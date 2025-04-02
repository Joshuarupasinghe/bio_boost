import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up Method
  Future<User?> signUp(UserModel user, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      user = user.copyWith(uid: result.user!.uid);
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return result.user;
    } catch (e) {
      print("Sign Up Error: ${e.toString()}");
      return null;
    }
  }

  // Sign In Method
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Sign In Error: ${e.toString()}");
      return null;
    }
  }

  // Sign Out Method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Current User Stream (Listen for Auth Changes)
  Stream<User?> get userStream {
    return _auth.authStateChanges();
  }
}
