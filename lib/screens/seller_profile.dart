import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'active_sales.dart';
import 'MyProfileEdit.dart';
import 'sign_In.dart';
import '../services/seller_profile_service.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final SellerProfileService _profileService = SellerProfileService();
  bool _isLoading = true;
  String _username = 'UserName';
  String _fullName = '';
  String _location = '';
  String _contactNumber = '';
  String _email = '';
  String _profileImageUrl = '';

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
      _username = await _profileService.getSellerUsername();
      _fullName = await _profileService.getSellerFullName();
      _location = await _profileService.getSellerLocation();
      _contactNumber = await _profileService.getSellerContactNumber();
      _email = await _profileService.getSellerEmail();
      _profileImageUrl = await _profileService.getProfileImageUrl();
    } catch (e) {
      print('Error loading profile data: $e');
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
        title: Text('My Profile - Sales Panel'),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.black,
                      backgroundImage: _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : null,
                      child: _profileImageUrl.isEmpty
                          ? Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    SizedBox(height: 20),
                    Text(
                      _username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyProfileEdit()),
                          );
                          // Refresh profile data when returning from edit screen
                          _loadProfileData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text("Edit Profile"),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fullName,
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(Icons.location_pin, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  "My Location",
                                  style: TextStyle(
                                    fontSize: 16, 
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text(
                                _location,
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(Icons.call, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  "My Contact Number",
                                  style: TextStyle(
                                    fontSize: 16, 
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text(
                                _contactNumber,
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(Icons.email, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  "Email",
                                  style: TextStyle(
                                    fontSize: 16, 
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text(
                                _email,
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ActiveSales()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: const Text(
                          "Active Sales (BTN)",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        await _profileService.signOut();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInPage()),
                          (route) => false, // Remove all routes
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text("Logout", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
