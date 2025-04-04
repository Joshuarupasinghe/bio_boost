import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up Method
  Future<Map<String, dynamic>?> signUp(UserModel user, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      user = user.copyWith(uid: result.user!.uid);
      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      return {'user': result.user, 'role': user.role};
    } catch (e) {
      print("Sign Up Error: ${e.toString()}");
      return null;
    }
  }

  // Sign In Method (Returns User and Role)
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? role = await getUserRole(result.user!.uid);
      if (role != null) {
        return {'user': result.user, 'role': role};
      }
      return null;
    } catch (e) {
      print("Sign In Error: ${e.toString()}");
      return null;
    }
  }

  // Get the user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;

        // If you have an array field called 'roles':
        final List<dynamic> roles = data['roles'] ?? [];

        // If 'seller' is in the array, treat them as a seller
        if (roles.contains('seller') || roles.contains('Seller')) {
          return 'Seller';
        } else {
          return 'Buyer';
        }
      }
      return null;
    } catch (e) {
      print("Error getting user role: ${e.toString()}");
      return null;
    }
  }
}
