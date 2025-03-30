import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyProfileEdit extends StatefulWidget {
  @override
  _MyProfileEditState createState() => _MyProfileEditState();
}

class _MyProfileEditState extends State<MyProfileEdit> {
  File? _profileImage;
  final picker = ImagePicker();

  // Controllers for text fields
  TextEditingController firstNameController = TextEditingController(
    text: "Nimal",
  );
  TextEditingController lastNameController = TextEditingController(
    text: "Gunawardhana",
  );
  TextEditingController contactController = TextEditingController(
    text: "077 xxxxxxx",
  );
  TextEditingController emailController = TextEditingController();

  // Dropdown values
  String selectedDistrict = "Colombo";
  String selectedCity = "Nugegoda";

  final List<String> districts = ["Colombo", "Gampaha", "Kandy", "Galle"];
  final List<String> cities = [
    "Nugegoda",
    "Dehiwala",
    "Maharagama",
    "Battaramulla",
  ];

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[700],
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                    child:
                        _profileImage == null
                            ? Icon(Icons.person, color: Colors.white, size: 50)
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Username Placeholder
            Text(
              "UserName",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            // Name Fields
            _buildSectionTitle("Name"),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(firstNameController, "First Name"),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(lastNameController, "Last Name"),
                ),
              ],
            ),

            SizedBox(height: 15),

            // Location Fields
            _buildSectionTitle("Location"),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    "District",
                    districts,
                    selectedDistrict,
                    (newValue) {
                      setState(() {
                        selectedDistrict = newValue!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown("City", cities, selectedCity, (
                    newValue,
                  ) {
                    setState(() {
                      selectedCity = newValue!;
                    });
                  }),
                ),
              ],
            ),

            SizedBox(height: 15),

            // Contact Number
            _buildSectionTitle("Contact Number"),
            _buildTextField(contactController, "077 xxxxxxx"),

            SizedBox(height: 15),

            // Optional Email
            _buildSectionTitle("Add New Email (Optional)"),
            _buildTextField(emailController, "Enter your email"),

            SizedBox(height: 20),

            // Update Button
            ElevatedButton(
              onPressed: () {
                // Save Profile Logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for text fields
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Widget for dropdown fields
  Widget _buildDropdown(
    String label,
    List<String> items,
    String selectedItem,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedItem,
      dropdownColor: Colors.grey[800],
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items:
          items.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: onChanged,
    );
  }

  // Widget for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
