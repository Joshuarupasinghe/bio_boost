class Sales {
  final String documentId;
  final String s_ownerName;
  final String s_location;
  final String s_weight;
  final String s_type;
  final String s_address;
  final String s_contactNumber;
  final String s_price;
  final String s_description;
  final String s_mainImage;
  final List<String> s_otherImages;

  Sales({
    required this.documentId,
    required this.s_ownerName,
    required this.s_location,
    required this.s_weight,
    required this.s_type,
    required this.s_address,
    required this.s_contactNumber,
    required this.s_price,
    required this.s_description,
    required this.s_mainImage,
    required this.s_otherImages,
  });

  factory Sales.fromMap(Map<String, dynamic> data, String documentId) {
    return Sales(
      documentId: documentId,
      s_ownerName: data['s_name'] ?? '',
      s_location: data['s_location'] ?? '',
      s_weight: data['s_weight'] ?? '',
      s_type: data['s_type'] ?? '',
      s_address: data['s_address'] ?? '',
      s_contactNumber: data['s_contactNumber'] ?? '',
      s_price: data['s_price'] ?? '',
      s_description: data['s_description'] ?? '',
      s_mainImage: data['s_mainImage'] ?? 'https://via.placeholder.com/250',
      s_otherImages: List<String>.from(data['s_otherImages'] ?? []),
    );
  }
}
