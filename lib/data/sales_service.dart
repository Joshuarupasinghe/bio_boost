import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bio_boost/models/sales_model.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'sales';

  // Get all sales (for admin or marketplace view)
  Future<List<Sales>> getSalesDetails() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection(_collectionPath).get();

      return querySnapshot.docs
          .map(
            (doc) => Sales.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('Error fetching sales details: $e');
      return [];
    }
  }

  // Get sales for a specific seller using UID
  Future<List<Sales>> getSellerSales(String uid) async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collection(_collectionPath)
              .where('uid', isEqualTo: uid) // Use 'uid' instead of 's_sellerId'
              .get();

      return querySnapshot.docs
          .map(
            (doc) => Sales.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('Error fetching seller sales: $e');
      return [];
    }
  }

  // Get a specific sale by its ID
  Future<Sales?> getSalesDetailsById(String documentId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionPath).doc(documentId).get();

      if (doc.exists) {
        return Sales.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print("Error fetching sale details: $e");
    }
    return null;
  }

  // Add a new sale
  Future<String?> addSale(Sales sale) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collectionPath)
          .add(sale.toMap());
      return docRef.id;
    } catch (e) {
      print("Error adding sale: $e");
      return null;
    }
  }

  // Update an existing sale
  Future<bool> updateSale(
    String documentId,
    Map<String, dynamic> saleData,
  ) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(documentId)
          .update(saleData);
      return true;
    } catch (e) {
      print("Error updating sale: $e");
      return false;
    }
  }

  // Delete a sale
  Future<bool> deleteSale(String documentId) async {
    try {
      await _firestore.collection(_collectionPath).doc(documentId).delete();
      return true;
    } catch (e) {
      print('Error deleting sale: $e');
      return false;
    }
  }
}
