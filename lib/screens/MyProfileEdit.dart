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
  File? _profileImage;
  final picker = ImagePicker();
  // Initialize the seller profile service
  final SellerProfileService _profileService = SellerProfileService();
  bool _isLoading = true;

  // Controllers for text fields
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // Dropdown values
  String selectedDistrict = "Colombo";
  String selectedCity = "Nugegoda";

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
        });
      }
    } catch (e) {
      print("Error loading profile data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
    "Puthukkudiyiruppu",
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
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.grey[850],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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
                  onPressed: _updateProfile,  // Change this line to call your method
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

  Future<void> _updateProfile() async {
    final success = await _profileService.updateSellerProfile(
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
        SnackBar(content: Text('Profile updated successfully'))
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile'))
      );
    }
  }
}
