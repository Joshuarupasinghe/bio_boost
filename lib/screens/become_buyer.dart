import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/buyer_auth_service.dart';

class BecomeBuyerPage extends StatefulWidget {
  const BecomeBuyerPage({super.key});

  @override
  _BecomeBuyerPageState createState() => _BecomeBuyerPageState();
}

class _BecomeBuyerPageState extends State<BecomeBuyerPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final BuyerAuthService _buyerAuthService = BuyerAuthService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false; // Class-level variable
  final _formKey = GlobalKey<FormState>(); // Add form key for validation
  String authStatus = "";

  Future<void> _registerBuyer() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Use the class-level variable
    });

    try {
      await _buyerAuthService.registerBuyer(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      
      // Registration successful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        // Navigate to home or login page
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Registration error: $e'); // Add debug print
      
      // Handle specific errors
      String errorMessage = 'Registration failed: ${e.toString()}';
      
      if (e is FirebaseAuthException) {
        if (e.code == 'username-already-in-use') {
          errorMessage = 'This username is already taken. Please choose another one.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'This username is already registered. Please try another one.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Use the class-level variable
        });
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false, bool isVisible = false, Function()? onToggle}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: onToggle,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(backgroundColor: Colors.grey[850]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(  // Wrap with Form widget
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Become a Buyer",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Create a new username to become a Buyer",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildTextField("Username", _usernameController),
                      const SizedBox(height: 15),
                      _buildTextField(
                        "Password",
                        _passwordController,
                        isPassword: true,
                        isVisible: _isPasswordVisible,
                        onToggle: () => setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        }),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        "Confirm Password",
                        _confirmPasswordController,
                        isPassword: true,
                        isVisible: _isConfirmPasswordVisible,
                        onToggle: () => setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        }),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _registerBuyer,  // Disable when loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)  // Show loading indicator
                            : const Text(
                                "Become a Buyer",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}