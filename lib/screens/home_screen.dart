import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/user_card.dart';
import '../models/user_model.dart';
import 'add_user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late UserProvider provider;

  @override
  void initState() {
    super.initState();
    provider = context.read<UserProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchUsers());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, prov, _) {
      final query = _searchCtrl.text.trim();
      final List<UserModel> displayList =
      query.isEmpty ? prov.users : prov.search(query);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Users',style: TextStyle(fontWeight: FontWeight.bold),),backgroundColor: Colors.cyan,
          actions: [
            IconButton(
              onPressed: () {
                prov.fetchInitial();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final added = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddUserScreen()),
            );
            if (added == true) {
            }
          },
          child: const Icon(Icons.fiber_new_rounded),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search by name or phone',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!prov.isLoading &&
                      prov.hasMore &&
                      scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
                    prov.fetchUsers(loadMore: true);
                    return true;
                  }
                  return false;
                },
                child: prov.users.isEmpty && prov.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: displayList.length + (prov.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < displayList.length) {
                      return UserCard(user: displayList[index]);
                    }

                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
