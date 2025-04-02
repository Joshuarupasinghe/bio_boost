// import 'package:flutter/material.dart';
// import 'package:bio_boost/data/sales_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:bio_boost/models/user_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path/path.dart' as path;

// class AddSalePage extends StatefulWidget {
//   const AddSalePage({super.key});

//   @override
//   State<AddSalePage> createState() => _AddSalePageState();
// }

// class _AddSalePageState extends State<AddSalePage> {
//   final _formKey = GlobalKey<FormState>();
//   final SalesService _salesService = SalesService();
//   UserModel? _currentUser;
//   bool _isLoading = false;
//   String? _userId;

//   // Form controllers
//   final TextEditingController _typeController = TextEditingController();
//   final TextEditingController _weightController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   // For image handling
//   File? _mainImage;
//   final List<File> _otherImages = [];
//   final ImagePicker _picker = ImagePicker();

//   // Pre-defined waste types for dropdown
//   final List<String> _wasteTypes = [
//     'Tea Waste',
//     'Coffee Pulp & Husk',
//     'Banana Plant Waste',
//     'Coconut Husk',
//     'Rice Straw',
//     'Other',
//   ];
//   String? _selectedWasteType;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUser();
//   }

//   Future<void> _getCurrentUser() async {
//     try {
//       // Get current logged in user
//       User? firebaseUser = FirebaseAuth.instance.currentUser;

//       if (firebaseUser == null) {
//         // Handle not logged in state
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('You need to be logged in to add a sale'),
//           ),
//         );
//         Navigator.pop(context);
//         return;
//       }

//       setState(() {
//         _userId = firebaseUser.uid;
//       });

//       // Load the user data from Firestore
//       await _loadUserData(firebaseUser.uid);
//     } catch (e) {
//       print('Error getting current user: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Authentication error: $e')));
//     }
//   }

//   Future<void> _loadUserData(String userId) async {
//     try {
//       DocumentSnapshot userDoc =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(userId)
//               .get();

//       if (userDoc.exists) {
//         setState(() {
//           _currentUser = UserModel.fromMap(
//             userDoc.data() as Map<String, dynamic>,
//           );
//         });
//       } else {
//         // Handle case where user document doesn't exist
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'User profile not found. Please complete your profile first.',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error loading user data: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
//     }
//   }

//   Future<void> _pickMainImage() async {
//     final XFile? pickedFile = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );

//     if (pickedFile != null) {
//       setState(() {
//         _mainImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _pickOtherImages() async {
//     final List<XFile>? pickedFiles = await _picker.pickMultiImage(
//       imageQuality: 80,
//     );

//     if (pickedFiles != null) {
//       setState(() {
//         for (var file in pickedFiles) {
//           _otherImages.add(File(file.path));
//         }
//       });
//     }
//   }

//   Future<String> _uploadImage(File imageFile) async {
//     if (_userId == null) {
//       throw Exception('User not authenticated');
//     }

//     String fileName = path.basename(imageFile.path);
//     Reference storageRef = FirebaseStorage.instance.ref().child(
//       'sales_images/$_userId/${DateTime.now().millisecondsSinceEpoch}_$fileName',
//     );

//     UploadTask uploadTask = storageRef.putFile(imageFile);
//     TaskSnapshot taskSnapshot = await uploadTask;
//     return await taskSnapshot.ref.getDownloadURL();
//   }

//   Future<void> _submitSale() async {
//     if (_userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('You must be logged in to post a sale')),
//       );
//       return;
//     }

//     if (_currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('User profile not loaded. Please try again'),
//         ),
//       );
//       return;
//     }

//     if (_formKey.currentState!.validate()) {
//       if (_mainImage == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please select a main image')),
//         );
//         return;
//       }

//       if (_selectedWasteType == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please select a waste type')),
//         );
//         return;
//       }

//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         // Upload main image
//         String mainImageUrl = await _uploadImage(_mainImage!);

//         // Upload other images
//         List<String> otherImageUrls = [];
//         for (var image in _otherImages) {
//           String url = await _uploadImage(image);
//           otherImageUrls.add(url);
//         }

//         // Prepare sale data
//         Map<String, dynamic> saleData = {
//           's_name': _currentUser?.firstName ?? 'Unknown',
//           's_location': _currentUser?.city ?? 'Unknown',
//           's_weight': _weightController.text,
//           's_type': _selectedWasteType!,
//           's_address': _currentUser?.address ?? 'Unknown',
//           's_contactNumber': _currentUser?.phone ?? 'Unknown',
//           's_price': _priceController.text,
//           's_description': _descriptionController.text,
//           's_mainImage': mainImageUrl,
//           's_otherImages': otherImageUrls,
//           's_sellerId': _userId,
//           'timestamp': FieldValue.serverTimestamp(),
//         };

//         // Add to Firestore
//         String? documentId = await _salesService.addSale(saleData);

//         if (documentId != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Sale added successfully')),
//           );
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text('Failed to add sale')));
//         }
//       } catch (e) {
//         print('Error submitting sale: $e');
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[900],
//       appBar: AppBar(
//         title: const Text(
//           'Add New Sale',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.grey[850],
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Main Image Selection
//                       Center(
//                         child: GestureDetector(
//                           onTap: _pickMainImage,
//                           child: Container(
//                             width: double.infinity,
//                             height: 200,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[800],
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.grey[700]!),
//                             ),
//                             child:
//                                 _mainImage == null
//                                     ? Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.add_photo_alternate,
//                                           size: 50,
//                                           color: Colors.grey[400],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           'Add Main Image',
//                                           style: TextStyle(
//                                             color: Colors.grey[400],
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                     : ClipRRect(
//                                       borderRadius: BorderRadius.circular(12),
//                                       child: Image.file(
//                                         _mainImage!,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Type Dropdown
//                       const Text(
//                         'Type of Waste:',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[800],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: _selectedWasteType,
//                             isExpanded: true,
//                             dropdownColor: Colors.grey[800],
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                             ),
//                             hint: Text(
//                               'Select type',
//                               style: TextStyle(color: Colors.grey[400]),
//                             ),
//                             icon: Icon(
//                               Icons.arrow_drop_down,
//                               color: Colors.grey[400],
//                             ),
//                             items:
//                                 _wasteTypes.map((String type) {
//                                   return DropdownMenuItem<String>(
//                                     value: type,
//                                     child: Text(type),
//                                   );
//                                 }).toList(),
//                             onChanged: (String? newValue) {
//                               setState(() {
//                                 _selectedWasteType = newValue;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Weight Field
//                       const Text(
//                         'Weight (kg):',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _weightController,
//                         style: const TextStyle(color: Colors.white),
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.grey[800],
//                           hintText: 'Enter weight',
//                           hintStyle: TextStyle(color: Colors.grey[400]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           suffixText: 'kg',
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter weight';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // Price Field
//                       const Text(
//                         'Price (Rs):',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _priceController,
//                         style: const TextStyle(color: Colors.white),
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.grey[800],
//                           hintText: 'Enter price',
//                           hintStyle: TextStyle(color: Colors.grey[400]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           prefixText: 'Rs. ',
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter price';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // Description Field
//                       const Text(
//                         'Description:',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _descriptionController,
//                         style: const TextStyle(color: Colors.white),
//                         maxLines: 3,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.grey[800],
//                           hintText: 'Describe your waste...',
//                           hintStyle: TextStyle(color: Colors.grey[400]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Additional Images
//                       const Text(
//                         'Additional Images (Optional):',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                       const SizedBox(height: 8),
//                       GestureDetector(
//                         onTap: _pickOtherImages,
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[800],
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.grey[700]!),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.add_photo_alternate,
//                                 color: Colors.grey[400],
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Add More Images',
//                                 style: TextStyle(color: Colors.grey[400]),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),

//                       // Preview of additional images
//                       if (_otherImages.isNotEmpty)
//                         SizedBox(
//                           height: 100,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: _otherImages.length,
//                             itemBuilder: (context, index) {
//                               return Padding(
//                                 padding: const EdgeInsets.only(right: 8),
//                                 child: Stack(
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.circular(8),
//                                       child: Image.file(
//                                         _otherImages[index],
//                                         width: 100,
//                                         height: 100,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 0,
//                                       right: 0,
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           setState(() {
//                                             _otherImages.removeAt(index);
//                                           });
//                                         },
//                                         child: Container(
//                                           padding: const EdgeInsets.all(4),
//                                           decoration: BoxDecoration(
//                                             color: Colors.black.withOpacity(
//                                               0.7,
//                                             ),
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: const Icon(
//                                             Icons.close,
//                                             size: 16,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       const SizedBox(height: 24),

//                       // Submit Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _submitSale,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'POST FOR SALE',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//               ),
//     );
//   }

//   @override
//   void dispose() {
//     _typeController.dispose();
//     _weightController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }
