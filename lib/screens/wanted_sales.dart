import 'package:flutter/material.dart';

class WantedPage extends StatelessWidget {
  const WantedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Wanted"),
        backgroundColor: Colors.grey[850],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wanted Title Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Wanted",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // District Dropdown
                  _buildDropdown("District"),
                  const SizedBox(height: 10),

                  // City Dropdown
                  _buildDropdown("City"),
                  const SizedBox(height: 10),

                  // Filter Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Filter BTN"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Divider Line
            const Divider(color: Colors.white, thickness: 2),
            const SizedBox(height: 10),

            // List of Wanted Items
            Expanded(
              child: ListView(
                children: [_buildWantedCard(), _buildWantedCard()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function for dropdown fields
  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            dropdownColor: Colors.grey[800],
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(color: Colors.white),
            value: null,
            items:
                ['Option 1', 'Option 2'].map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

  // Function for Wanted Cards
  Widget _buildWantedCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black, // Placeholder color
            ),
          ),
          const SizedBox(width: 10),

          // Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Needs ___(Agri waste type)____",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text("Name: xxxxx", style: TextStyle(color: Colors.white)),
                Text("Location", style: TextStyle(color: Colors.white)),
                Text("Weight", style: TextStyle(color: Colors.white)),
                Text(
                  "Small Description about what he need",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Call Icon
          const Icon(Icons.call, color: Colors.white),
        ],
      ),
    );
  }
}
