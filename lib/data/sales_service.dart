import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bio_boost/models/sales_model.dart';

class SalesService {
  Future<List<Sales>> getSalesDetails() async {
    List<Sales> salesDetailList = [];
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("sales").get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Sales sales = Sales.fromMap(
          documentSnapshot.data() as Map<String, dynamic>,
          documentSnapshot.id, // Pass document ID
        );
        salesDetailList.add(sales);
      }
      return salesDetailList;
    } catch (e) {
      print('Error fetching sales details: $e');
      return [];
    }
  }

  Future<Sales?> getSalesDetailsById(String documentId) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection("sales")
              .doc(documentId)
              .get();

      if (doc.exists) {
        return Sales.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching sale details: $e");
      return null;
    }
  }
}
