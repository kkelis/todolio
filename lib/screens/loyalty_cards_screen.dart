import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:image_picker/image_picker.dart';
import '../models/loyalty_card.dart' as loyalty_card;
import '../models/loyalty_card.dart';
import '../models/brand.dart';
import '../providers/loyalty_cards_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/gradient_background.dart';
import '../utils/undo_deletion_helper.dart';
import '../widgets/barcode_display_widget.dart';
import '../widgets/brand_logo.dart';
import 'settings_screen.dart';
import 'brand_selection_screen.dart';
import '../l10n/app_localizations.dart';

class LoyaltyCardsScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  
  const LoyaltyCardsScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<LoyaltyCardsScreen> createState() => _LoyaltyCardsScreenState();
}

class _LoyaltyCardsScreenState extends ConsumerState<LoyaltyCardsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cardsAsync = ref.watch(loyaltyCardsProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(l10n.loyaltyCardsTitle),
                leading: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              )
            : null,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.loyaltyCardsSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
            ),
            Expanded(
              child: cardsAsync.when(
                data: (cards) {
                  // Filter by search query
                  var filteredCards = cards.where((card) {
                    return _searchQuery.isEmpty ||
                        card.cardName.toLowerCase().contains(_searchQuery) ||
                        card.barcodeNumber.toLowerCase().contains(_searchQuery);
                  }).toList();

                  // Sort: pinned first, then alphabetical by card name
                  filteredCards.sort((a, b) {
                    if (a.isPinned && !b.isPinned) return -1;
                    if (!a.isPinned && b.isPinned) return 1;
                    return a.cardName.toLowerCase().compareTo(b.cardName.toLowerCase());
                  });

                  if (filteredCards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_membership_outlined,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _searchQuery.isEmpty ? l10n.noLoyaltyCards : l10n.noCardsFound,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(loyaltyCardsProvider);
                    },
                    color: Theme.of(context).colorScheme.primary,
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: filteredCards.length,
                      itemBuilder: (context, index) {
                        final card = filteredCards[index];
                        return _LoyaltyCardCard(
                          card: card,
                          onTap: () => _showBarcodeDisplay(card),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.errorWithDetails(error.toString())),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(loyaltyCardsProvider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            final appSettingsNotifier = ref.watch(appSettingsNotifierProvider);
            final primaryColor = appSettingsNotifier.hasValue
                ? appSettingsNotifier.value!.colorScheme.primaryColor
                : Theme.of(context).colorScheme.primary;

            return FloatingActionButton(
              onPressed: () => _showBrandSelection(),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  void _showBarcodeDisplay(LoyaltyCard card) {
    final l10n = AppLocalizations.of(context);
    final brand = card.brandId != null
        ? BrandDatabase.getBrandById(card.brandId!)
        : null;
    final brandColor = brand?.primaryColor ??
        (card.brandPrimaryColor != null
            ? Color(card.brandPrimaryColor!)
            : Theme.of(context).colorScheme.primary);
    final logoAssetPath = brand?.logoAssetPath ?? card.brandLogoAssetPath;
    final isWhiteBackground = brandColor.computeLuminance() > 0.5;
    final textColor = isWhiteBackground ? Colors.black87 : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: brandColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header with close, edit, delete
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.cardName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          card.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          color: textColor,
                        ),
                        onPressed: () {
                          final notifier = ref.read(loyaltyCardsNotifierProvider.notifier);
                          final updatedCard = card.copyWith(isPinned: !card.isPinned);
                          notifier.updateLoyaltyCard(updatedCard);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                card.isPinned
                                    ? l10n.cardUnpinned
                                    : l10n.cardPinnedToTop,
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        tooltip: card.isPinned ? l10n.tooltipUnpin : l10n.tooltipPinToTop,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: textColor),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDialog(card);
                        },
                        tooltip: l10n.edit,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: textColor),
                        onPressed: () async {
                          Navigator.pop(context);
                          if (!context.mounted) return;
                          final cardCopy = card;
                          final notifier = ref.read(loyaltyCardsNotifierProvider.notifier);
                          notifier.deleteLoyaltyCard(card.id);
                          showUndoDeletionSnackBar(
                            context,
                            itemName: card.cardName,
                            onUndo: () {
                              notifier.createLoyaltyCard(cardCopy);
                            },
                          );
                        },
                        tooltip: l10n.tooltipDelete,
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Brand logo if available
            if (logoAssetPath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 60,
                  child: BrandLogo(
                    assetPath: logoAssetPath,
                    height: 60,
                    fallbackColor: textColor,
                  ),
                ),
              ),
            // Barcode on white background
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: BarcodeDisplayWidget(
                      barcodeNumber: card.barcodeNumber,
                      barcodeType: card.barcodeType,
                      width: MediaQuery.of(context).size.width - 96,
                      height: 300,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showBrandSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrandSelectionScreen(
          onBrandSelected: (brand) {
            // Cancel/back should just close the selector, not start scanning.
            if (brand == null) return;
            _showBarcodeScannerWithBrand(context, brand);
          },
        ),
      ),
    );
  }

  void _showBarcodeScannerWithBrand(BuildContext context, Brand? brand) {
    final l10n = AppLocalizations.of(context);
    _showBarcodeScanner(
      context,
      (barcode, type) {
        // Create card with brand info
        final newCard = LoyaltyCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          cardName: brand?.name ?? l10n.defaultLoyaltyCardName,
          barcodeNumber: barcode,
          barcodeType: type,
          cardImagePath: null,
          notes: null,
          createdAt: DateTime.now(),
          isPinned: false,
          brandId: brand?.id,
          brandPrimaryColor: brand?.primaryColor.toARGB32(),
          brandLogoAssetPath: brand?.logoAssetPath,
        );

        final notifier = ref.read(loyaltyCardsNotifierProvider.notifier);
        notifier.createLoyaltyCard(newCard);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cardAddedSuccess(newCard.cardName)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  void _showEditDialog(LoyaltyCard? card) async {
    final cardNameController = TextEditingController(text: card?.cardName ?? '');
    final barcodeNumberController = TextEditingController(text: card?.barcodeNumber ?? '');
    loyalty_card.BarcodeType barcodeType = card?.barcodeType ?? loyalty_card.BarcodeType.ean13;
    bool isPinned = card?.isPinned ?? false;
    Brand? selectedBrand = card?.brandId != null
        ? BrandDatabase.getBrandById(card!.brandId!)
        : null;
    
    // If brand lookup failed but we have brand data stored (custom brands), reconstruct it
    if (selectedBrand == null && card?.brandId != null && card?.brandLogoAssetPath != null) {
      selectedBrand = Brand(
        id: card!.brandId!,
        name: card.cardName,
        logoAssetPath: card.brandLogoAssetPath!,
        primaryColor: card.brandPrimaryColor != null 
            ? Color(card.brandPrimaryColor!) 
            : Theme.of(context).colorScheme.primary,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          return StatefulBuilder(
            builder: (context, setState) {
              final l10n = AppLocalizations.of(context);
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              card == null ? l10n.addLoyaltyCard : l10n.editLoyaltyCard,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        TextField(
                          controller: cardNameController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: l10n.cardNameLabel,
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Brand selection
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BrandSelectionScreen(
                                  onBrandSelected: (brand) {
                                    // BrandSelectionScreen handles its own pop.
                                    // Re-open the edit sheet with updated (or unchanged) brand.
                                    final updatedCard = brand == null
                                        ? card
                                        : card?.copyWith(
                                              brandId: brand.id,
                                              brandPrimaryColor: brand.primaryColor.toARGB32(),
                                              brandLogoAssetPath: brand.logoAssetPath,
                                              cardName: brand.name,
                                            );
                                    _showEditDialog(updatedCard);
                                  },
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                if (selectedBrand != null)
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: selectedBrand.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: selectedBrand.primaryColor.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: BrandLogo(
                                        assetPath: selectedBrand.logoAssetPath,
                                        width: 40,
                                        height: 40,
                                        fallbackColor: selectedBrand.primaryColor,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.card_membership,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.brandFieldLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedBrand?.name ?? l10n.genericCardFallback,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: barcodeNumberController,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: l10n.barcodeNumberLabel,
                                  labelStyle: TextStyle(color: Colors.grey.shade700),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              onPressed: () => _showBarcodeScanner(
                                context,
                                (barcode, type) {
                                  setState(() {
                                    barcodeNumberController.text = barcode;
                                    barcodeType = type;
                                  });
                                },
                              ),
                              icon: const Icon(Icons.qr_code_scanner),
                              label: Text(l10n.scanButtonLabel),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(
                            l10n.pinned,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Switch(
                            value: isPinned,
                            onChanged: (value) => setState(() => isPinned = value),
                            activeTrackColor: Theme.of(context).colorScheme.primary,
                            activeThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade300,
                            inactiveThumbColor: Colors.white,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              if (cardNameController.text.isEmpty ||
                                  barcodeNumberController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.fillInCardNameAndBarcode),
                                  ),
                                );
                                return;
                              }

                              final newCard = LoyaltyCard(
                                id: card?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                cardName: cardNameController.text,
                                barcodeNumber: barcodeNumberController.text,
                                barcodeType: barcodeType,
                                cardImagePath: null,
                                notes: null,
                                createdAt: card?.createdAt ?? DateTime.now(),
                                isPinned: isPinned,
                                brandId: selectedBrand?.id ?? card?.brandId,
                                brandPrimaryColor: selectedBrand?.primaryColor.toARGB32() ??
                                    card?.brandPrimaryColor,
                                brandLogoAssetPath: selectedBrand?.logoAssetPath ?? card?.brandLogoAssetPath,
                              );

                              final notifier = ref.read(loyaltyCardsNotifierProvider.notifier);
                              if (card?.id == newCard.id) {
                                notifier.updateLoyaltyCard(newCard);
                              } else {
                                notifier.createLoyaltyCard(newCard);
                              }

                              Navigator.pop(context);
                            },
                            child: Text(l10n.save),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBarcodeScanner(
    BuildContext context,
    Function(String barcode, loyalty_card.BarcodeType type) onScanned,
  ) {
    final l10n = AppLocalizations.of(context);
    final controller = mobile_scanner.MobileScannerController(
      detectionSpeed: mobile_scanner.DetectionSpeed.noDuplicates,
      facing: mobile_scanner.CameraFacing.back,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.scanBarcodeTitle),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: const Icon(Icons.photo_library, color: Colors.white),
                onPressed: () => _pickImageAndScan(context, controller, onScanned),
                tooltip: l10n.tooltipPickFromGallery,
              ),
              IconButton(
                icon: const Icon(Icons.flash_on, color: Colors.white),
                onPressed: () => controller.toggleTorch(),
              ),
            ],
          ),
          body: mobile_scanner.MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<mobile_scanner.Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  final rawValue = barcode.rawValue!;
                  loyalty_card.BarcodeType detectedType = loyalty_card.BarcodeType.ean13;

                  // Map mobile_scanner BarcodeFormat to our BarcodeType
                  switch (barcode.format) {
                    case mobile_scanner.BarcodeFormat.ean13:
                      detectedType = loyalty_card.BarcodeType.ean13;
                      break;
                    case mobile_scanner.BarcodeFormat.code128:
                      detectedType = loyalty_card.BarcodeType.code128;
                      break;
                    case mobile_scanner.BarcodeFormat.qrCode:
                      detectedType = loyalty_card.BarcodeType.qrCode;
                      break;
                    case mobile_scanner.BarcodeFormat.upcA:
                      detectedType = loyalty_card.BarcodeType.upcA;
                      break;
                    default:
                      // Try to infer from format
                      if (rawValue.length == 13 && RegExp(r'^\d+$').hasMatch(rawValue)) {
                        detectedType = loyalty_card.BarcodeType.ean13;
                      } else if (rawValue.length == 12 && RegExp(r'^\d+$').hasMatch(rawValue)) {
                        detectedType = loyalty_card.BarcodeType.upcA;
                      } else {
                        detectedType = loyalty_card.BarcodeType.code128;
                      }
                  }

                  controller.stop();
                  Navigator.pop(context);
                  onScanned(rawValue, detectedType);
                  return;
                }
              }
            },
          ),
        ),
      ),
    ).then((_) => controller.dispose());
  }

  Future<void> _pickImageAndScan(
    BuildContext context,
    mobile_scanner.MobileScannerController controller,
    Function(String barcode, loyalty_card.BarcodeType type) onScanned,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    if (!context.mounted) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final mobile_scanner.BarcodeCapture? capture = 
          await controller.analyzeImage(image.path);

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (capture != null && capture.barcodes.isNotEmpty) {
        for (final barcode in capture.barcodes) {
          if (barcode.rawValue != null) {
            final rawValue = barcode.rawValue!;
            loyalty_card.BarcodeType detectedType = loyalty_card.BarcodeType.ean13;

            // Map mobile_scanner BarcodeFormat to our BarcodeType
            switch (barcode.format) {
              case mobile_scanner.BarcodeFormat.ean13:
                detectedType = loyalty_card.BarcodeType.ean13;
                break;
              case mobile_scanner.BarcodeFormat.code128:
                detectedType = loyalty_card.BarcodeType.code128;
                break;
              case mobile_scanner.BarcodeFormat.qrCode:
                detectedType = loyalty_card.BarcodeType.qrCode;
                break;
              case mobile_scanner.BarcodeFormat.upcA:
                detectedType = loyalty_card.BarcodeType.upcA;
                break;
              default:
                // Try to infer from format
                if (rawValue.length == 13 && RegExp(r'^\d+$').hasMatch(rawValue)) {
                  detectedType = loyalty_card.BarcodeType.ean13;
                } else if (rawValue.length == 12 && RegExp(r'^\d+$').hasMatch(rawValue)) {
                  detectedType = loyalty_card.BarcodeType.upcA;
                } else {
                  detectedType = loyalty_card.BarcodeType.code128;
                }
            }

            controller.stop();
            Navigator.pop(context); // Close scanner screen
            onScanned(rawValue, detectedType);
            return;
          }
        }
      }

      // No barcode found in image
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noBarcodeFoundInImage),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorScanningImage(e.toString())),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class _LoyaltyCardCard extends StatelessWidget {
  final LoyaltyCard card;
  final VoidCallback onTap;

  const _LoyaltyCardCard({
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brand = card.brandId != null
        ? BrandDatabase.getBrandById(card.brandId!)
        : null;
    final cardColor = brand?.primaryColor ??
        (card.brandPrimaryColor != null
            ? Color(card.brandPrimaryColor!)
            : Theme.of(context).colorScheme.primary);
    final logoAssetPath = brand?.logoAssetPath ?? card.brandLogoAssetPath;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card with brand color background
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Logo in center
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: logoAssetPath != null
                          ? BrandLogo(
                              assetPath: logoAssetPath,
                              fallbackColor: Colors.white,
                            )
                          : Icon(
                              Icons.card_membership,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                    ),
                  ),
                  // Pin indicator
                  if (card.isPinned)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
