import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final int age;
  final String? imageUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.age,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }


  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    // handle Timestamp vs DateTime
    DateTime created;
    final raw = map['createdAt'];
    if (raw is Timestamp) {
      created = raw.toDate();
    } else if (raw is DateTime) {
      created = raw;
    } else {
      created = DateTime.now();
    }

    final ageVal = map['age'];
    final intAge = ageVal is int ? ageVal : int.tryParse('$ageVal') ?? 0;

    return UserModel(
      id: id,
      name: (map['name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      age: intAge,
      imageUrl: map['imageUrl'] as String?,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'age': age,
    'imageUrl': imageUrl ?? '',
    'createdAt': Timestamp.fromDate(createdAt),
  };


  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    int? age,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
