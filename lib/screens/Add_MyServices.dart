import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/service_request_service.dart';
import '../services/user_service.dart';
import '../services/wanted_sales_service.dart';

class AddMyServicesPage extends StatefulWidget {
  const AddMyServicesPage({super.key});

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
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    weightController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    loadUserName();
  }

    void loadUserName() async {
    String fullName = await UserService().getCurrentUserFullName();
    setState(() {
      nameController.text = fullName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add My Needs",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
      
                buildLabel("Name"),
                buildTextField(nameController, "Enter your name", Icons.person),
                SizedBox(height: 12),
      
                buildLabel("Location"),
                buildTextField(locationController, "Enter your location", Icons.location_on),
                SizedBox(height: 12),
      
                buildLabel("What Do You Need?"),
                DropdownButtonFormField<String>(
                  decoration: buildInputDecoration(),
                  dropdownColor: Colors.grey[800],
                  value: selectedService,
                  hint: Text(
                    "Select an option",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
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
      
                buildLabel("Weight"),
                buildTextField(weightController, "Enter weight (kg)", Icons.scale),
                SizedBox(height: 12),
      
                buildLabel("Explain what you need (briefly)"),
                buildTextField(descriptionController, "Enter description", Icons.edit, maxLines: 2),
      
                SizedBox(height: 16),
      
                GestureDetector(
                  onTap: _isLoading ? null : _submitServiceRequest,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(12),
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
    );
  }

  Future<void> _submitServiceRequest() async {
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
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _serviceRequestService.addServiceRequest(
        selectedService!,
        weight,
        descriptionController.text,
        nameController.text,
        locationController.text
      );
      
      _showSuccessToast("Service request posted successfully");
      Navigator.pop(context, true);

      setState(() {
        selectedService = null;
        nameController.clear();
        locationController.clear();
        weightController.clear();
        descriptionController.clear();
        _isLoading = false;
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
