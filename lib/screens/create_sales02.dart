import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/sales_model.dart';
import '../services/sales_service.dart';
import 'package:bio_boost/services/user_service.dart';

class CreateSales02 extends StatefulWidget {
  final String wasteType;
  final SalesService salesService = SalesService();

  CreateSales02({super.key, required this.wasteType});

  @override
  State<CreateSales02> createState() => _CreateSales02State();
}

class _CreateSales02State extends State<CreateSales02> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  // List to hold the local paths of selected images
  List<String> imagePaths = [];
  // List to hold selected image files
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUserName();
    loadLocation();
  }

  void loadUserName() async {
    String fullName = await UserService().getCurrentUserFullName();
    setState(() {
      ownerNameController.text = fullName;
    });
  }

  void loadLocation() async {
    String location = await UserService().getCurrentUserLocation();
    setState(() {
      locationController.text = location;
    });
  }

  // Method to pick images from gallery
  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages = images;
        // Instead of uploading, save the local path of each image
        imagePaths = images.map((image) => image.path).toList();
      });
    }
  }

  Future<void> _createSale() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create a sale')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final newSale = Sales(
      id: '', // Firestore will generate an ID
      ownerId: user.uid,
      ownerName: ownerNameController.text,
      location: locationController.text,
      weight: double.tryParse(weightController.text) ?? 0,
      type: widget.wasteType,
      address: addressController.text,
      contactNumber: contactController.text,
      price: double.tryParse(priceController.text) ?? 0,
      description: descriptionController.text,
      imageUrls: imagePaths, // Using local image paths
      isActive: true,
      isInWishlist: false,
      rating: null,
      postedDate: DateTime.now(),
    );

    try {
      await widget.salesService.addSale(newSale);
      Navigator.pop(context); // Return after successful creation
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating sale: $e')));
    }
  }

  @override
  void dispose() {
    ownerNameController.dispose();
    locationController.dispose();
    weightController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Create ${widget.wasteType} Sale'),
        backgroundColor: Colors.grey[850],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: ownerNameController,
                label: 'Owner Name',
                isRequired: true,
              ),
              _buildTextField(
                controller: locationController,
                label: 'Location',
                isRequired: true,
              ),
              _buildTextField(
                controller: weightController,
                label: 'Weight (kg)',
                isNumber: true,
                isRequired: true,
              ),
              _buildTextField(
                controller: priceController,
                label: 'Price',
                isNumber: true,
                isRequired: true,
              ),
              _buildTextField(
                controller: addressController,
                label: 'Address',
                isRequired: true,
              ),
              _buildTextField(
                controller: contactController,
                label: 'Contact Number',
                isRequired: true,
              ),
              _buildTextField(
                controller: descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              // Button to pick images
              ElevatedButton(
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Add Images',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              // Display selected images as thumbnails
              _selectedImages.isNotEmpty
                  ? SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Create Sale',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal),
          ),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: isRequired
            ? (value) => value == null || value.isEmpty ? 'Required' : null
            : null,
        maxLines: maxLines,
      ),
    );
  }
}
