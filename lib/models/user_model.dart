// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String userType; // 'customer' or 'provider'
  final String? profileImageUrl;
  final List<String> favoriteServices;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    this.profileImageUrl,
    this.favoriteServices = const [],
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      userType: data['userType'] ?? 'customer',
      profileImageUrl: data['profileImageUrl'],
      favoriteServices: List<String>.from(data['favoriteServices'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'userType': userType,
      'profileImageUrl': profileImageUrl,
      'favoriteServices': favoriteServices,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}