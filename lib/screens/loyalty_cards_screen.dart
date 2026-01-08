import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import '../models/loyalty_card.dart' as loyalty_card;
import '../models/loyalty_card.dart';
import '../providers/loyalty_cards_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/gradient_background.dart';
import '../utils/undo_deletion_helper.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/barcode_display_widget.dart';
import 'settings_screen.dart';

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
    final cardsAsync = ref.watch(loyaltyCardsProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: widget.showAppBar
            ? AppBar(
                title: const Text('Loyalty Cards'),
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
                  hintText: 'Search loyalty cards...',
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
                            _searchQuery.isEmpty ? 'No loyalty cards' : 'No cards found',
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
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredCards.length,
                      itemBuilder: (context, index) {
                        final card = filteredCards[index];
                        return _LoyaltyCardCard(
                          card: card,
                          onTap: () => _showBarcodeDisplay(card),
                          onEdit: () => _showEditDialog(card),
                          onDelete: () async {
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
                      Text('Error: $error'),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(loyaltyCardsProvider),
                        child: const Text('Retry'),
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
              onPressed: () => _showEditDialog(null),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.cardName,
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
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: BarcodeDisplayWidget(
                      barcodeNumber: card.barcodeNumber,
                      barcodeType: card.barcodeType,
                      width: MediaQuery.of(context).size.width - 48,
                      height: 300,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(LoyaltyCard? card) async {
    final cardNameController = TextEditingController(text: card?.cardName ?? '');
    final barcodeNumberController = TextEditingController(text: card?.barcodeNumber ?? '');
    loyalty_card.BarcodeType barcodeType = card?.barcodeType ?? loyalty_card.BarcodeType.ean13;
    bool isPinned = card?.isPinned ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
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
                              card == null ? 'Add Loyalty Card' : 'Edit Loyalty Card',
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
                            labelText: 'Card Name',
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
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: barcodeNumberController,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Barcode Number',
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
                              label: const Text('Scan'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FormField<loyalty_card.BarcodeType>(
                          initialValue: barcodeType,
                          builder: (field) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Barcode Type',
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
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<loyalty_card.BarcodeType>(
                                  value: barcodeType,
                                  isDense: true,
                                  items: loyalty_card.BarcodeType.values.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type.displayName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => barcodeType = value);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(
                            'Pinned',
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
                                  const SnackBar(
                                    content: Text('Please fill in card name and barcode number'),
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
                              );

                              final notifier = ref.read(loyaltyCardsNotifierProvider.notifier);
                              if (card?.id == newCard.id) {
                                notifier.updateLoyaltyCard(newCard);
                              } else {
                                notifier.createLoyaltyCard(newCard);
                              }

                              Navigator.pop(context);
                            },
                            child: const Text('Save'),
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
    final controller = mobile_scanner.MobileScannerController(
      detectionSpeed: mobile_scanner.DetectionSpeed.noDuplicates,
      facing: mobile_scanner.CameraFacing.back,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Scan Barcode'),
            backgroundColor: Colors.black,
            actions: [
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
}

class _LoyaltyCardCard extends StatelessWidget {
  final LoyaltyCard card;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _LoyaltyCardCard({
    required this.card,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassmorphicCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              card.isPinned ? Icons.push_pin : Icons.card_membership,
              color: theme.colorScheme.primary.withValues(alpha: 1.0),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.cardName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 13,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      card.barcodeType.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 22,
                  color: Colors.grey[700],
                ),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Edit',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 22,
                  color: Colors.red,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
