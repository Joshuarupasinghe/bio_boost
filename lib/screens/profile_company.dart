import 'package:bio_boost/screens/become_seller.dart';
import 'package:bio_boost/screens/wishlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/wanted_sales_model.dart';
import '../services/company_profile_service.dart';
import 'add_want.dart';

import 'sign_in.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  _CompanyProfilePageState createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userData = doc.data();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
        ),
      );
    }

    if (userData == null) {
      return const Center(
        child: Text(
          'Error loading profile. Please try again.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    print('Current user role: ${userData!['role']}');

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: Colors.teal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.black,
                  child: Text(
                    (userData!['firstName']?[0] ?? '').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "${userData!['firstName']} ${userData!['lastName']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditCompanyProfilePage(),
                          ),
                        );
                        if (result == true) {
                          _loadUserData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WishlistPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("My Wishlist"),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.business, userData!['companyName'] ?? 'N/A'),
                      const SizedBox(height: 15),
                      _buildInfoRow(
                        Icons.location_pin,
                        "${userData!['city']}, ${userData!['district']}",
                      ),
                      const SizedBox(height: 15),
                      _buildInfoRow(Icons.call, userData!['phoneNumber'] ?? 'N/A'),
                      const SizedBox(height: 15),
                      _buildInfoRow(Icons.email, userData!['email'] ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (userData!['role'] == 'Buyer')
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BecomeSellerPage(),
                        ),
                      ).then((result) async {
                        if (result != null && result is Map<String, dynamic> && result['success'] == true) {
                          // Reload user data
                          await _loadUserData();
                          
                          if (!mounted) return;

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Successfully became a seller!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Navigate to home
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                            arguments: {'userRole': 'Seller'},
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Become a Seller",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class EditCompanyProfilePage extends StatefulWidget {
  const EditCompanyProfilePage({super.key});

  @override
  _EditCompanyProfilePageState createState() => _EditCompanyProfilePageState();
}

class _EditCompanyProfilePageState extends State<EditCompanyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  String? selectedProvince;
  String? selectedDistrict;
  bool isLoading = true;
  Map<String, dynamic>? userData;

  // Province and District Data
  final Map<String, List<String>> provinceDistricts = {
    'Western Province': ['Colombo', 'Gampaha', 'Kalutara'],
    'Central Province': ['Kandy', 'Matale', 'Nuwara Eliya'],
    'Southern Province': ['Galle', 'Matara', 'Hambantota'],
    'Northern Province': ['Jaffna', 'Kilinochchi', 'Mannar', 'Mullaitivu', 'Vavuniya'],
    'Eastern Province': ['Trincomalee', 'Batticaloa', 'Ampara'],
    'North Western Province': ['Kurunegala', 'Puttalam'],
    'North Central Province': ['Anuradhapura', 'Polonnaruwa'],
    'Uva Province': ['Badulla', 'Monaragala'],
    'Sabaragamuwa Province': ['Ratnapura', 'Kegalle']
  };

  // Find province for a given district
  String? findProvinceForDistrict(String district) {
    for (var entry in provinceDistricts.entries) {
      if (entry.value.contains(district)) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            userData = data;
            firstNameController.text = data['firstName'] ?? '';
            lastNameController.text = data['lastName'] ?? '';
            phoneNumberController.text = data['phoneNumber'] ?? '';
            emailController.text = data['email'] ?? '';
            addressController.text = data['address'] ?? '';
            
            // Load province and district
            String? storedDistrict = data['district'] as String?;
            String? storedCity = data['city'] as String?;
            
            if (storedCity != null) {
              // Find the province that contains the stored city
              for (var entry in provinceDistricts.entries) {
                if (entry.value.contains(storedCity)) {
                  selectedProvince = entry.key;
                  selectedDistrict = storedCity;
                  break;
                }
              }
            }
            
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (firstNameController.text.isEmpty || 
        lastNameController.text.isEmpty || 
        phoneNumberController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedProvince == null ||
        selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final Map<String, dynamic> updateData = {
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'phoneNumber': phoneNumberController.text.trim(),
          'address': addressController.text.trim(),
          'district': selectedProvince,
          'city': selectedDistrict,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).update(updateData);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.grey[850],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[800],
                child: Text(
                  (firstNameController.text.isNotEmpty ? firstNameController.text[0] : '').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField('First Name', firstNameController),
            const SizedBox(height: 15),
            _buildTextField('Last Name', lastNameController),
            const SizedBox(height: 15),
            _buildTextField('Phone Number', phoneNumberController),
            const SizedBox(height: 15),
            _buildTextField('Address', addressController),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedProvince,
                  isExpanded: true,
                  dropdownColor: Colors.grey[850],
                  hint: const Text('Select Province', style: TextStyle(color: Colors.white70)),
                  style: const TextStyle(color: Colors.white),
                  items: provinceDistricts.keys.map((String province) {
                    return DropdownMenuItem<String>(
                      value: province,
                      child: Text(province),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedProvince = newValue;
                      selectedDistrict = null;  // Reset district when province changes
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDistrict,
                  isExpanded: true,
                  dropdownColor: Colors.grey[850],
                  hint: const Text('Select District', style: TextStyle(color: Colors.white70)),
                  style: const TextStyle(color: Colors.white),
                  items: selectedProvince != null
                      ? provinceDistricts[selectedProvince]!.map((String district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          );
                        }).toList()
                      : <DropdownMenuItem<String>>[],
                  onChanged: selectedProvince == null ? null : (String? newValue) {
                    setState(() {
                      selectedDistrict = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Profile',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        filled: true,
        fillColor: Colors.grey[850],
      ),
    );
  }
}
