import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

 // District and City Data
final Map<String, List<String>> districtCities = {
  'Ampara': ['Ampara', 'Kalmunai', 'Pottuvil', 'Akkaraipattu', 'Sammanthurai', 'Deegavapi', 'Uhana'],
  'Anuradhapura': ['Anuradhapura', 'Mihintale', 'Kekirawa', 'Medawachchiya', 'Galnewa', 'Thalawa'],
  'Badulla': ['Badulla', 'Bandarawela', 'Haputale', 'Ella', 'Mahiyanganaya', 'Welimada', 'Passara'],
  'Batticaloa': ['Batticaloa', 'Kaluwanchikudy', 'Eravur', 'Valachchenai', 'Kattankudy', 'Oddamavadi'],
  'Colombo': ['Colombo', 'Dehiwala', 'Mount Lavinia', 'Moratuwa', 'Maharagama', 'Kotte', 'Nugegoda'],
  'Galle': ['Galle', 'Unawatuna', 'Hikkaduwa', 'Ambalangoda', 'Bentota', 'Karapitiya', 'Baddegama'],
  'Gampaha': ['Gampaha', 'Negombo', 'Wattala', 'Ja-Ela', 'Minuwangoda', 'Kelaniya', 'Katunayake'],
  'Hambantota': ['Hambantota', 'Tangalle', 'Tissamaharama', 'Beliatta', 'Kataragama', 'Ambalantota'],
  'Jaffna': ['Jaffna', 'Chavakachcheri', 'Point Pedro', 'Nallur', 'Kopay', 'Velanai', 'Kayts'],
  'Kalutara': ['Kalutara', 'Panadura', 'Horana', 'Beruwala', 'Aluthgama', 'Wadduwa', 'Matugama'],
  'Kandy': ['Kandy', 'Peradeniya', 'Katugastota', 'Gampola', 'Nawalapitiya', 'Wattegama', 'Kundasale'],
  'Kegalle': ['Kegalle', 'Mawanella', 'Warakapola', 'Rambukkana', 'Aranayaka', 'Galigamuwa'],
  'Kilinochchi': ['Kilinochchi', 'Paranthan', 'Mallavi', 'Pooneryn', 'Dharmapuram'],
  'Kurunegala': ['Kurunegala', 'Pannala', 'Kuliyapitiya', 'Narammala', 'Polgahawela', 'Melsiripura', 'Ibbagamuwa'],
  'Mannar': ['Mannar', 'Murunkan', 'Pesalai', 'Nanattan', 'Talaimannar'],
  'Matale': ['Matale', 'Dambulla', 'Sigiriya', 'Rattota', 'Ukuwela', 'Galewela', 'Pallepola'],
  'Matara': ['Matara', 'Weligama', 'Mirissa', 'Akuressa', 'Dikwella', 'Deniyaya', 'Hakmana'],
  'Monaragala': ['Monaragala', 'Wellawaya', 'Bibile', 'Madulla', 'Medagama', 'Siyambalanduwa'],
  'Mullaitivu': ['Mullaitivu', 'Puthukudiyiruppu', 'Oddusuddan', 'Mallavi', 'Thunukkai'],
  'Nuwara Eliya': ['Nuwara Eliya', 'Hatton', 'Talawakele', 'Kotagala', 'Ragala', 'Ginigathena', 'Walapane'],
  'Polonnaruwa': ['Polonnaruwa', 'Hingurakgoda', 'Medirigiriya', 'Thamankaduwa', 'Dimbulagala'],
  'Puttalam': ['Puttalam', 'Chilaw', 'Wennappuwa', 'Marawila', 'Anamaduwa', 'Kalpitiya'],
  'Ratnapura': ['Ratnapura', 'Eheliyagoda', 'Pelmadulla', 'Balangoda', 'Kahawatta', 'Godakawela'],
  'Trincomalee': ['Trincomalee', 'Kinniya', 'Muttur', 'Nilaveli', 'Thampalakamam', 'Kuchchaveli'],
  'Vavuniya': ['Vavuniya', 'Omanthai', 'Cheddikulam', 'Nedunkeni'],
};


  String? selectedDistrict;
  String? selectedCity;
  String userType = "Buyer"; // Default selection

  Future<void> _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    if (selectedDistrict == null || selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your district and city!")),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Determine collection based on user type
      String collection = userType == "Buyer" ? "buyers" : "sellers";

      await _firestore
          .collection(collection)
          .doc(userCredential.user!.uid)
          .set({
            "firstName": firstNameController.text.trim(),
            "lastName": lastNameController.text.trim(),
            "companyName": companyNameController.text.trim(),
            "phoneNumber": phoneNumberController.text.trim(),
            "address": addressController.text.trim(),
            "district": selectedDistrict,
            "city": selectedCity,
            "email": emailController.text.trim(),
            "userType": userType,
            "createdAt": DateTime.now(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sign-Up Successful!")));

      Navigator.pop(context); // Navigate back to Sign-In Page
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 120, // Label width (adjustable)
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Sign Up", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("First Name", firstNameController),
              _buildTextField("Last Name", lastNameController),
              _buildTextField("Company", companyNameController),
              _buildTextField("Phone", phoneNumberController),
              _buildTextField("Address", addressController),

              // District Dropdown
              _buildDropdown(
                "District",
                districtCities.keys.toList(),
                selectedDistrict,
                (newValue) {
                  setState(() {
                    selectedDistrict = newValue;
                    selectedCity = null; // Reset city when district changes
                  });
                },
              ),

              // City Dropdown (Only show cities for selected district)
              _buildDropdown(
                "City",
                selectedDistrict != null
                    ? districtCities[selectedDistrict]!
                    : [],
                selectedCity,
                (newValue) {
                  setState(() {
                    selectedCity = newValue;
                  });
                },
              ),

              _buildTextField("Email", emailController),
              _buildTextField(
                "Password",
                passwordController,
                obscureText: !_passwordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              _buildTextField(
                "Confirm",
                confirmPasswordController,
                obscureText: !_confirmPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),

              // Radio Button for Buyer or Seller
              Row(
                children: [
                  const Text(
                    "Who am I?",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 20),
                  Radio(
                    value: "Buyer",
                    groupValue: userType,
                    onChanged: (value) {
                      setState(() {
                        userType = value.toString();
                      });
                    },
                    activeColor: Colors.teal,
                  ),
                  const Text("Buyer", style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 20),
                  Radio(
                    value: "Seller",
                    groupValue: userType,
                    onChanged: (value) {
                      setState(() {
                        userType = value.toString();
                      });
                    },
                    activeColor: Colors.teal,
                  ),
                  const Text("Seller", style: TextStyle(color: Colors.white)),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Sign Up", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
              dropdownColor: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
