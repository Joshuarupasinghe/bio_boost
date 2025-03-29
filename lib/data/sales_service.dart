// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:bio_boost/models/sales_model.dart';

// class Database {
//   Future<List<Sales>> getSalesDetails() async {
//     List<Sales> salesDetailList = [];
//     try{
//       final QuerySnapshot querySnapshot = 
//       await FirebaseFirestore.instance.collection("Sales").get();

//       for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
//         Sales sales = Sales(
//           s_id: documentSnapshot.get('s_id')
//         )
//       }
//     }
//   }
// }
