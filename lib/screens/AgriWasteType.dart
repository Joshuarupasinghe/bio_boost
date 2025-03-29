import 'package:flutter/material.dart';

class AgriWasteTypePage extends StatefulWidget {
  @override
  _AgriWasteTypePageState createState() => _AgriWasteTypePageState();
}

class _AgriWasteTypePageState extends State<AgriWasteTypePage> {
  String? selectedDistrict;
  String? selectedCity;
  String? selectedWasteType;

  List<String> districts = ["District 1", "District 2", "District 3"];
  List<String> cities = ["City A", "City B", "City C"];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Background color of the page
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // District & City Filter Section
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // District Dropdown
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.grey[700],
                    value: selectedDistrict,
                    onChanged:
                        (value) => setState(() => selectedDistrict = value),
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

                  // City Dropdown
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

                  // Filter Button
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Filter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Agri Waste Type Dropdown
            DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[700],
              value: selectedWasteType,
              onChanged: (value) => setState(() => selectedWasteType = value),
              items:
                  wasteTypes
                      .map(
                        (w) => DropdownMenuItem(
                          value: w,
                          child: Text(w, style: TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
              decoration: InputDecoration(
                labelText: "Agri Waste Type",
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),

            SizedBox(height: 10),

            // Waste Items List
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Change this based on data
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey,
                        child: Center(
                          child: Text(
                            "Image",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      title: Text(
                        "Owner: xxxxxxxxxx",
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Location: XYZ",
                            style: TextStyle(color: Colors.white54),
                          ),
                          Text(
                            "Type: Type X",
                            style: TextStyle(color: Colors.white54),
                          ),
                          Text(
                            "Weight: 20kg",
                            style: TextStyle(color: Colors.white54),
                          ),
                          Text(
                            "Price: \$XX",
                            style: TextStyle(color: Colors.white54),
                          ),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < 2 ? Icons.star : Icons.star_border,
                                color: Colors.yellow,
                                size: 20,
                              );
                            }),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.phone, color: Colors.white),
                    ),
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
