class Guarantee {
  final String id;
  final String productName;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final String? warrantyImagePath;
  final String? receiptImagePath;
  final String? notes;
  final DateTime createdAt;

  Guarantee({
    required this.id,
    required this.productName,
    required this.purchaseDate,
    required this.expiryDate,
    this.warrantyImagePath,
    this.receiptImagePath,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'warrantyImagePath': warrantyImagePath,
      'receiptImagePath': receiptImagePath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Guarantee.fromMap(Map<String, dynamic> map) {
    return Guarantee(
      id: map['id'] ?? '',
      productName: map['productName'] ?? '',
      purchaseDate: map['purchaseDate'] is String
          ? DateTime.parse(map['purchaseDate'])
          : (map['purchaseDate'] as DateTime),
      expiryDate: map['expiryDate'] is String
          ? DateTime.parse(map['expiryDate'])
          : (map['expiryDate'] as DateTime),
      warrantyImagePath: map['warrantyImagePath'],
      receiptImagePath: map['receiptImagePath'],
      notes: map['notes'],
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt'] as DateTime? ?? DateTime.now()),
    );
  }

  Guarantee copyWith({
    String? id,
    String? productName,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? warrantyImagePath,
    String? receiptImagePath,
    String? notes,
    DateTime? createdAt,
  }) {
    return Guarantee(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      warrantyImagePath: warrantyImagePath ?? this.warrantyImagePath,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

