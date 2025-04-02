import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wanted_sales_model.dart';

class WantedSalesService {
  final CollectionReference wantedSalesCollection = FirebaseFirestore.instance
      .collection('wanted_sales');

  // Add Wanted Sale
  Future<void> addWantedSale(WantedSale sale) async {
    try {
      await wantedSalesCollection.doc(sale.id).set(sale.toMap());
    } catch (e) {
      print('Error adding wanted sale: $e');
    }
  }

  // Fetch Wanted Sales List
  Stream<List<WantedSale>> getWantedSales() {
    return wantedSalesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return WantedSale.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
