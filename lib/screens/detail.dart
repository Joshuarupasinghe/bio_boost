import 'package:flutter/material.dart';
import 'package:bio_boost/models/sales_model.dart';
import 'package:bio_boost/data/sales_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AgriWasteDetailPage extends StatefulWidget {
  final String saleId;

  const AgriWasteDetailPage({super.key, required this.saleId});

  @override
  _AgriWasteDetailPageState createState() => _AgriWasteDetailPageState();
}

class _AgriWasteDetailPageState extends State<AgriWasteDetailPage> {
  late Future<Sales?> _agriWasteFuture;
  final SalesService _salesService = SalesService();
  int _selectedImageIndex = -1; // -1 means main image is selected

  @override
  void initState() {
    super.initState();
    _agriWasteFuture = _salesService.getSalesDetailsById(widget.saleId);
  }

  //Adding Data to wishlist page using SharedPreferences
  Future<void> _addToWishlist(Sales agriWaste) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> wishlist = prefs.getStringList('wishlist') ?? [];

    String saleJson = jsonEncode({
      'id': agriWaste.documentId,
      'owner': agriWaste.s_ownerName,
      'location': agriWaste.s_location,
      'weight': agriWaste.s_weight,
      'type': agriWaste.s_type,
      'image': agriWaste.s_mainImage,
    });

    if (!wishlist.contains(saleJson)) {
      wishlist.add(saleJson);
      await prefs.setStringList('wishlist', wishlist);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Added to Wishlist")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agricultural Waste Details')),
      body: FutureBuilder<Sales?>(
        future: _agriWasteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data available"));
          }

          final agriWaste = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main image container
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _selectedImageIndex == -1
                          ? agriWaste.s_mainImage
                          : agriWaste.s_otherImages[_selectedImageIndex],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Image not available'));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary images row
                SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      // Main image thumbnail
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImageIndex = -1;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    _selectedImageIndex == -1
                                        ? Colors.blue
                                        : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Image.network(
                                agriWaste.s_mainImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Other images (up to 4 thumbnails)
                      ...List.generate(
                        agriWaste.s_otherImages.length > 4
                            ? 4
                            : agriWaste.s_otherImages.length,
                        (index) => Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageIndex = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _selectedImageIndex == index
                                          ? Colors.blue
                                          : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.network(
                                  agriWaste.s_otherImages[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Fill remaining spaces if less than 4 other images
                      if (agriWaste.s_otherImages.length < 4)
                        ...List.generate(
                          4 - agriWaste.s_otherImages.length,
                          (index) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 10),

                _buildDetailFields(agriWaste),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone),
                    label: const Text('Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addToWishlist(agriWaste),
                    child: const Text('Add To Wish List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailFields(Sales agriWaste) {
    final details = [
      {'label': 'Owner Name:', 'value': agriWaste.s_ownerName},
      {'label': 'Location:', 'value': agriWaste.s_location},
      {'label': 'Weight:', 'value': agriWaste.s_weight},
      {'label': 'Type:', 'value': agriWaste.s_type},
      {'label': 'Address:', 'value': agriWaste.s_address},
      {'label': 'Contact Number:', 'value': agriWaste.s_contactNumber},
      {'label': 'Price:', 'value': agriWaste.s_price},
      {'label': 'Description:', 'value': agriWaste.s_description},
    ];

    return Column(
      children:
          details.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      item['label']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['value']!,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
