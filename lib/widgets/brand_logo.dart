import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandLogo extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? fallbackColor;
  final Color? forceColor;

  const BrandLogo({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackColor,
    this.forceColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSvg = assetPath.toLowerCase().endsWith('.svg');
    final normalizedPath = assetPath.toLowerCase();
    final effectiveForceColor =
        forceColor ?? (normalizedPath.contains('optikaanda.png') ? Colors.white : null);

    // If width/height are provided, respect them (used for small icons/previews).
    // Otherwise, expand to the parent's constraints so wide/short logos don't render
    // at their tiny intrinsic SVG size.
    if (isSvg) {
      final svg = SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        colorFilter: effectiveForceColor == null
            ? null
            : ColorFilter.mode(effectiveForceColor, BlendMode.srcIn),
        placeholderBuilder: (context) => _buildFallback(),
      );

      if (width != null || height != null) return svg;

      return LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: svg,
        ),
      );
    } else {
      final image = Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
      final maybeTinted = effectiveForceColor == null
          ? image
          : ColorFiltered(
        colorFilter: ColorFilter.mode(effectiveForceColor, BlendMode.srcIn),
        child: image,
      );

      if (width != null || height != null) return maybeTinted;

      return LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: maybeTinted,
        ),
      );
    }
  }

  Widget _buildFallback() {
    return Icon(
      Icons.card_membership,
      color: fallbackColor ?? Colors.grey,
      size: width ?? height ?? 24,
    );
  }
}
