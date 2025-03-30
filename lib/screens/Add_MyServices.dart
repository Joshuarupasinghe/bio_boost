import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/service_request_service.dart';
import '../services/wanted_sales_service.dart';

class AddMyServicesPage extends StatefulWidget {
  @override
  _AddMyServicesPageState createState() => _AddMyServicesPageState();
}

class _AddMyServicesPageState extends State<AddMyServicesPage> {
  final List<String> services = [
    "Paddy Husk & Straw",
    "Coconut Husks and Shells",
    "Tea Waste",
    "Rubber Wood and Latex Waste",
    "Fruit and Vegetable Waste",
    "Sugarcane Bagasse",
    "Oil Cake and Residues",
    "Maize and Other Cereal Residues",
    "Banana Plant Waste",
  ];

  final WantedSalesService _wantedSalesService = WantedSalesService();

  final ServiceRequestService _serviceRequestService = ServiceRequestService();
  
  String? selectedService;
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 3,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    "Add My Services",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),

                  // Name Input
                  buildLabel("Name"),
                  buildTextField(nameController, "Enter your name", Icons.person),
                  SizedBox(height: 12),

                  // Location Input
                  buildLabel("Location"),
                  buildTextField(locationController, "Enter your location", Icons.location_on),
                  SizedBox(height: 12),

                  // Dropdown Field
                  buildLabel("What Do You Need?"),
                  DropdownButtonFormField<String>(
                    decoration: buildInputDecoration(),
                    dropdownColor: Colors.grey[800],
                    value: selectedService,
                    items: services.map((String service) {
                      return DropdownMenuItem<String>(
                        value: service,
                        child: Text(
                          service,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedService = newValue;
                      });
                    },
                    isExpanded: true,
                  ),
                  SizedBox(height: 12),

                  // Weight Input
                  buildLabel("Weight"),
                  buildTextField(weightController, "Enter weight (kg)", Icons.scale),

                  SizedBox(height: 12),

                  // Description Input
                  buildLabel("Explain what you need (briefly)"),
                  buildTextField(descriptionController, "Enter description", Icons.edit, maxLines: 2),

                  SizedBox(height: 16),

                  // Submit Button
                  GestureDetector(
                    onTap: _isLoading ? null : _submitServiceRequest,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading 
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "POST",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitServiceRequest() async {
    // Validate form fields
    if (nameController.text.isEmpty) {
      _showErrorToast("Please enter your name");
      return;
    }
    
    if (locationController.text.isEmpty) {
      _showErrorToast("Please enter your location");
      return;
    }
    
    if (selectedService == null || selectedService!.isEmpty) {
      _showErrorToast("Please select a service type");
      return;
    }
    
    if (weightController.text.isEmpty) {
      _showErrorToast("Please enter the weight");
      return;
    }
    
    double? weight = double.tryParse(weightController.text);
    if (weight == null || weight <= 0) {
      _showErrorToast("Please enter a valid weight");
      return;
    }
    
    if (descriptionController.text.isEmpty) {
      _showErrorToast("Please enter a description");
      return;
    }
    
    // Submit form
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use the service to add the service request
      await _serviceRequestService.addServiceRequest(
        selectedService!,
        weight,
        descriptionController.text,
        nameController.text,
        locationController.text
      );
      
      // Show success message
      _showSuccessToast("Service request posted successfully");
      
      // Clear form without navigation
      setState(() {
        selectedService = null;
        nameController.clear();
        locationController.clear();
        weightController.clear();
        descriptionController.clear();
        _isLoading = false;  // Make sure to set loading back to false
      });
    } catch (e) {
      _showErrorToast("Error: ${e.toString()}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: buildInputDecoration(hintText, icon),
      style: TextStyle(fontSize: 16, color: Colors.white),
    );
  }

  InputDecoration buildInputDecoration([String hintText = "", IconData? icon]) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      filled: true,
      fillColor: Colors.grey[700],
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}