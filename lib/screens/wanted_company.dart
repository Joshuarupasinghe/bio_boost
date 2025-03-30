import 'package:bio_boost/screens/Add_MyServices.dart';
import 'package:bio_boost/services/service_request_service.dart';
import 'package:flutter/material.dart';

class WantedCompanyPage extends StatefulWidget {
  const WantedCompanyPage({super.key});

  @override
  _WantedCompanyPageState createState() => _WantedCompanyPageState();
}

class _WantedCompanyPageState extends State<WantedCompanyPage> {
  final ServiceRequestService _serviceRequestService = ServiceRequestService();
  List<Map<String, dynamic>> _serviceRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServiceRequests();
  }

  Future<void> _fetchServiceRequests() async {
    try {
      final requests = await _serviceRequestService.getServiceRequests();
      setState(() {
        _serviceRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load service requests: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          "Wanted",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMyServicesPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Filter Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildDropdown("District"),
                          const SizedBox(height: 10),
                          _buildDropdown("City"),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                // Add filter logic here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                "Filter",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // List of Wanted Items
                    Expanded(
                      child: ListView.builder(
                        itemCount: _serviceRequests.length,
                        itemBuilder: (context, index) {
                          return _buildWantedCard(_serviceRequests[index]);
                        },
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
            onChanged: (value) {
              // Handle dropdown selection
            },
          ),
        ),
      ],
    );
  }

  // Function for Wanted Cards
  Widget _buildWantedCard(Map<String, dynamic> data) {
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
              children: [
                Text(
                  "Needs ${data['serviceType'] ?? 'Unknown'}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Name: ${data['name'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Location: ${data['location'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Weight: ${data['weight'] ?? 'N/A'} kg",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  data['description'] ?? 'No description provided',
                  style: const TextStyle(color: Colors.white70),
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
