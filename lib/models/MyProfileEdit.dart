import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class ProfileService {
  final String _storageFile = "user_profiles.json"; // Local storage file

  // Load user profile
  Future<Map<String, dynamic>?> loadProfile(String userId) async {
    try {
      final file = File(_storageFile);
      if (!await file.exists()) return null;

      String content = await file.readAsString();
      Map<String, dynamic> profiles = jsonDecode(content);

      return profiles[userId];
    } catch (e) {
      print("Error loading profile: $e");
      return null;
    }
  }

  // Save user profile
  Future<void> saveProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final file = File(_storageFile);
      Map<String, dynamic> profiles = {};

      if (await file.exists()) {
        String content = await file.readAsString();
        profiles = jsonDecode(content);
      }

      profiles[userId] = profileData;
      await file.writeAsString(jsonEncode(profiles));
    } catch (e) {
      print("Error saving profile: $e");
    }
  }

  // Upload profile image (simulate saving locally)
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      String newPath = "profile_images/$userId.jpg";
      await imageFile.copy(newPath);
      return newPath;
    } catch (e) {
      print("Error saving image: $e");
      return "";
    }
  }

  // Update profile function
  Future<void> updateProfile({
    required String userId,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController contactController,
    required TextEditingController emailController,
    required String selectedDistrict,
    required String selectedCity,
    File? profileImage,
    required BuildContext context,
  }) async {
    // Upload profile image if selected
    String? imageUrl;
    if (profileImage != null) {
      imageUrl = await uploadProfileImage(userId, profileImage);
    }

    // Save profile data
    await saveProfile(userId, {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "contact": contactController.text,
      "email": emailController.text,
      "district": selectedDistrict,
      "city": selectedCity,
      "imageUrl": imageUrl ?? '',
    });

    // Show success message
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Profile Updated Successfully")));
  }
}
