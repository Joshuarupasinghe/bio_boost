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

  // Get current user
  User? get currentUser => _auth.currentUser;

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
        'phoneNumber': contact, // Add for compatibility with signup data
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

      // Update profile in Firestore (both in sellers and users collections)
      await _firestore.collection('sellers').doc(currentUserId).set(
            profileData,
            SetOptions(merge: true),
          );
      
      // Update in users collection for consistency
      await _firestore.collection('users').doc(currentUserId).set(
            profileData,
            SetOptions(merge: true),
          );
      
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

  // Get seller profile from multiple collections
  Future<Map<String, dynamic>?> getSellerProfile() async {
    try {
      if (currentUserId == null) {
        return null;
      }

      // Try to get from sellers collection first
      final sellerDoc = await _firestore.collection('sellers').doc(currentUserId).get();
      
      if (sellerDoc.exists && sellerDoc.data() != null) {
        return sellerDoc.data();
      }
      
      // If not found in sellers, try users collection
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data()!;
        
        // If user exists but is not in sellers collection and has seller role, create entry
        if (userData['role'] == 'Seller' || userData['role'] == 'seller') {
          await _firestore.collection('sellers').doc(currentUserId).set(
                userData,
                SetOptions(merge: true),
              );
        }
        
        return userData;
      }
      
      return null;
    } catch (e) {
      print("Error getting profile: $e");
      return null;
    }
  }

  // Get seller full name
  Future<String> getSellerFullName() async {
    try {
      final profileData = await getSellerProfile();
      if (profileData != null) {
        String firstName = profileData['firstName'] ?? '';
        String lastName = profileData['lastName'] ?? '';
        return '$firstName $lastName'.trim();
      }
      return '';
    } catch (e) {
      print("Error getting seller full name: $e");
      return '';
    }
  }

  // Get seller username for display
  Future<String> getSellerUsername() async {
    try {
      final profileData = await getSellerProfile();
      if (profileData != null) {
        return profileData['firstName'] ?? '';
      }
      return '';
    } catch (e) {
      print("Error getting seller username: $e");
      return '';
    }
  }

  // Get seller location (district + city)
  Future<String> getSellerLocation() async {
    try {
      final profileData = await getSellerProfile();
      if (profileData != null) {
        String city = profileData['city'] ?? '';
        String district = profileData['district'] ?? '';
        if (city.isNotEmpty && district.isNotEmpty) {
          return '$city, $district';
        } else if (city.isNotEmpty) {
          return city;
        } else if (district.isNotEmpty) {
          return district;
        }
      }
      return '';
    } catch (e) {
      print("Error getting seller location: $e");
      return '';
    }
  }

  // Get seller contact number
  Future<String> getSellerContactNumber() async {
    try {
      final profileData = await getSellerProfile();
      if (profileData != null) {
        // Check both contact and phoneNumber fields for compatibility
        return profileData['contact'] ?? profileData['phoneNumber'] ?? '';
      }
      return '';
    } catch (e) {
      print("Error getting seller contact number: $e");
      return '';
    }
  }

  // Get seller email
  Future<String> getSellerEmail() async {
    try {
      // First try to get from Firestore
      final profileData = await getSellerProfile();
      if (profileData != null && profileData['email'] != null) {
        return profileData['email'];
      }
      
      // If not in Firestore, try to get from Firebase Auth
      if (currentUser != null && currentUser!.email != null) {
        return currentUser!.email!;
      }
      
      return '';
    } catch (e) {
      print("Error getting seller email: $e");
      return '';
    }
  }

  // Get profile image URL
  Future<String> getProfileImageUrl() async {
    try {
      final profileData = await getSellerProfile();
      if (profileData != null && profileData['profileImage'] != null) {
        return profileData['profileImage'];
      }
      return '';
    } catch (e) {
      print("Error getting profile image URL: $e");
      return '';
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }
}