class PaginatedResponse<T> {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<T> items;

  PaginatedResponse({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      page: json['page'],
      perPage: json['perPage'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
      items: (json['items'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ShoppingItem {
  final String? collectionId;
  final String? collectionName;
  final String id;
  final String name;
  final int quantity;
  final String category;
  final DateTime? created;
  final DateTime? updated;

  ShoppingItem({
    this.collectionId,
    this.collectionName,
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.created,
    this.updated,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      collectionId: json['collectionId'],
      collectionName: json['collectionName'],
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collectionId': collectionId,
      'collectionName': collectionName,
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'created': created!.toIso8601String(),
      'updated': updated!.toIso8601String(),
    };
  }
}
