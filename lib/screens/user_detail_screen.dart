import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;
  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String ageCategory;
    if (user.age >= 60) {
      ageCategory = 'Older';
    } else if (user.age >= 30) {
      ageCategory = 'Middle Age';
    } else {
      ageCategory = 'Young';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        backgroundColor: Colors.tealAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.imageUrl != null && user.imageUrl!.isNotEmpty)
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user.imageUrl!),
                ),
              ),
            const SizedBox(height: 20),
            Text("Name: ${user.name}", style: const TextStyle(fontSize: 18)),
            Text("Phone: ${user.phone}", style: const TextStyle(fontSize: 18)),
            Text("Age: ${user.age}", style: const TextStyle(fontSize: 18)),
            Text("Category: $ageCategory", style: const TextStyle(fontSize: 18)),
            Text("Created At: ${user.createdAt.toLocal()}",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}