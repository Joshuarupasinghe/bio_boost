import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AgriWasteTypePage(),
    );
  }
}

class AgriWasteTypePage extends StatefulWidget {
  final String? selectedCategory;

  const AgriWasteTypePage({super.key, this.selectedCategory});

  @override
  _AgriWasteTypePageState createState() => _AgriWasteTypePageState();
}

class _AgriWasteTypePageState extends State<AgriWasteTypePage> {
  String? selectedDistrict;
  String? selectedCity;
  String? selectedWasteType;

  @override
  void initState() {
    super.initState();
    selectedWasteType = widget.selectedCategory; // Set the initial value
  }

  List<String> districts = [
    "Colombo",
    "Gampaha",
    "Kalutara",
    "Kandy",
    "Matale",
    "Nuwara Eliya",
    "Galle",
    "Matara",
    "Hambantota",
    "Jaffna",
    "Kilinochchi",
    "Mannar",
    "Mullaitivu",
    "Vavuniya",
    "Trincomalee",
    "Batticaloa",
    "Ampara",
    "Kurunegala",
    "Puttalam",
    "Anuradhapura",
    "Polonnaruwa",
    "Badulla",
    "Monaragala",
    "Ratnapura",
    "Kegalle",
  ];

  Map<String, List<String>> districtCities = {
    "Colombo": ["Colombo", "Dehiwala", "Moratuwa"],
    "Gampaha": ["Gampaha", "Negombo", "Kelaniya"],
    "Kandy": ["Kandy", "Katugastota", "Peradeniya"],
  };

  List<String> cities = [];

  List<String> wasteTypes = [
    "Paddy Husk & Straw",
    "Coconut Husks & Shells",
    "Tea Waste",
    "Rubber Wood & Latex Waste",
    "Fruit & Vegetable Waste",
    "Sugarcane Bagasse",
    "Oil Cake & Residues",
    "Maize & Other Cereal Residues",
    "Banana Plant Waste",
    "Other",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveDataToFirebase() async {
    if (selectedDistrict != null &&
        selectedCity != null &&
        selectedWasteType != null) {
      try {
        await _firestore.collection("agri_waste_data").add({
          "district": selectedDistrict,
          "city": selectedCity,
          "wasteType": selectedWasteType,
          "timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Data saved successfully!")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select all fields!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Agri Waste Type"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.grey[700],
                    value: selectedDistrict,
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value;
                        selectedCity = null;
                        cities = districtCities[value] ?? [];
                      });
                    },
                    items:
                        districts
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                    decoration: InputDecoration(
                      labelText: "District",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.grey[700],
                    value: selectedCity,
                    onChanged: (value) => setState(() => selectedCity = value),
                    items:
                        cities
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                    decoration: InputDecoration(
                      labelText: "City",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.grey[700],
                    value: selectedWasteType,
                    onChanged:
                        (value) => setState(() => selectedWasteType = value),
                    items:
                        wasteTypes
                            .map(
                              (w) => DropdownMenuItem(
                                value: w,
                                child: Text(
                                  w,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                    decoration: InputDecoration(
                      labelText: "Agri Waste Type",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: saveDataToFirebase,
                    child: Text("Save Data"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Filter"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                          trailing: Icon(Icons.delete, color: Colors.red),
                          onTap: () async {
                            await _firestore
                                .collection("agri_waste_data")
                                .doc(doc.id)
                                .delete();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
