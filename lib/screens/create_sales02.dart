import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateSales02 extends StatefulWidget {
  final String selectedCategory;

  const CreateSales02({super.key, required this.selectedCategory});

  @override
  _CreateSales02State createState() => _CreateSales02State();
}

class _CreateSales02State extends State<CreateSales02> {
  late String uid;
  late String selectedCategory;

  // Text editing controllers for the fields
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // List of categories
  final List<String> categories = [
    'Paddy Husk & Straw',
    'Coconut Husks and Shells',
    'Tea Waste',
    'Rubber Wood and Latex Waste',
    'Fruit and Vegetable Waste',
    'Sugarcane Bagasse',
    'Oil Cake and Residues',
    'Maize and Other Cereal Residues',
    'Banana Plant Waste',
    'Other',
  ];

  // Image variables for storing images
  File? _mainImage;
  List<File> _subImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Set the selected category
    selectedCategory = widget.selectedCategory;
  }

  // Function to pick the main image
  Future<void> pickMainImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mainImage = File(pickedFile.path);
      });
    }
  }

  // Function to pick sub-images (limit of 4)
  Future<void> pickSubImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _subImages = pickedFiles.take(4).map((file) => File(file.path)).toList();
      });
    }
  }

  // Function to upload images to Firebase Storage and get URLs
  Future<String> uploadImageToFirebase(File image, String imageName) async {
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('sales_images')
        .child('$uid/$imageName.jpg');

    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Function to save the sale to Firestore with the images
  void saveSaleToDatabase() async {
    if (uid.isEmpty) {
      print("Error: User not logged in");
      return;
    }

    // Upload main image and get URL
    String? mainImageUrl;
    if (_mainImage != null) {
      mainImageUrl = await uploadImageToFirebase(_mainImage!, 'mainImage');
    }

    // Upload sub images and get URLs
    List<String> subImageUrls = [];
    for (var i = 0; i < _subImages.length; i++) {
      String url = await uploadImageToFirebase(_subImages[i], 'subImage_$i');
      subImageUrls.add(url);
    }

    // Save sale data to Firestore
    FirebaseFirestore.instance.collection('sales').add({
      'uid': uid,
      's_type': selectedCategory,
      's_price': _priceController.text,
      's_quantity': _quantityController.text,
      's_description': _descriptionController.text,
      's_ownerName': _ownerNameController.text,
      's_location': _locationController.text,
      's_address': _addressController.text,
      's_contactNumber': _contactNumberController.text,
      's_mainImage': mainImageUrl,
      's_otherImages': subImageUrls,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      print("Sale created successfully!");
      Navigator.pop(context);
    }).catchError((error) {
      print("Error creating sale: $error");
    });
  }

  // Build category dropdown field
  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Category',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            items:
                categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedCategory = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

  // Build text input field
  Widget _buildDetailField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  // Build image picker button
  Widget _buildImagePickerButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[700],
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Create Sale'),
        backgroundColor: Colors.grey[850],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailField('Owner Name', _ownerNameController),
            _buildDetailField('Location', _locationController),
            _buildDetailField('Address', _addressController),
            _buildDetailField('Contact Number', _contactNumberController),
            _buildCategoryDropdown(),
            _buildDetailField('Price', _priceController),
            _buildDetailField('Quantity', _quantityController),
            _buildDetailField('Description', _descriptionController),

            // Image picker buttons
            const SizedBox(height: 24),
            _buildImagePickerButton('Pick Main Image', pickMainImage),
            _mainImage != null
                ? Image.network(_mainImage!.path, height: 100) // Web support
                : Container(),

            const SizedBox(height: 16),

            _buildImagePickerButton('Pick Sub Images (Max 4)', pickSubImages),
            _subImages.isNotEmpty
                ? Wrap(
                    spacing: 8,
                    children: _subImages.map((file) => Image.network(file.path, height: 80)).toList(), // Web support
                  )
                : Container(),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveSaleToDatabase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('CREATE SALE', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
