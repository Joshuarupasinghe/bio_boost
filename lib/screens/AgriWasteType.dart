import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bio_boost/screens/detail.dart';

class AgriWasteTypePage extends StatefulWidget {
  @override
  _AgriWasteTypePageState createState() => _AgriWasteTypePageState();
}

class _AgriWasteTypePageState extends State<AgriWasteTypePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    setState(() {
      _currentUser = _auth.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        body: Center(child: Text("Please sign in to view the listings.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Agri Waste Type"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("agri_waste_data").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var doc = data[index];
              return Card(
                color: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    "Waste Type: ${doc["wasteType"]}",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Location: ${doc["city"]}, ${doc["district"]}",
                    style: TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AgriWasteDetailPage(
                              currentUser: _currentUser!,
                              saleId: doc.id, // Pass the sales document ID
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
