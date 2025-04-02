import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseException implements Exception {
  final String message;
  FirebaseException(this.message);
  @override
  String toString() => message;
}

class CompanyProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Get company profile data
  Future<Map<String, dynamic>?> getCompanyProfile() async {
    try {
      if (currentUserId == null) {
        throw FirebaseException('No authenticated user found');
      }

      final doc = await _firestore
          .collection('companies')
          .doc(currentUserId)
          .get();

      if (!doc.exists) {
        return {'error': 'Profile not found'};
      }

      return doc.data();
    } catch (e) {
      print('Error getting company profile: $e');
      throw FirebaseException('Failed to fetch company profile: ${e.toString()}');
    }
  }

  // Update company profile
  Future<bool> updateCompanyProfile(Map<String, dynamic> profileData) async {
    try {
      if (currentUserId == null) {
        throw FirebaseException('No authenticated user found');
      }

      // Validate required fields
      final requiredFields = ['fullName', 'email', 'phone'];
      for (final field in requiredFields) {
        if (profileData.containsKey(field) && (profileData[field] == null || profileData[field].toString().isEmpty)) {
          throw FirebaseException('$field cannot be empty');
        }
      }

      // Add timestamp
      profileData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('companies')
          .doc(currentUserId)
          .set(profileData, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      print('Error updating company profile: $e');
      return false;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(String filePath) async {
    try {
      if (currentUserId == null) {
        throw FirebaseException('No authenticated user found');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw FirebaseException('Image file not found');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('company_profiles/$currentUserId/profile_$timestamp.jpg');
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': currentUserId.toString()}
      );
      
      await ref.putFile(file, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      throw FirebaseException('Failed to upload profile image: ${e.toString()}');
    }
  }

  // Add to wishlist
  Future<bool> addToWishlist(String itemId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('companies')
          .doc(currentUserId)
          .collection('wishlist')
          .doc(itemId)
          .set({'addedAt': FieldValue.serverTimestamp()});

      return true;
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    }
  }

  // Remove from wishlist
  Future<bool> removeFromWishlist(String itemId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('companies')
          .doc(currentUserId)
          .collection('wishlist')
          .doc(itemId)
          .delete();

      return true;
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  // Get wishlist items
  Stream<QuerySnapshot> getWishlistStream() {
    if (currentUserId == null) {
      throw Exception('No authenticated user');
    }

    return _firestore
        .collection('companies')
        .doc(currentUserId)
        .collection('wishlist')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  // Add wanted item
  Future<bool> addWantedItem(Map<String, dynamic> wantedData) async {
    try {
      if (currentUserId == null) return false;

      await _firestore.collection('wanted_items').add({
        ...wantedData,
        'companyId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error adding wanted item: $e');
      return false;
    }
  }

  // Get wanted items
  Stream<QuerySnapshot> getWantedItemsStream() {
    if (currentUserId == null) {
      throw Exception('No authenticated user');
    }

    return _firestore
        .collection('wanted_items')
        .where('companyId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete wanted item
  Future<bool> deleteWantedItem(String itemId) async {
    try {
      await _firestore.collection('wanted_items').doc(itemId).delete();
      return true;
    } catch (e) {
      print('Error deleting wanted item: $e');
      return false;
    }
  }
}