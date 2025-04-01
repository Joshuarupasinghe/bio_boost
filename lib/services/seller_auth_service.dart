import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seller_model.dart';

class SellerAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpSeller(String username, String password) async {
    try {
      String email = "$username@sellerapp.com"; // Generating an email
      print("Attempting sign-up for: $email");

      // Check if the username is already taken in Firestore
      var existingUser =
          await _firestore
              .collection('sellers')
              .where('username', isEqualTo: username)
              .get();

      if (existingUser.docs.isNotEmpty) {
        print("Username already exists!");
        return null; // Stop sign-up if username exists
      }

      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ User created in Firebase Auth: ${result.user!.uid}");
      //Store seller details in Firestore
      SellerModel seller = SellerModel(
        uid: result.user!.uid,
        username: username,
        email: email,
      );

      await _firestore
          .collection('sellers')
          .doc(seller.uid)
          .set(seller.toMap());
      print("✅ Seller data saved to Firestore");
      return result.user;
    } catch (e) {
      print("Firebase Error: ${e.toString()}");
      return null;
    }
  }
}
