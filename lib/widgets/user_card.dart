import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/models/user_model.dart';
import '/screens/user_detail_screen.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  const UserCard({super.key, required this.user});

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailScreen(user: user),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: user.imageUrl != null && user.imageUrl!.isNotEmpty
              ? CachedNetworkImageProvider(user.imageUrl!)
              : null,
          child: (user.imageUrl == null || user.imageUrl!.isEmpty)
              ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
              : null,
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${user.phone}   Age: ${user.age} • $ageCategory"),
        trailing: Icon(user.age >= 60 ? Icons.celebration : Icons.person),
      ),
    );
  }
}