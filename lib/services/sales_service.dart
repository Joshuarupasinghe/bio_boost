import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sales_model.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all sales listings
  Stream<List<Sales>> getSalesListings() {
    return _firestore.collection('sales').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Sales.fromMap(doc.data(), doc.id)).toList();
    });
  }

    Future<Sales?> getSalesById(String saleId) async {
    try {
      final doc = await _firestore.collection('sales').doc(saleId).get();
      if (doc.exists) {
        return Sales.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting sale: $e');
      return null;
    }
  }

  // Add a new sale
  Future<void> addSale(Sales sale) async {
    await _firestore.collection('sales').add(sale.toMap());
  }

  // Update a sale
  Future<void> updateSale(Sales sale) async {
    await _firestore.collection('sales').doc(sale.id).update(sale.toMap());
  }

  // Delete a sale
  Future<void> deleteSale(String saleId) async {
    await _firestore.collection('sales').doc(saleId).delete();
  }

  // Toggle wishlist status
  Future<void> toggleWishlistStatus(String saleId, bool currentStatus) async {
    await _firestore.collection('sales').doc(saleId).update({
      'isInWishlist': !currentStatus,
    });
  }
}