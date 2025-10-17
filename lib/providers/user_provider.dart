import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoading = false;

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  final int _limit = 10;

  Future<void> fetchInitial() async {
    _users = [];
    _lastDoc = null;
    _hasMore = true;
    await fetchUsers();
  }

  Future<void> fetchUsers({bool loadMore = false}) async {
    if (_isLoading) return;
    if (!loadMore) {
      // fresh load
      _users = [];
      _lastDoc = null;
      _hasMore = true;
    }
    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      Query query = _db
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(_limit);

      if (loadMore && _lastDoc != null) {
        query = query.startAfterDocument(_lastDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final fetched = snap.docs.map((d) => UserModel.fromDocument(d)).toList();
        _users.addAll(fetched);
        if (fetched.length < _limit) {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
      }
    } catch (e) {

      debugPrint('fetchUsers error: $e');
      // optionally set a local error variable and notifyListeners()
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      final docRef = await _db.collection('users').add(user.toMap());
      // Insert locally at top so UI updates immediately
      final saved = user.copyWith(id: docRef.id);
      _users.insert(0, saved);
      notifyListeners();
    } catch (e) {
      debugPrint('addUser error: $e');
      rethrow;
    }
  }


  List<UserModel> search(String keyword) {
    final q = keyword.toLowerCase().trim();
    if (q.isEmpty) return _users;
    return _users.where((u) => u.name.toLowerCase().contains(q) || u.phone.contains(q)).toList();
  }


  List<UserModel> sortByAge({bool olderFirst = true}) {
    final list = List<UserModel>.from(_users);
    list.sort((a, b) {
      final aOlder = a.age >= 60;
      final bOlder = b.age >= 60;
      if (aOlder && !bOlder) return olderFirst ? -1 : 1;
      if (!aOlder && bOlder) return olderFirst ? 1 : -1;
      return 0;
    });
    return list;
  }
}

extension _UserCopy on UserModel {
  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    int? age,
    String? imageUrl,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        age: age ?? this.age,
        imageUrl: imageUrl ?? this.imageUrl,
        createdAt: createdAt ?? this.createdAt,
      );
}
