class SellerModel {
  final String uid;
  final String username;
  final String email;

  SellerModel({required this.uid, required this.username, required this.email});

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'username': username, 'email': email};
  }

  // Convert from Map (for Firestore retrieval)
  factory SellerModel.fromMap(Map<String, dynamic> map) {
    return SellerModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
    );
  }

  // CopyWith for updating values
  SellerModel copyWith({String? uid, String? username, String? email}) {
    return SellerModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}
