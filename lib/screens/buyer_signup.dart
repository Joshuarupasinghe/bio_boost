import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class BuyerSignupPage extends StatefulWidget {
  const BuyerSignupPage({super.key});

  @override
  _BuyerSignupPageState createState() => _BuyerSignupPageState();
}

class _BuyerSignupPageState extends State<BuyerSignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signupAsBuyer() async {
    // Hide any previous error
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validate inputs
    String username = _usernameController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a username";
        _isLoading = false;
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a password";
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match";
        _isLoading = false;
      });
      return;
    }

    try {
      // Create email from username if it doesn't contain @ symbol
      String email = username.contains('@') ? username : '$username@buyer.bioboost.com';

      // Create user account in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create buyer profile in Firestore
      Map<String, dynamic> userData = {
        'uid': userCredential.user!.uid,
        'username': username,
        'email': email,
        'role': 'Buyer',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to buyers collection
      await _firestore.collection('buyers').doc(userCredential.user!.uid).set(userData);
      
      // Also save to users collection for consistency
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);

      // Navigate to home page after successful signup
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userRole: 'Buyer')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error creating account: ${e.toString()}";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Become a buyer signup'),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Become a Buyer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create a new username to become a Buyer',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                      
                    // Username field
                    _buildTextField(
                      label: 'Username',
                      controller: _usernameController,
                    ),
                    SizedBox(height: 12),
                    
                    // Password field
                    _buildTextField(
                      label: 'Password',
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    SizedBox(height: 12),
                    
                    // Confirm Password field
                    _buildTextField(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      isPassword: true,
                    ),
                    SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signupAsBuyer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text('Become a Buyer'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
} 