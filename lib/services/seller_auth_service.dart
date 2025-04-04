import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if username is already taken
  Future<bool> isUsernameTaken(String username) async {
    try {
      // Check both users and sellers collections
      final usersQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      
      final sellersQuery = await _firestore
          .collection('sellers')
          .where('username', isEqualTo: username)
          .get();
      
      return usersQuery.docs.isNotEmpty || sellersQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return true; // Default to true on error to prevent duplicate usernames
    }
  }

  // Register a new seller
  Future<Map<String, dynamic>> registerSeller({
    required String username,
    required String password,
  }) async {
    try {
      // Check if username is already taken
      bool usernameTaken = await isUsernameTaken(username);
      if (usernameTaken) {
        return {
          'success': false,
          'error': 'Username is already taken'
        };
      }

      // Create a unique email using the username for FirebaseAuth
      // This is just for auth purposes - we'll use username for display
      String email = '$username@seller.bioboost.com';
      
      // Create user in Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User user = result.user!;
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': username,
        'email': email,
        'role': 'seller',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Create seller document in Firestore
      await _firestore.collection('sellers').doc(user.uid).set({
        'userId': user.uid,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return {
        'success': true,
        'user': user.uid
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'This username is already in use';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during registration';
      }
      
      return {
        'success': false,
        'error': errorMessage
      };
    } catch (e) {
      print('Error in registerSeller: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // Convert existing user to seller
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
        'role': 'seller',
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
        'role': 'seller'
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
