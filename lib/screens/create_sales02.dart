import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Widget displayImage(File? imageFile) {
  if (imageFile == null) return const SizedBox(); // No image selected

  if (kIsWeb) {
    return Image.network(imageFile.path, height: 100); // Web uses network path
  } else {
    return Image.file(imageFile, height: 100); // Mobile & desktop use File
  }
}

class CreateSales02 extends StatefulWidget {
  final String selectedCategory;

  const CreateSales02({super.key, required this.selectedCategory});

  @override
  _CreateSales02State createState() => _CreateSales02State();
}

class _CreateSales02State extends State<CreateSales02> {
  late String uid;
  late String selectedCategory;

  // Text editing controllers
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
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

  // Image variables
  File? _mainImage;
  List<File> _subImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    selectedCategory = widget.selectedCategory;
    _fetchUserData();
  }

  // Fetch user data
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _locationController.text = "${userData['district']}, ${userData['city']}";
        });
      }
    }
  }

  // Pick main image
  Future<void> pickMainImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mainImage = File(pickedFile.path);
      });
    }
  }

  // Pick sub-images (max 4)
  Future<void> pickSubImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _subImages = pickedFiles.take(4).map((file) => File(file.path)).toList();
      });
    }
  }

  // Upload image to Firebase Storage and get URL
  Future<String?> uploadImageToFirebase(File image, String imageName) async {
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('sales_images/$uid/$imageName.jpg');

      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  // Save sale to Firestore with images
  void saveSaleToDatabase() async {
    if (uid.isEmpty) {
      print("Error: User not logged in");
      return;
    }

    String? mainImageUrl;
    if (_mainImage != null) {
      mainImageUrl = await uploadImageToFirebase(_mainImage!, 'mainImage');
    }

    List<String> subImageUrls = [];
    for (var i = 0; i < _subImages.length; i++) {
      String? url = await uploadImageToFirebase(_subImages[i], 'subImage$i');
      if (url != null) {
        subImageUrls.add(url);
      }
    }

    // Save to Firestore
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

  // Build UI widgets
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      dropdownColor: Colors.grey[800],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedCategory = newValue!;
        });
      },
    );
  }

  Widget _buildDetailField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Enter $label',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildImagePickerButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: const Text('Create Sale'), backgroundColor: Colors.grey[850]),
      body: SingleChildScrollView( // Ensure the content is scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailField('Owner Name', _ownerNameController),
            _buildDetailField('Location', _locationController),
            _buildDetailField('Address', _addressController),
            _buildDetailField('Contact Number', _contactNumberController),
            _buildCategoryDropdown(),
            _buildDetailField('Price', _priceController),
            _buildDetailField('Quantity', _quantityController),
            _buildDetailField('Description', _descriptionController),
            const SizedBox(height: 16),
            _buildImagePickerButton('Pick Main Image', pickMainImage),
            if (_mainImage != null) displayImage(_mainImage), // Display main image
            const SizedBox(height: 16),
            _buildImagePickerButton('Pick Sub Images (Max 4)', pickSubImages),
            Wrap(
              spacing: 8,
              children: _subImages.map((file) => displayImage(file)).toList(), // Display sub-images
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveSaleToDatabase,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
              child: const Text('CREATE SALE', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}