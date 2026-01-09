enum BarcodeType {
  ean13,
  code128,
  qrCode,
  upcA,
}

extension BarcodeTypeExtension on BarcodeType {
  String get displayName {
    switch (this) {
      case BarcodeType.ean13:
        return 'EAN-13';
      case BarcodeType.code128:
        return 'Code 128';
      case BarcodeType.qrCode:
        return 'QR Code';
      case BarcodeType.upcA:
        return 'UPC-A';
    }
  }

  String get name {
    switch (this) {
      case BarcodeType.ean13:
        return 'ean13';
      case BarcodeType.code128:
        return 'code128';
      case BarcodeType.qrCode:
        return 'qrCode';
      case BarcodeType.upcA:
        return 'upcA';
    }
  }

  static BarcodeType fromString(String value) {
    switch (value) {
      case 'ean13':
        return BarcodeType.ean13;
      case 'code128':
        return BarcodeType.code128;
      case 'qrCode':
        return BarcodeType.qrCode;
      case 'upcA':
        return BarcodeType.upcA;
      default:
        return BarcodeType.ean13;
    }
  }
}

class LoyaltyCard {
  final String id;
  final String cardName;
  final String barcodeNumber;
  final BarcodeType barcodeType;
  final String? cardImagePath;
  final String? notes;
  final DateTime createdAt;
  final bool isPinned;
  final String? brandId;
  final int? brandPrimaryColor;

  LoyaltyCard({
    required this.id,
    required this.cardName,
    required this.barcodeNumber,
    required this.barcodeType,
    this.cardImagePath,
    this.notes,
    required this.createdAt,
    this.isPinned = false,
    this.brandId,
    this.brandPrimaryColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardName': cardName,
      'barcodeNumber': barcodeNumber,
      'barcodeType': barcodeType.name,
      'cardImagePath': cardImagePath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'isPinned': isPinned,
      'brandId': brandId,
      'brandPrimaryColor': brandPrimaryColor,
    };
  }

  factory LoyaltyCard.fromMap(Map<String, dynamic> map) {
    return LoyaltyCard(
      id: map['id'] ?? '',
      cardName: map['cardName'] ?? '',
      barcodeNumber: map['barcodeNumber'] ?? '',
      barcodeType: map['barcodeType'] != null
          ? BarcodeTypeExtension.fromString(map['barcodeType'])
          : BarcodeType.ean13,
      cardImagePath: map['cardImagePath'],
      notes: map['notes'],
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt'] as DateTime? ?? DateTime.now()),
      isPinned: map['isPinned'] ?? false,
      // Migration: Handle existing cards without brand info
      brandId: map['brandId'],
      brandPrimaryColor: map['brandPrimaryColor'] is int
          ? map['brandPrimaryColor'] as int
          : (map['brandPrimaryColor'] != null
              ? int.tryParse(map['brandPrimaryColor'].toString())
              : null),
    );
  }

  LoyaltyCard copyWith({
    String? id,
    String? cardName,
    String? barcodeNumber,
    BarcodeType? barcodeType,
    String? cardImagePath,
    String? notes,
    DateTime? createdAt,
    bool? isPinned,
    String? brandId,
    int? brandPrimaryColor,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      barcodeNumber: barcodeNumber ?? this.barcodeNumber,
      barcodeType: barcodeType ?? this.barcodeType,
      cardImagePath: cardImagePath ?? this.cardImagePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
      brandId: brandId ?? this.brandId,
      brandPrimaryColor: brandPrimaryColor ?? this.brandPrimaryColor,
    );
  }
}
