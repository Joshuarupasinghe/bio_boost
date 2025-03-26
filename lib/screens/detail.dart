import 'package:flutter/material.dart';

class AgriWasteDetailPage extends StatelessWidget {
  const AgriWasteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // No need for Scaffold since this will be inside the HomePage Scaffold
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo section
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[700],
            child: const Text(
              'LOGO',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // Main image
          Container(
            height: 250,
            color: Colors.grey[800],
            child: Image.asset('images/bioWasteMain.jpg'),
          ),

          // Image navigation
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Image.asset(
                    'images/bioWasteSub1.jpg',
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Image.asset(
                    'images/bioWasteSub2.jpeg',
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Image.asset(
                    'images/bioWasteSub3.jpeg',
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Image.asset(
                    'images/bioWasteSub4.jpg',
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1, thickness: 1, color: Colors.grey),

          // Details section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: _buildDetailRows()),
          ),

          // Contact button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone, color: Colors.white),
              label: const Text(
                'Contact',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
          ),

          // Wishlist button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                'Add To Wish List',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          //Other Agri waste adds
          Container(
            margin: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 12.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Image.asset(
                  'images/bioWasteSub4.jpg', // Replace with your image path
                  height: 120, // Adjust size as needed
                  width: double.infinity, // Make image take full width
                  fit: BoxFit.cover,
                ),
                const SizedBox(
                  height: 12,
                ), // Spacing between image and navigation row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back_ios_new, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Other Agri Waste Adds',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ],
            ),
          ),
          // Rating section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => const Icon(
                      Icons.star_border,
                      size: 30,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Rate'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildDetailRows() {
    final details = [
      {'label': 'Owner Name:', 'value': 'xxxxxxx'},
      {'label': 'Location:', 'value': 'xxxxxxx'},
      {'label': 'Weight:', 'value': 'xxxxxxx'},
      {'label': 'Type:', 'value': 'xxxxxxx'},
      {'label': 'Address:', 'value': 'xxxxxxx'},
      {'label': 'Contact Number:', 'value': 'xxxxxxx'},
      {'label': 'Price:', 'value': 'xxxxxxx'},
      {'label': 'Description:', 'value': 'xxxxxxx'},
    ];

    

    return details.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                item['label']!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: Colors.grey[700],
                child: Text(item['value']!),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
