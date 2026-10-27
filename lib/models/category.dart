class Category {
  final String id;
  final String name;
  final String description;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.sortOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sortOrder': sortOrder,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      sortOrder: (map['sortOrder'] as num).toInt(),
    );
  }
}
