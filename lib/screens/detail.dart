import 'package:flutter/material.dart';
import 'package:bio_boost/models/sales_model.dart';
import 'package:bio_boost/services/sales_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:bio_boost/screens/chat_detail.dart';

class AgriWasteDetailPage extends StatefulWidget {
  final String saleId;
  final String currentUserId;

  const AgriWasteDetailPage({
    super.key,
    required this.saleId,
    required this.currentUserId,
  });

  @override
  _AgriWasteDetailPageState createState() => _AgriWasteDetailPageState();
}

class _AgriWasteDetailPageState extends State<AgriWasteDetailPage> {
  late Future<Sales?> _agriWasteFuture;
  final SalesService _salesService = SalesService();
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _agriWasteFuture = _salesService.getSalesById(widget.saleId);
  }

  Future<void> _addToWishlist(Sales agriWaste) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> wishlist = prefs.getStringList('wishlist') ?? [];

    String saleJson = jsonEncode({
      'id': agriWaste.id,
      'owner': agriWaste.ownerName,
      'location': agriWaste.location,
      'weight': agriWaste.weight,
      'type': agriWaste.type,
      'price': agriWaste.price,
      'image': agriWaste.imageUrls.isNotEmpty ? agriWaste.imageUrls[0] : '',
    });

    if (!wishlist.contains(saleJson)) {
      wishlist.add(saleJson);
      await prefs.setStringList('wishlist', wishlist);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Added to Wishlist"),
          backgroundColor: Colors.teal[400],
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Already in Wishlist")));
    }
  }

  void _contactSeller(Sales agriWaste) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatDetailScreen(
              name: agriWaste.ownerName,
              avatar:
                  agriWaste.ownerName.isNotEmpty
                      ? agriWaste.ownerName.substring(0, 1).toUpperCase()
                      : 'S',
              userId: agriWaste.ownerId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agricultural Waste Details'),
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[900],
      body: FutureBuilder<Sales?>(
        future: _agriWasteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading details",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final agriWaste = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main image display
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        agriWaste.imageUrls.isNotEmpty
                            ? Image.network(
                              agriWaste.imageUrls[_selectedImageIndex],
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                      size: 50,
                                    ),
                                  ),
                            )
                            : Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: 50,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                // Image thumbnails
                if (agriWaste.imageUrls.length > 1)
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: agriWaste.imageUrls.length,
                      itemBuilder:
                          (context, index) => GestureDetector(
                            onTap:
                                () =>
                                    setState(() => _selectedImageIndex = index),
                            child: Container(
                              width: 80,
                              margin: EdgeInsets.only(
                                right:
                                    index == agriWaste.imageUrls.length - 1
                                        ? 0
                                        : 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _selectedImageIndex == index
                                          ? Colors.teal
                                          : Colors.grey[700]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  agriWaste.imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.image),
                                      ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Details section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Owner:', agriWaste.ownerName),
                      _buildDetailRow('Location:', agriWaste.location),
                      _buildDetailRow('Type:', agriWaste.type),
                      _buildDetailRow('Weight:', '${agriWaste.weight} kg'),
                      _buildDetailRow('Price:', '\Rs.${agriWaste.price}'),
                      _buildDetailRow('Contact:', agriWaste.contactNumber),
                      const SizedBox(height: 12),
                      const Text(
                        'Description:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        agriWaste.description,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _contactSeller(agriWaste),
                        child: const Text(
                          'Contact Seller',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.teal),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _addToWishlist(agriWaste),
                        child: const Text(
                          'Add to Wishlist',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
