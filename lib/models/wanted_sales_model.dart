class WantedSale {
  String id;
  String name;
  String location;
  double weight;
  String description;

  WantedSale({
    required this.id,
    required this.name,
    required this.location,
    required this.weight,
    required this.description,
  });

  // Convert data to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'weight': weight,
      'description': description,
    };
  }

  // Convert Firestore document snapshot to WantedSale object
  factory WantedSale.fromMap(Map<String, dynamic> map, String documentId) {
    return WantedSale(
      id: documentId,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      description: map['description'] ?? '',
    );
  }
}
