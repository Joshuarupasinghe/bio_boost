import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/buyer_model.dart';

class BuyerAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in buyer
  Future<UserCredential> signInBuyer(String username, String password) async {
    try {
      String email = "$username@buyerapp.com";
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      throw e;
    }
  }

  // Register a new buyer
  Future<BuyerModel> registerBuyer(String username, String password) async {
    try {
      // Use a more unique email format with timestamp
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String email = "$username-$timestamp@buyerapp.com";
      
      // Check if username already exists in Firestore
      bool usernameExists = await checkUserExists(username);
      if (usernameExists) {
        throw FirebaseAuthException(
          code: 'username-already-in-use',
          message: 'This username is already taken. Please choose another one.'
        );
      }
      
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create buyer object
      BuyerModel buyer = BuyerModel(
        uid: userCredential.user!.uid,
        username: username,
        email: email,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Convert to map and add buyer details to Firestore
      Map<String, dynamic> buyerMap = buyer.toMap();
      await _firestore
          .collection('buyers')
          .doc(userCredential.user!.uid)
          .set(buyerMap);

      return buyer;
    } catch (e) {
      print('Error registering buyer: $e');
      throw e;
    }
  }

  // Check if username exists - improve this method to check both collections
  Future<bool> checkUserExists(String username) async {
    try {
      // Check in buyers collection
      var existingBuyer = await _firestore
          .collection('buyers')
          .where('username', isEqualTo: username)
          .get();

      if (existingBuyer.docs.isNotEmpty) {
        return true;
      }
      
      // Also check in sellers collection to avoid duplicate usernames
      var existingSeller = await _firestore
          .collection('sellers')
          .where('username', isEqualTo: username)
          .get();
          
      return existingSeller.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user existence: $e');
      throw e;
    }
  }

  // Get current buyer profile
  Future<BuyerModel?> getCurrentBuyerProfile() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot doc = await _firestore
            .collection('buyers')
            .doc(currentUser.uid)
            .get();
            
        if (!doc.exists) {
          return null;
        }
        
        return BuyerModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting buyer profile: $e');
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

  // Update buyer profile
  Future<void> updateBuyerProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('buyers')
          .doc(uid)
          .update(data);
    } catch (e) {
      print('Error updating buyer profile: $e');
      throw e;
    }
  }
}