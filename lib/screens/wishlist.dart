import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bio_boost/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> _wishlist = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final SalesService _salesService = SalesService();
  String? _currentUserId;
  bool _isLoading = true;
  String? _errorMessage;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
    _checkUserRole();
    _loadCurrentUser();
  }

  Future<void> _checkUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? role = await _authService.getUserRole(user.uid);
        setState(() {
          _userRole = role;
          _isLoading = false;
        });

        if (role != 'Buyer') {
          setState(() {
            _errorMessage = 'You do not have permission to access this page.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No user is signed in.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to check user role: $e';
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('currentUserId') ?? 'defaultUser';
    });
  }

  Future<void> _loadWishlist() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> wishlist = prefs.getStringList('wishlist') ?? [];

      setState(() {
        _wishlist =
            wishlist.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load wishlist: $e';
      });
    }
  }

  Future<void> _removeFromWishlist(int index) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> wishlist = prefs.getStringList('wishlist') ?? [];

      wishlist.removeAt(index);
      await prefs.setStringList('wishlist', wishlist);

      setState(() {
        _wishlist.removeAt(index);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to remove item from wishlist: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text(
            "My Wishlist",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_userRole != 'Buyer') {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text(
            "Access Denied",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            "You do not have permission to access this page.",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("My Wishlist", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _wishlist.isEmpty
            ? const Center(
                child: Text(
                  "No items in Wishlist",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              )
            : ListView.builder(
                itemCount: _wishlist.length,
                itemBuilder: (context, index) {
                  final item = _wishlist[index];
                  return _buildWishlistCard(item, index);
                },
              ),
      ),
    );
  }

  Widget _buildWishlistCard(Map<String, dynamic> item, int index) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: item['image'] != null && item['image'].toString().isNotEmpty
                            ? DecorationImage(
                                image: FileImage(File(item['image'])),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.black,
                      ),
                      child: item['image'] == null || item['image'].toString().isEmpty
                          ? const Center(
                              child: Text(
                                "No Image",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Owner: ${item['owner']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Location: ${item['location']}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Weight: ${item['weight']}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Type: ${item['type']}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        // Call Button
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.white),
                          onPressed: () {}, // Implement call functionality
                        ),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFromWishlist(index),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
