import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class MyProfileEdit extends StatefulWidget {
  @override
  _MyProfileEditState createState() => _MyProfileEditState();
}

class _MyProfileEditState extends State<MyProfileEdit> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final picker = ImagePicker();

  File? _profileImage;
  String? _downloadUrl;

  // Controllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String selectedDistrict = "Colombo";
  String selectedCity = "Nugegoda";

  final List<String> districts = ["Colombo", "Gampaha", "Kandy"];
  final List<String> cities = ["Nugegoda", "Galle", "Kandy"];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          firstNameController.text = data['firstName'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          contactController.text = data['contactNumber'] ?? '';
          emailController.text = data['email'] ?? '';
          selectedDistrict = data['district'] ?? 'Colombo';
          selectedCity = data['city'] ?? 'Nugegoda';
          _downloadUrl = data['profileImagePath'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String userId = _auth.currentUser!.uid;
      Reference ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print("❌ Error uploading image: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("❌ User not signed in!");
        return;
      }

      String? imageUrl = _downloadUrl;
      if (_profileImage != null) {
        print("📸 Uploading profile image...");
        imageUrl = await _uploadImage(_profileImage!);
      }

      Map<String, dynamic> userProfile = {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'contactNumber': contactController.text,
        'email': emailController.text,
        'district': selectedDistrict,
        'city': selectedCity,
        'profileImagePath': imageUrl,
      };

      print("📤 Saving profile data...");
      await _firestore.collection('users').doc(user.uid).set(userProfile);
      print("✅ Profile updated successfully!");
    } catch (e) {
      print("❌ Error saving profile: $e");
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
                            : (_downloadUrl != null
                                    ? NetworkImage(_downloadUrl!)
                                    : null)
                                as ImageProvider?,
                    child:
                        _profileImage == null && _downloadUrl == null
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

            // User Fields
            _buildTextField(firstNameController, "First Name"),
            _buildTextField(lastNameController, "Last Name"),
            _buildTextField(contactController, "Contact Number"),
            _buildTextField(emailController, "Email (Optional)"),

            // Location
            _buildDropdown("District", districts, selectedDistrict, (newValue) {
              setState(() {
                selectedDistrict = newValue!;
              });
            }),
            _buildDropdown("City", cities, selectedCity, (newValue) {
              setState(() {
                selectedCity = newValue!;
              });
            }),

            SizedBox(height: 20),
            // Update Button
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String selectedItem,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
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
      ),
    );
  }
}
