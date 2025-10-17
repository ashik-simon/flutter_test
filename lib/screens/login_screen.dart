import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String verificationId = '';
  bool otpSent = false;

  void sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        navigateHome();
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")));
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          otpSent = true;
          verificationId = verId;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  void verifyOTP() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otpController.text.trim());

      await _auth.signInWithCredential(credential);
      navigateHome();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid OTP")));
    }
  }

  void navigateHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                  labelText: "Phone Number (+91...)", hintText: "+919999999999"),
            ),
            const SizedBox(height: 20),
            otpSent
                ? Column(
              children: [
                TextField(
                  controller: otpController,
                  decoration: const InputDecoration(labelText: "Enter OTP"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: verifyOTP, child: const Text("Verify OTP"))
              ],
            )
                : ElevatedButton(
                onPressed: sendOTP, child: const Text("Send OTP")),
          ],
        ),
      ),
    );
  }
}
