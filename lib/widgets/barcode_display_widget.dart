import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/loyalty_card.dart' as loyalty_card;

class BarcodeDisplayWidget extends StatelessWidget {
  final String barcodeNumber;
  final loyalty_card.BarcodeType barcodeType;
  final double? width;
  final double? height;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const BarcodeDisplayWidget({
    super.key,
    required this.barcodeNumber,
    required this.barcodeType,
    this.width,
    this.height,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = foregroundColor ?? Colors.black;
    final bgColor = backgroundColor ?? Colors.white;

    if (barcodeType == loyalty_card.BarcodeType.qrCode) {
      return Container(
        width: width,
        height: height,
        color: bgColor,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;
            final qrSize = (availableWidth < availableHeight 
                ? availableWidth 
                : availableHeight).clamp(200.0, 300.0);
            
            return SizedBox(
              width: qrSize,
              height: qrSize,
              child: QrImageView(
                data: barcodeNumber,
                version: QrVersions.auto,
                size: qrSize,
                backgroundColor: bgColor,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: fgColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: fgColor,
                ),
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            );
          },
        ),
      );
    }

    // Linear barcodes
    Barcode? barcode;
    switch (barcodeType) {
      case loyalty_card.BarcodeType.ean13:
        barcode = Barcode.ean13();
        break;
      case loyalty_card.BarcodeType.code128:
        barcode = Barcode.code128();
        break;
      case loyalty_card.BarcodeType.upcA:
        barcode = Barcode.upcA();
        break;
      case loyalty_card.BarcodeType.qrCode:
        // Already handled above
        break;
    }

    if (barcode == null) {
      return Container(
        width: width,
        height: height,
        color: bgColor,
        child: Center(
          child: Text(
            'Unsupported barcode type',
            style: TextStyle(color: fgColor),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: bgColor,
      padding: const EdgeInsets.all(16),
      child: BarcodeWidget(
        barcode: barcode,
        data: barcodeNumber,
        width: width != null ? width! - 32 : double.infinity,
        height: height != null ? height! - 32 : 100,
        color: fgColor,
        drawText: true,
      ),
    );
  }
}
