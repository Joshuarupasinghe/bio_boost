import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new service request to Firestore
  Future<void> addServiceRequest(
    String serviceType,
    double weight,
    String description,
    String name,
    String location,
  ) async {
    try {
      // Create a new document in the "serviceRequests" collection
      await _firestore.collection('serviceRequests').add({
        'serviceType': serviceType,
        'weight': weight,
        'description': description,
        'name': name,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // Initial status for the request
      });
    } catch (e) {
      // Re-throw the error so we can handle it in the UI
      throw Exception('Failed to add service request: $e');
    }
  }

  // Get all service requests
  Future<List<Map<String, dynamic>>> getServiceRequests() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('serviceRequests')
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get service requests: $e');
    }
  }

  // Get service requests by name
  Future<List<Map<String, dynamic>>> getServiceRequestsByName(String name) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('serviceRequests')
          .where('name', isEqualTo: name)
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get service requests by name: $e');
    }
  }

  // Update an existing service request
  Future<void> updateServiceRequest(
    String requestId, 
    Map<String, dynamic> data
  ) async {
    try {
      await _firestore
          .collection('serviceRequests')
          .doc(requestId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update service request: $e');
    }
  }

  // Delete a service request
  Future<void> deleteServiceRequest(String requestId) async {
    try {
      await _firestore
          .collection('serviceRequests')
          .doc(requestId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete service request: $e');
    }
  }

  // Stream service requests to get real-time updates
  Stream<QuerySnapshot> fetchServiceRequests() {
    return _firestore
        .collection('serviceRequests')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}