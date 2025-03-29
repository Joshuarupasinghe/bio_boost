import 'package:flutter/material.dart';

class ActiveSales extends StatelessWidget {
  const ActiveSales({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activeSales = [
      {'type': 'Tea Waste'},
      {'type': 'Banana Plant Waste'},
      {'type': 'Coffee Pulp & Husk'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Active Sales',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeSales.length,
        itemBuilder: (context, index) {
          final sale = activeSales[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.grey[850],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // color: Colors.grey[800],
                    child: Center(
                      child: Image.asset('images/bioWasteMain.jpg'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Owner: xxxxxxxxxx',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Location:',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Weight:',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Type: ', // The label part
                                style: const TextStyle(
                                  color: Colors.white70, // Color for the label
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: '${sale['type']}', // The value part
                                style: const TextStyle(
                                  color:
                                      Colors.tealAccent, // Color for the value
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
