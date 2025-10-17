import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/widgets/user_card.dart';
import '/models/user_model.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => SearchUserScreenState();
}

class SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController searchController = TextEditingController();
  List<UserModel> searchResults = [];
  bool isLoading = false;

  // Function to perform search
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    setState(() => isLoading = true);

    try {

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .get();

      final results = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

      setState(() {
        searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching users: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search people by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    searchResults.clear();
                    setState(() {});
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: searchUsers,
            ),

            const SizedBox(height: 16),

            // Loading indicator
            if (isLoading)
              const CircularProgressIndicator()
            else if (searchResults.isEmpty && searchController.text.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Start typing to search users...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else if (searchResults.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No users found!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
              // Display results
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      return UserCard(user: user);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
