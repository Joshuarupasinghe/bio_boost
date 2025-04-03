import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user's UID
  String? get currentUserId => _auth.currentUser?.uid;

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password - Improved error handling
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      // Trim inputs to prevent whitespace issues
      email = email.trim();
      password = password.trim();
      
      // Attempt to sign in
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if user exists in Firestore
      String? role = await getUserRole(result.user!.uid);
      
      // If user has no role, check both collections
      if (role == null) {
        // Check sellers collection
        DocumentSnapshot sellerDoc = 
            await _firestore.collection('sellers').doc(result.user!.uid).get();
        
        if (sellerDoc.exists) {
          role = 'seller';
        } else {
          // Check buyers collection
          DocumentSnapshot buyerDoc = 
              await _firestore.collection('buyers').doc(result.user!.uid).get();
          
          if (buyerDoc.exists) {
            role = 'buyer';
          } else {
            // Check users collection
            DocumentSnapshot userDoc = 
                await _firestore.collection('users').doc(result.user!.uid).get();
                
            if (userDoc.exists) {
              Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
              role = userData['role'] ?? 'seller';
              
              // Create entry in appropriate collection based on role
              if (role.toString().toLowerCase() == 'seller') {
                await _firestore.collection('sellers').doc(result.user!.uid).set(userData);
              } else {
                await _firestore.collection('buyers').doc(result.user!.uid).set(userData);
              }
            } else {
              // Create a basic profile if none exists at all
              Map<String, dynamic> basicProfile = {
                'uid': result.user!.uid,
                'email': email,
                'role': 'seller',
                'createdAt': FieldValue.serverTimestamp(),
                'firstName': result.user!.email!.split('@')[0], // Use part of email as name
                'lastName': '',
              };
              
              await _firestore.collection('sellers').doc(result.user!.uid).set(basicProfile);
              await _firestore.collection('users').doc(result.user!.uid).set(basicProfile);
              
              role = 'seller';
            }
          }
        }
      }
      
      return {'user': result.user, 'role': role ?? 'seller'};
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      
      // Convert Firebase error codes to more user-friendly messages
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'The password is incorrect.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many sign-in attempts. Try again later.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred.';
      }
      
      throw errorMessage;
    } catch (e) {
      print("General Sign In Error: ${e.toString()}");
      throw 'Failed to sign in: ${e.toString()}';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Failed to sign in: ${e.message}');
      throw e;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailPassword(
    String email, 
    String password, 
    String role, // 'seller' or 'buyer'
    Map<String, dynamic> userData
  ) async {
    try {
      // Create user account
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Add UID to userData
      userData['uid'] = userCredential.user!.uid;
      userData['role'] = role;
      userData['email'] = email;
      userData['createdAt'] = FieldValue.serverTimestamp();
      
      // Store user data in Firestore
      String collectionPath = role.toLowerCase() == 'seller' ? 'sellers' : 'buyers';
      await _firestore.collection(collectionPath).doc(userCredential.user!.uid).set(userData);
      
      // Also save to users collection for consistency
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Failed to create user: ${e.message}');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }

  // Get user role (seller or buyer)
  Future<String?> getUserRole(String uid) async {
    try {
      // Check if user exists in sellers collection
      DocumentSnapshot sellerDoc = await _firestore.collection('sellers').doc(uid).get();
      if (sellerDoc.exists) {
        return 'seller';
      }
      
      // Check if user exists in buyers collection
      DocumentSnapshot buyerDoc = await _firestore.collection('buyers').doc(uid).get();
      if (buyerDoc.exists) {
        return 'buyer';
      }
      
      // Check if user exists in users collection
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['role']?.toString().toLowerCase();
      }
      
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Error sending password reset email: ${e.message}');
      throw e;
    }
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUserId == null) {
      return null;
    }

    try {
      // Determine user role
      String? role = await getUserRole(currentUserId!);
      if (role == null) {
        // Try to get from users collection first
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUserId).get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>;
        }
        return null;
      }

      // Get user data from appropriate collection
      String collectionPath = role == 'seller' ? 'sellers' : 'buyers';
      DocumentSnapshot doc = await _firestore.collection(collectionPath).doc(currentUserId).get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}
