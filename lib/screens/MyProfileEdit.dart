import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/seller_profile_service.dart';

class MyProfileEdit extends StatefulWidget {
  const MyProfileEdit({super.key});

  @override
  _MyProfileEditState createState() => _MyProfileEditState();
}

class _MyProfileEditState extends State<MyProfileEdit> {
  final SellerProfileService _profileService = SellerProfileService();
  final picker = ImagePicker();
  bool _isLoading = true;
  bool _isSaving = false;

  File? _profileImage;
  String? _currentImageUrl;

  // Controllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingContfinal  contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String selectedDistrict = "Colombo";
  String selectedCity = "Nugegoda";

  final List<String> districts = [
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
    "Vavuniya",
    "Mullaitivu",
    "Batticaloa",
    "Ampara",
    "Trincomalee",
    "Kurunegala",
    "Puttalam",
    "Anuradhapura",
    "Polonnaruwa",
    "Badulla",
    "Monaragala",
    "Ratnapura",
    "Kegalle",
  ];
  
  final List<String> cities = [
    "Colombo",
    "Dehiwala",
    "Moratuwa",
    "Nugegoda",
    "Gampaha",
    "Negombo",
    "Wattala",
    "Ja-Ela",
    "Kalutara",
    "Panadura",
    "Horana",
    "Kandy",
    "Peradeniya",
    "Gampola",
    "Matale",
    "Dambulla",
    "Nuwara Eliya",
    "Hatton",
    "Galle",
    "Matara",
    "Weligama",
    "Hambantota",
    "Tangalle",
    "Jaffna",
    "Vavuniya",
    "Trincomalee",
    "Batticaloa",
    "Ampara",
    "Kalmunai",
    "Kurunegala",
    "Kuliyapitiya",
    "Puttalam",
    "Chilaw",
    "Anuradhapura",
    "Polonnaruwa",
    "Badulla",
    "Bandarawela",
    "Monaragala",
    "Ratnapura",
    "Balangoda",
    "Kegalle",
    "Mawanella",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = await _profileService.getSellerProfile();
      
      if (profileData != null) {
        firstNameController.text = profileData['firstName'] ?? '';
        lastNameController.text = profileData['lastName'] ?? '';
        contactController.text = profileData['contact'] ?? '';
        emailController.text = profileData['email'] ?? '';
        
        if (profileData['district'] != null) {
          selectedDistrict = profileData['district'];
        }
        
        if (profileData['city'] != null) {
          selectedCity = profileData['city'];
        }
        
        if (profileData['profileImage'] != null) {
          _currentImageUrl = profileData['profileImage'];
        }
      } else {
        // If no profile exists yet, use the email from Firebase Auth
        final user = _profileService.currentUser;
        if (user != null && user.email != null) {
          emailController.text = user.email!;
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      bool success = await _profileService.updateSellerProfile(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        contact: contactController.text,
        email: emailController.text,
        district: selectedDistrict,
        city: selectedCity,
        profileImage: _profileImage,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.grey[850],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.black,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : _currentImageUrl != null
                                  ? NetworkImage(_currentImageUrl!)
                                  : null,
                          child: (_profileImage == null && _currentImageUrl == null)
                              ? Icon(Icons.person, size: 70, color: Colors.white)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.teal,
                            radius: 20,
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              onPressed: _getImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'First Name',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: firstNameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter first name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Last Name',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: lastNameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter last name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Contact Number',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: contactController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter contact number',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    enabled: false, // Email cannot be changed
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'District',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedDistrict,
                      isExpanded: true,
                      dropdownColor: Colors.grey[800],
                      style: TextStyle(color: Colors.white),
                      underline: Container(),
                      items: districts.map((String district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedDistrict = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'City',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCity,
                      isExpanded: true,
                      dropdownColor: Colors.grey[800],
                      style: TextStyle(color: Colors.white),
                      underline: Container(),
                      items: cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCity = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isSaving
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
