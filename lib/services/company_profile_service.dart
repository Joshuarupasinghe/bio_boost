import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/wanted_sales_model.dart';

class CompanyProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Get current user profile stream
  Stream<UserModel?> getUserProfile() {
    if (currentUserId == null) return Stream.value(null);
    
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
          try {
            if (snapshot.exists && snapshot.data() != null) {
              // Handle potential null values in the data
              Map<String, dynamic> data = snapshot.data()!;
              
              // Create a sanitized map with no null values
              Map<String, dynamic> sanitizedData = {
                'uid': data['uid'] ?? currentUserId,
                'firstName': data['firstName'] ?? 'Default',
                'lastName': data['lastName'] ?? 'User',
                'email': data['email'] ?? _auth.currentUser?.email ?? 'default@example.com',
                'companyName': data['companyName'] ?? 'Default Company',
                'phone': data['phone'] ?? '1234567890',
                'address': data['address'] ?? 'Default Address',
                'district': data['district'] ?? 'Default District',
                'city': data['city'] ?? 'Default City',
                'role': data['role'] ?? 'buyer',
              };
              
              return UserModel.fromMap(sanitizedData);
            } else {
              // Document doesn't exist, create it with default values
              UserModel defaultUser = UserModel(
                uid: currentUserId!,
                firstName: 'Default',
                lastName: 'User',
                email: _auth.currentUser?.email ?? 'default@example.com',
                companyName: 'Default Company',
                phone: '1234567890',
                address: 'Default Address',
                district: 'Default District',
                city: 'Default City',
                role: 'buyer',
              );
              
              try {
                // Create the document with default values
                await _firestore.collection('users').doc(currentUserId).set(defaultUser.toMap());
                print("Created default user profile");
                return defaultUser;
              } catch (e) {
                print("Error creating default profile: $e");
                return defaultUser; // Return default user even if save fails
              }
            }
          } catch (e) {
            print("Error processing user data: $e");
            // Return a fallback user model to avoid errors
            return UserModel(
              uid: currentUserId!,
              firstName: 'Error',
              lastName: 'Recovery',
              email: _auth.currentUser?.email ?? 'error@example.com',
              companyName: 'Error Recovery',
              phone: '0000000000',
              address: 'Error Address',
              district: 'Error District',
              city: 'Error City',
              role: 'buyer',
            );
          }
        });
  }
  
  // Get user profile by ID
  Future<UserModel?> getUserProfileById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Create a sanitized map with no null values
        Map<String, dynamic> sanitizedData = {
          'uid': data['uid'] ?? userId,
          'firstName': data['firstName'] ?? 'Default',
          'lastName': data['lastName'] ?? 'User',
          'email': data['email'] ?? 'default@example.com',
          'companyName': data['companyName'] ?? 'Default Company',
          'phone': data['phone'] ?? '1234567890',
          'address': data['address'] ?? 'Default Address',
          'district': data['district'] ?? 'Default District',
          'city': data['city'] ?? 'Default City',
          'role': data['role'] ?? 'buyer',
        };
        
        return UserModel.fromMap(sanitizedData);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? district,
    String? city,
    String? companyName,
    String? email,
  }) async {
    try {
      if (currentUserId == null) return false;
      
      // Get current user data
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUserId).get();
      Map<String, dynamic> userData;
      
      if (!userDoc.exists) {
        // Create default user if not exists
        userData = {
          'uid': currentUserId,
          'firstName': 'Default',
          'lastName': 'User',
          'email': _auth.currentUser?.email ?? 'default@example.com',
          'companyName': 'Default Company',
          'phone': '1234567890',
          'address': 'Default Address',
          'district': 'Default District',
          'city': 'Default City',
          'role': 'buyer',
        };
      } else {
        userData = userDoc.data() as Map<String, dynamic>;
      }
      
      // Update with new values, ensuring no null values
      Map<String, dynamic> updatedData = {
        'uid': currentUserId,
        'firstName': firstName ?? userData['firstName'] ?? 'Default',
        'lastName': lastName ?? userData['lastName'] ?? 'User',
        'email': email ?? userData['email'] ?? _auth.currentUser?.email ?? 'default@example.com',
        'companyName': companyName ?? userData['companyName'] ?? 'Default Company',
        'phone': phone ?? userData['phone'] ?? '1234567890',
        'address': address ?? userData['address'] ?? 'Default Address',
        'district': district ?? userData['district'] ?? 'Default District',
        'city': city ?? userData['city'] ?? 'Default City',
        'role': userData['role'] ?? 'buyer',
      };
      
      await _firestore.collection('users').doc(currentUserId).set(updatedData);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
  
  // Reset profile to default values
  Future<bool> resetProfile({String? customEmail}) async {
    try {
      if (currentUserId == null) return false;
      
      // Set default profile data
      Map<String, dynamic> defaultData = {
        'uid': currentUserId,
        'firstName': 'Reset',
        'lastName': 'User',
        'email': customEmail ?? _auth.currentUser?.email ?? 'reset@example.com',
        'companyName': 'Reset Company',
        'phone': '9876543210',
        'address': 'Reset Address',
        'district': 'Reset District',
        'city': 'Reset City',
        'role': 'buyer',
      };
      
      await _firestore.collection('users').doc(currentUserId).set(defaultData);
      return true;
    } catch (e) {
      print('Error resetting profile: $e');
      return false;
    }
  }
  
  // Get all "wants" for the current user
  Stream<List<WantedSale>> getUserWants() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('wanted_sales')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return WantedSale.fromMap(doc.data(), doc.id);
        } catch (e) {
          print('Error parsing want data: $e');
          // Return a dummy want on error
          return WantedSale(
            id: doc.id,
            name: 'Error loading',
            location: 'Unknown',
            weight: 0,
            description: 'Error loading want data',
          );
        }
      }).toList();
    });
  }
  
  // Add a new "want"
  Future<bool> addUserWant(String name, String location, double weight, String description) async {
    try {
      if (currentUserId == null) return false;
      
      DocumentReference docRef = _firestore.collection('wanted_sales').doc();
      
      WantedSale newWant = WantedSale(
        id: docRef.id,
        name: name,
        location: location,
        weight: weight,
        description: description,
      );
      
      await docRef.set({
        ...newWant.toMap(),
        'userId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error adding want: $e');
      return false;
    }
  }
  
  // Delete a "want"
  Future<bool> deleteUserWant(String wantId) async {
    try {
      if (currentUserId == null) return false;
      
      // Verify the want belongs to the current user
      DocumentSnapshot wantDoc = await _firestore.collection('wanted_sales').doc(wantId).get();
      
      if (!wantDoc.exists) return false;
      Map<String, dynamic> data = wantDoc.data() as Map<String, dynamic>;
      
      if (data['userId'] != currentUserId) {
        // Not authorized to delete this want
        return false;
      }
      
      await _firestore.collection('wanted_sales').doc(wantId).delete();
      return true;
    } catch (e) {
      print('Error deleting want: $e');
      return false;
    }
  }
  
  // Update user's "become seller" status
  Future<bool> updateToSellerRole() async {
    try {
      if (currentUserId == null) return false;
      
      await _firestore.collection('users').doc(currentUserId).update({
        'role': 'seller',
      });
      
      return true;
    } catch (e) {
      print('Error updating to seller role: $e');
      return false;
    }
  }
} 