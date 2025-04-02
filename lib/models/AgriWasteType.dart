import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgriWasteTypePage extends StatefulWidget {
  const AgriWasteTypePage({super.key});

  @override
  _AgriWasteTypePageState createState() => _AgriWasteTypePageState();
}

class _AgriWasteTypePageState extends State<AgriWasteTypePage> {
  String? selectedDistrict;
  String? selectedCity;
  String? selectedWasteType;

  List<String> districts = [];
  List<String> cities = [];
  List<String> wasteTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchDistricts();
    _fetchWasteTypes();
  }

  // Fetch districts from backend
  _fetchDistricts() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/districts'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        districts = List<String>.from(data['districts']);
      });
    }
  }

  // Fetch waste types from backend
  _fetchWasteTypes() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/waste-types'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        wasteTypes = List<String>.from(data['waste_types']);
      });
    }
  }

  // Fetch cities based on selected district
  _fetchCities(String district) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/cities/$district'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        cities = List<String>.from(data['cities']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agri Waste Type')),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                  selectedCity = null;
                  cities = [];
                });
                _fetchCities(value!);
              },
              items:
                  districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
              decoration: InputDecoration(labelText: 'District'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCity,
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                });
              },
              items:
                  cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
              decoration: InputDecoration(labelText: 'City'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedWasteType,
              onChanged: (value) {
                setState(() {
                  selectedWasteType = value;
                });
              },
              items:
                  wasteTypes.map((wasteType) {
                    return DropdownMenuItem(
                      value: wasteType,
                      child: Text(wasteType),
                    );
                  }).toList(),
              decoration: InputDecoration(labelText: 'Agri Waste Type'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text('Filter')),
          ],
        ),
      ),
    );
  }
}
