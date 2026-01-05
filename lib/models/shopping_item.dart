enum ShoppingUnit {
  piece,
  liter,
  kg,
  gram,
  ml,
  pack,
  bottle,
  box,
  bag,
  other,
}

extension ShoppingUnitExtension on ShoppingUnit {
  String get displayName {
    switch (this) {
      case ShoppingUnit.piece:
        return 'piece';
      case ShoppingUnit.liter:
        return 'liter';
      case ShoppingUnit.kg:
        return 'kg';
      case ShoppingUnit.gram:
        return 'gram';
      case ShoppingUnit.ml:
        return 'ml';
      case ShoppingUnit.pack:
        return 'pack';
      case ShoppingUnit.bottle:
        return 'bottle';
      case ShoppingUnit.box:
        return 'box';
      case ShoppingUnit.bag:
        return 'bag';
      case ShoppingUnit.other:
        return 'other';
    }
  }
}

class ShoppingItem {
  final String id;
  final String name;
  final int quantity;
  final ShoppingUnit unit;
  final bool isCompleted;
  final String addedBy;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.unit = ShoppingUnit.piece,
    this.isCompleted = false,
    required this.addedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit.name,
      'isCompleted': isCompleted,
      'addedBy': addedBy,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 1,
      unit: map['unit'] != null
          ? ShoppingUnit.values.firstWhere(
              (e) => e.name == map['unit'],
              orElse: () => ShoppingUnit.piece,
            )
          : ShoppingUnit.piece,
      isCompleted: map['isCompleted'] ?? false,
      addedBy: map['addedBy'] ?? '',
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    int? quantity,
    ShoppingUnit? unit,
    bool? isCompleted,
    String? addedBy,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isCompleted: isCompleted ?? this.isCompleted,
      addedBy: addedBy ?? this.addedBy,
    );
  }
}

