import 'package:bio_boost/screens/become_seller.dart';
import 'package:bio_boost/screens/wishlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final CompanyProfileService _profileService = CompanyProfileService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  UserModel? _userProfile;
  List<WantedSale> _userWants = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _retryCount = 0;
  final int _maxRetries = 2;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Manually check if user document exists and create if not
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        
        if (!userDoc.exists) {
          print("User document does not exist, creating default...");
          // Create default user document
          await _firestore.collection('users').doc(currentUser.uid).set({
            'uid': currentUser.uid,
            'firstName': 'Default',
            'lastName': 'User',
            'email': currentUser.email ?? 'no-email@example.com',
            'companyName': 'Default Company',
            'phone': '1234567890',
            'address': 'Default Address',
            'district': 'Default District',
            'city': 'Default City',
            'role': 'buyer',
          });
        }
      }
      
      // Listen for user profile changes
      _profileService.getUserProfile().listen(
        (profile) {
          if (mounted) {
            setState(() {
              _userProfile = profile;
              _isLoading = false;
              _errorMessage = null;
            });
          }
        },
        onError: (error) {
          print("Error in user profile stream: $error");
          if (mounted) {
            setState(() {
              _errorMessage = "Error loading profile data: $error";
              _isLoading = false;
            });
          }
          
          // Auto-retry a few times
          if (_retryCount < _maxRetries) {
            _retryCount++;
            Future.delayed(Duration(seconds: 2), _loadUserData);
          }
        },
      );

      // Listen for user wants changes
      _profileService.getUserWants().listen(
        (wants) {
          if (mounted) {
            setState(() {
              _userWants = wants;
            });
          }
        },
        onError: (error) {
          print("Error in user wants stream: $error");
        },
      );
    } catch (e) {
      print("Error in loadUserData: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Use the service method for a more reliable reset
      bool success = await _profileService.resetProfile(
        customEmail: _auth.currentUser?.email
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile has been reset successfully"))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to reset profile. Please try again."))
        );
      }
      
      _loadUserData();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error resetting profile: $e";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );
    }
  }

  String _getFullName() {
    if (_userProfile == null) return '';
    return '${_userProfile!.firstName} ${_userProfile!.lastName}';
  }

  String _getLocation() {
    if (_userProfile == null) return '';
    return '${_userProfile!.city}, ${_userProfile!.district}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Loading profile data..."),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserData,
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 20),
              Text(
                "Error loading profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_errorMessage!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserData,
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                _userProfile?.companyName ?? "Company Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCompanyProfilePage(userProfile: _userProfile),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Text('Edit Profile'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WishlistPage()),
                      );
                    },
                    child: Text("My Wishlist"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getFullName(), style: TextStyle(fontSize: 20)),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.location_pin),
                          SizedBox(width: 5),
                          Text(
                            _getLocation(),
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.call),
                          SizedBox(width: 5),
                          Text(_userProfile?.phone ?? "No phone", style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.email),
                          SizedBox(width: 5),
                          Text(
                            _userProfile?.email ?? "No email",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BecomeSellerPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text("Become a Seller"),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Wants",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddWantScreen()),
                      );
                    },
                    icon: Icon(Icons.add),
                    label: Text("Add Want"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _userWants.isEmpty
                  ? Text("You haven't added any wants yet", style: TextStyle(color: Colors.white70))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _userWants.length,
                      itemBuilder: (context, index) {
                        final want = _userWants[index];
                        return _buildWantedCard(
                          agriWasteType: want.name,
                          name: _getFullName(),
                          location: want.location,
                          weight: "${want.weight}kg",
                          description: want.description,
                          onDelete: () async {
                            await _profileService.deleteUserWant(want.id);
                          },
                        );
                      },
                    ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInPage()),
                        (route) => false, // Remove all routes
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: Text("Logout", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWantedCard({
    required String agriWasteType,
    required String name,
    required String location,
    required String weight,
    required String description,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),

          // Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Needs $agriWasteType",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text("Name: $name", style: TextStyle(color: Colors.white)),
                Text(
                  "Location: $location",
                  style: TextStyle(color: Colors.white),
                ),
                Text("Weight: $weight", style: TextStyle(color: Colors.white)),
                Text(description, style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // Delete Icon
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class EditCompanyProfilePage extends StatefulWidget {
  final UserModel? userProfile;

  const EditCompanyProfilePage({super.key, this.userProfile});

  @override
  State<EditCompanyProfilePage> createState() => _EditCompanyProfilePageState();
}

class _EditCompanyProfilePageState extends State<EditCompanyProfilePage> {
  final CompanyProfileService _profileService = CompanyProfileService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _companyNameController;
  
  String? _selectedCity;
  String? _selectedDistrict;
  bool _isLoading = false;
  
  final List<String> _locations = ['Colombo', 'Pitipana', 'Kandy', 'Galle', 'Jaffna'];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.userProfile?.firstName ?? 'Default');
    _lastNameController = TextEditingController(text: widget.userProfile?.lastName ?? 'User');
    _phoneController = TextEditingController(text: widget.userProfile?.phone ?? '1234567890');
    _companyNameController = TextEditingController(text: widget.userProfile?.companyName ?? 'Default Company');
    _selectedCity = widget.userProfile?.city ?? _locations.first;
    _selectedDistrict = widget.userProfile?.district ?? _locations.last;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final success = await _profileService.updateUserProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      city: _selectedCity,
      district: _selectedDistrict,
      companyName: _companyNameController.text,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (success) {
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context);
    } else {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.grey[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[400],
                        child: Icon(Icons.edit, size: 30),
                      ),
                    ),
                    SizedBox(height: 10),
                    // User Name
                    Center(
                      child: Text(
                        widget.userProfile?.companyName ?? 'Company Name',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Company Name Field
                    Text('Company Name'),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: InputDecoration(
                        labelText: 'Company Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter company name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    
                    // Name Fields
                    Text('Name'),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // Location Dropdowns
                    Text('Location'),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      items: _locations
                          .map(
                            (location) => DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'City',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      items: _locations
                          .map(
                            (location) => DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedDistrict = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'District',
                      ),
                    ),
                    SizedBox(height: 10),
                    // Contact Fields
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Update Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text('Update Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
