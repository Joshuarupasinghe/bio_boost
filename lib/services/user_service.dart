import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  Future<String> getCurrentUserFullName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final userData = doc.data();
        final firstName = userData?['firstName'] ?? '';
        final lastName = userData?['lastName'] ?? '';
        return '$firstName $lastName';
      }
    }

    return 'Unknown User';
  }

  Future<String> getCurrentUserLocation() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final userData = doc.data();
        final district = userData?['district'] ?? '';
        final city = userData?['city'] ?? '';
        return '$city, $district';
      }
    }

    return 'Unknown Location';
  }

  Future<String> getCurrentUserPhoneNumber() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final userData = doc.data();
        final contact = userData?['contactNumber'] ?? '';
        return '$contact';
      }
    }

    return 'Unknown Location';
  }
}
