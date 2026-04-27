class Product {
  final dynamic id;
  final String? name;
  final String? category;
  final Map<String, dynamic> details;

  Product({
    required this.id,
    this.name,
    this.category,
    required this.details,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // If 'details' is null or not a Map, default to empty map
    Map<String, dynamic> parsedDetails = {};
    if (json['details'] != null && json['details'] is Map) {
      parsedDetails = Map<String, dynamic>.from(json['details']);
    }

    return Product(
      id: json['id'],
      name: json['name']?.toString(),
      category: json['category']?.toString(),
      details: parsedDetails,
    );
  }
}
