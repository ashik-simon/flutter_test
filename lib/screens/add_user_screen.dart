import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '/models/user_model.dart';
import '/providers/user_provider.dart';
import 'dart:io';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => AddUserScreenState();
}

class AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  File? image;
  bool isLoading = false;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      if (file.lengthSync() > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image must be under 2MB")),
        );
        return;
      }
      setState(() {
        image = file as XFile?;
      });
    }
  }

  Future<String?> uploadImage() async {
    if (image == null) return null;
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image!);
    return await ref.getDownloadURL();
  }

  void addUser() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final ageText = ageController.text.trim();

    if (name.isEmpty || phone.isEmpty || ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid age")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final imageUrl = await uploadImage();
      final user = UserModel(
        id: '',
        name: name,
        phone: phone,
        age: age,
        imageUrl: imageUrl,
      );

      await Provider.of<UserProvider>(context, listen: false).addUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User added successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding user: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add User", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.cyan,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text('Totalx',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: image != null ? FileImage(image!) : null,
                child: image == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: addUser,
                    child: const Text("Add User"),
                  ),
          ],
        ),
      ),
    );
  }
}
