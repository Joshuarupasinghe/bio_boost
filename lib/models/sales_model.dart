class Sales {
  final String s_id;
  final String s_ownerName;
  final String s_location;
  final String s_weight;
  final String s_type;
  final String s_address;
  final String s_contactNumber;
  final String s_price;
  final String s_description;
  final List<String> s_images;

  Sales({
    required this.s_id,
    required this.s_ownerName,
    required this.s_location,
    required this.s_weight,
    required this.s_type,
    required this.s_address,
    required this.s_contactNumber,
    required this.s_price,
    required this.s_description,
    required this.s_images,
  });

  // Convert Firebase snapshot to AgriWaste object
  factory Sales.fromMap(Map<String, dynamic> data, String documentId) {
    return Sales(
      s_id: documentId,
      s_ownerName: data['ownerName'] ?? '',
      s_location: data['location'] ?? '',
      s_weight: data['weight'] ?? '',
      s_type: data['type'] ?? '',
      s_address: data['address'] ?? '',
      s_contactNumber: data['contactNumber'] ?? '',
      s_price: data['price'] ?? '',
      s_description: data['description'] ?? '',
      s_images: List<String>.from(data['images'] ?? []),
    );
  }
}
