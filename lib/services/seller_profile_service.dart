import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Update seller profile
  Future<bool> updateSellerProfile({
    required String firstName,
    required String lastName,
    required String contact,
    required String email,
    required String district,
    required String city,
    File? profileImage,
  }) async {
    try {
      if (currentUserId == null) {
        return false;
      }

      // Prepare profile data
      Map<String, dynamic> profileData = {
        'firstName': firstName,
        'lastName': lastName,
        'contact': contact,
        'email': email,
        'district': district,
        'city': city,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Upload image if provided
      if (profileImage != null) {
        String imageUrl = await _uploadProfileImage(profileImage);
        if (imageUrl.isNotEmpty) {
          profileData['profileImage'] = imageUrl;
        }
      }

      // Update profile in Firestore
      await _firestore.collection('users').doc(currentUserId).update(profileData);
      
      return true;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }

  // Upload profile image to Firebase Storage
  Future<String> _uploadProfileImage(File imageFile) async {
    try {
      // Create storage reference with timestamp to avoid caching
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage
          .ref()
          .child('profile_images/$currentUserId/profile_$timestamp.jpg');
      
      // Upload file
      await ref.putFile(imageFile);
      
      // Get download URL
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }

  // Get seller profile
  Future<Map<String, dynamic>?> getSellerProfile() async {
    try {
      if (currentUserId == null) {
        return null;
      }

      final doc = await _firestore.collection('users').doc(currentUserId).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add username from email if not present
        if (!data.containsKey('username')) {
          String? email = _auth.currentUser?.email;
          if (email != null) {
            data['username'] = email.split('@')[0];
          }
        }
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting profile: $e");
      return null;
    }
  }
}