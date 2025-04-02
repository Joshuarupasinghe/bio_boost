import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerModel {
  final String uid;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime lastLogin;

  BuyerModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.lastLogin,
  });

  // Convert model to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  // Create model from Firestore document
  factory BuyerModel.fromMap(Map<String, dynamic> map) {
    return BuyerModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}