import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> signUpSeller({
    required String username,
    required String password,
  }) async {
    try {
      // Get the current user
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'error': 'No authenticated user found'
        };
      }

      // Check if username is already taken
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        return {
          'success': false,
          'error': 'Username is already taken'
        };
      }

      // Update user role and add seller details
      await _firestore.collection('users').doc(currentUser.uid).update({
        'role': 'Seller',
        'username': username,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create a seller document
      await _firestore.collection('sellers').doc(currentUser.uid).set({
        'userId': currentUser.uid,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'role': 'Seller'
      };
    } catch (e) {
      print('Error in signUpSeller: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
}
