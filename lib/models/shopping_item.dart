class ShoppingItem {
  final String id;
  final String name;
  final int quantity;
  final bool isCompleted;
  final String addedBy;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.isCompleted = false,
    required this.addedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'isCompleted': isCompleted,
      'addedBy': addedBy,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 1,
      isCompleted: map['isCompleted'] ?? false,
      addedBy: map['addedBy'] ?? '',
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    int? quantity,
    bool? isCompleted,
    String? addedBy,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
      addedBy: addedBy ?? this.addedBy,
    );
  }
}

