import 'package:bio_boost/screens/become_seller.dart';
import 'package:bio_boost/screens/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:bio_boost/services/company_profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  _CompanyProfilePageState createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final CompanyProfileService _profileService = CompanyProfileService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _profileService.getCompanyProfile();
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        
        final imageUrl = await _profileService.uploadProfileImage(image.path);
        await _profileService.updateCompanyProfile({'profileImage': imageUrl});
        await _loadProfileData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated successfully'))
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile image: ${e.toString()}'))
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfileData,
                    child: Text('Retry')
                  )
                ]
              )
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 30),
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.black,
                  backgroundImage: _profileData?['profileImage'] != null
                      ? NetworkImage(_profileData!['profileImage'])
                      : null,
                  child: _profileData?['profileImage'] == null
                      ? Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              Text(
                _profileData?['username'] ?? 'Loading...',
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
                          builder: (context) => EditCompanyProfilePage(),
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
                      Text(_profileData?['fullName'] ?? 'Not set', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.location_pin),
                          SizedBox(width: 5),
                          Text(
                            "${_profileData?['location'] ?? 'Not set'}, ${_profileData?['city'] ?? ''}",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.call),
                          SizedBox(width: 5),
                          Text(_profileData?['phone'] ?? 'Not set', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.email),
                          SizedBox(width: 5),
                          Text(
                            _profileData?['email'] ?? 'Not set',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ), // Remove duplicate email Row
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
              Text(
                "My Wants",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: _profileService.getWantedItemsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final items = snapshot.data?.docs ?? [];
                  
                  if (items.isEmpty) {
                    return Text('No wanted items yet');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index].data() as Map<String, dynamic>;
                      return _buildWantedCard(
                        agriWasteType: item['agriWasteType'] ?? '',
                        name: item['name'] ?? '',
                        location: item['location'] ?? '',
                        weight: '${item['weight']}kg',
                        description: item['description'] ?? '',
                        onDelete: () async {
                          await _profileService.deleteWantedItem(items[index].id);
                        },
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Add logout functionality
                  Navigator.pop(context); // Example logout action
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: Text("Logout"),
              ),
                  ],
                ),
              ),
            )
    );
  }

  Widget _buildWantedCard({
    required Function onDelete,
    required String agriWasteType,
    required String name,
    required String location,
    required String weight,
    required String description,
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

          // Call Icon
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => onDelete(),
          ),
        ],
      ),
    );
  }
}

class EditCompanyProfilePage extends StatefulWidget {
  final List<String> locations = ['Colombo', 'Pitipana'];

  EditCompanyProfilePage({super.key});

  @override
  _EditCompanyProfilePageState createState() => _EditCompanyProfilePageState();
}

class _EditCompanyProfilePageState extends State<EditCompanyProfilePage> {
  final CompanyProfileService _profileService = CompanyProfileService();
  final _formKey = GlobalKey<FormState>();
  
  String? selectedCity;
  String? selectedArea;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedCity = widget.locations.first;
    selectedArea = widget.locations.last;
    _firstNameController = TextEditingController();    
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() => _isLoading = true);
      final profileData = await _profileService.getCompanyProfile();
      if (profileData != null) {
        setState(() {
          final names = (profileData['fullName'] ?? '').split(' ');
          _firstNameController.text = names.first;
          _lastNameController.text = names.length > 1 ? names.last : '';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);
      
      await _profileService.updateCompanyProfile({
        'fullName': '${_firstNameController.text} ${_lastNameController.text}'.trim(),
        'phone': _phoneController.text,
        'email': _emailController.text,
        'city': selectedCity,
        'location': selectedArea,
      }).then((success) {
        if (success) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.grey[800],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
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
                        'ishara2003',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Name Fields
                    Text('Name'),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter first name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Enter last name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // Location Dropdowns
                    Text('Location'),
                    DropdownButtonFormField<String>(
                      value: selectedCity,
                      items: widget.locations
                          .map((location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: (String? value) {
                        setState(() => selectedCity = value);
                      },
                      decoration: InputDecoration(labelText: 'City'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedArea,
                      items: widget.locations
                          .map((location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: (String? value) {
                        setState(() => selectedArea = value);
                      },
                      decoration: InputDecoration(labelText: 'Area'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an area';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // Contact Fields
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        hintText: 'Enter phone number',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter email address',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Update Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      child: _isLoading ? CircularProgressIndicator() : Text('Update'),
                    ),
                  ],
                ),
              ),
            )
    );
  }
}
