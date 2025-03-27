class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String companyName;
  final String phone;
  final String address;
  final String district;
  final String city;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.companyName,
    required this.phone,
    required this.address,
    required this.district,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'companyName': companyName,
      'phone': phone,
      'address': address,
      'district': district,
      'city': city,
    };
  }
}
