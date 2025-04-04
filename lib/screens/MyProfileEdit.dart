import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../services/seller_profile_service.dart';

class MyProfileEdit extends StatefulWidget {
  const MyProfileEdit({super.key});

  @override
  _MyProfileEditState createState() => _MyProfileEditState();
}

class _MyProfileEditState extends State<MyProfileEdit> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final picker = ImagePicker();
  final SellerProfileService _profileService = SellerProfileService();
  bool _isLoading = true;

  File? _profileImage;
  String? _downloadUrl;

  // Controllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String selectedDistrict = "Colombo";
  String selectedCity = "Nugegoda";

  final List<String> districts = [
    "Colombo",
    "Dehiwala-Mount Lavinia",
    "Sri Jayawardenepura Kotte",
    "Moratuwa",
    "Kolonnawa",
    "Ratmalana",
    "Nugegoda",
    "Maharagama",
    "Kotikawatta",
    "Gampaha",
    "Negombo",
    "Kelaniya",
    "Kadawatha",
    "Minuwangoda",
    "Kiribathgoda",
    "Ja-Ela",
    "Wattala",
    "Biyagama",
    "Kalutara",
    "Panadura",
    "Horana",
    "Matugama",
    "Beruwala",
    "Aluthgama",
    "Bandaragama",
    "Ingiriya",
    "Bulathsinhala",
    "Kandy",
    "Katugastota",
    "Peradeniya",
    "Gampola",
    "Kundasale",
    "Kadugannawa",
    "Nawalapitiya",
    "Pilimatalawa",
    "Akurana",
    "Matale",
    "Dambulla",
    "Sigiriya",
    "Rattota",
    "Galewela",
    "Palapathwela",
    "Naula",
    "Ukuwela",
    "Nuwara Eliya",
    "Hatton",
    "Talawakelle",
    "Ginigathena",
    "Kandapola",
    "Maskeliya",
    "Kotagala",
    "Agarapatana",
    "Galle",
    "Ambalangoda",
    "Hikkaduwa",
    "Elpitiya",
    "Baddegama",
    "Udugama",
    "Ahangama",
    "Karapitiya",
    "Matara",
    "Weligama",
    "Dikwella",
    "Akuressa",
  ];
  final List<String> cities = [
    "Agarapatana",
    "Ahangama",
    "Akkaraipattu",
    "Akurana",
    "Aluthgama",
    "Ambalangoda",
    "Ambalantota",
    "Anuradhapura",
    "Akuressa",
    "Baddegama",
    "Badulla",
    "Bakamuna",
    "Balangoda",
    "Bandaragama",
    "Bandarawela",
    "Batticaloa",
    "Beliatte",
    "Beruwala",
    "Bibile",
    "Biyagama",
    "Bulathsinhala",
    "Buttala",
    "Chavakachcheri",
    "Cheddikulam",
    "Chilaw",
    "Chunnakam",
    "Colombo",
    "Dambulla",
    "Dankotuwa",
    "Dehiwala-Mount Lavinia",
    "Dickwella",
    "Dikwella",
    "Eravur",
    "Elpitiya",
    "Embilipitiya",
    "Galewela",
    "Galle",
    "Gampaha",
    "Gampola",
    "Ginigathena",
    "Hakmana",
    "Hambantota",
    "Haputale",
    "Hatton",
    "Hikkaduwa",
    "Hingurakgoda",
    "Horana",
    "Ingiriya",
    "Iranamadu",
    "Ja-Ela",
    "Jaffna",
    "Kadawatha",
    "Kadugannawa",
    "Kaduruwela",
    "Kalkudah",
    "Kalmunai",
    "Kalutara",
    "Kamburupitiya",
    "Kandapola",
    "Kandy",
    "Karainagar",
    "Karapitiya",
    "Katugastota",
    "Kegalle",
    "Kekirawa",
    "Kelaniya",
    "Kilinochchi",
    "Kinniya",
    "Kiribathgoda",
    "Kolonnawa",
    "Kopay",
    "Kotagala",
    "Kotikawatta",
    "Kuliyapitiya",
    "Kundasale",
    "Kurunegala",
    "Madhu",
    "Maharagama",
    "Mannar",
    "Maskeliya",
    "Matale",
    "Matara",
    "Matugama",
    "Mawanella",
    "Medawachchiya",
    "Mihintale",
    "Minuwangoda",
    "Moratuwa",
    "Mullaitivu",
    "Muttur",
    "Nanattan",
    "Narammala",
    "Nawalapitiya",
    "Negombo",
    "Nedunkeni",
    "Nugegoda",
    "Nuwara Eliya",
    "Naula",
    "Oddusuddan",
    "Palapathwela",
    "Pallai",
    "Panadura",
    "Paranthan",
    "Pelamadulla",
    "Peradeniya",
    "Pesalai",
    "Pilimatalawa",
    "Point Pedro",
    "Polgahawela",
    "Polonnaruwa",
    "Pottuvil",
    "Puttalam",
    "Rambukkana",
    "Rattota",
    "Ratmalana",
    "Ratnapura",
    "Sigiriya",
    "Sri Jayawardenepura Kotte",
    "Talawakelle",
    "Tangalle",
    "Thihagoda",
    "Tissamaharama",
    "Trincomalee",
    "Udugama",
    "Ukuwela",
    "Valaichchenai",
    "Vavuniya",
    "Walasmulla",
    "Warakapola",
    "Wattala",
    "Weeraketiya",
    "Weligama",
    "Welimada",
    "Wellawaya",
    "Wennappuwa",
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = await _profileService.getSellerProfile();
      if (profileData != null) {
        setState(() {
          firstNameController.text = profileData['firstName'] ?? '';
          lastNameController.text = profileData['lastName'] ?? '';
          contactController.text = profileData['contact'] ?? '';
          emailController.text = profileData['email'] ?? '';
          selectedDistrict = profileData['district'] ?? 'Colombo';
          selectedCity = profileData['city'] ?? 'Nugegoda';
          _downloadUrl = profileData['profileImage'];
        });
      }
    } catch (e) {
      print('Error loading profile data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Edit Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_downloadUrl != null
                              ? NetworkImage(_downloadUrl!)
                              : null) as ImageProvider?,
                      child: (_profileImage == null && _downloadUrl == null)
                          ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: firstNameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: lastNameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: contactController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    dropdownColor: Colors.grey[850],
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'District',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                    items: districts.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCity,
                    dropdownColor: Colors.grey[850],
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'City',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                    items: cities.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
