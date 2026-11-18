class Category {
  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.productCount,
  });

  final int id;
  final String name;
  final String? description;
  final int productCount;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        description: json['description'] as String?,
        productCount: (json['product_count'] as num?)?.toInt() ?? 0,
      );
}
