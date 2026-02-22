import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hr'),
    Locale('it')
  ];

  /// Primary save button used in all edit/add dialogs across every screen
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button — dialogs, CupertinoButton in unit-roller sheet (shopping_lists_screen), restore-backup dialog (settings_screen)
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button in delete_confirmation_dialog.dart
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// IconButton tooltip in loyalty_cards_screen, guarantees detail dialog action button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// AlertDialog action button in guarantees detail dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// ElevatedButton shown in every screen's error state (guarantees, loyalty_cards, notes, reminders, tasks, todos, settings, shopping, shopping_unified)
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// CupertinoButton in unit-roller sheet — shopping_lists_screen
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// TextButton in notification-status AlertDialog — main_navigation.dart
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Generic error display used in every screen's AsyncValue.error block
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// Error state in main_navigation.dart and shopping_unified_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading settings: {error}'**
  String errorLoadingSettings(String error);

  /// Subtitle when no date is selected — reminders_screen, tasks_screen, todos_screen Date & Time tile
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// ListTile title for date+time picker in reminders_screen, tasks_screen, todos_screen edit dialogs
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// Section label for priority selection in reminders_screen, tasks_screen, todos_screen edit dialogs
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// Section label for repeat-type selection in reminders_screen, tasks_screen, todos_screen edit dialogs
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// ListTile title for the pin toggle switch in loyalty_cards_screen and notes_screen edit dialogs
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// Section header for completed items in reminders_screen, tasks_screen, todos_screen; also filter menu item in todos_screen and tasks_screen
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Section header for overdue items in reminders_screen, tasks_screen, todos_screen
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// Time-period group label in reminders_screen._groupByTimePeriod and tasks_screen._groupByTimePeriod
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Time-period group label in reminders_screen._groupByTimePeriod and tasks_screen._groupByTimePeriod
  ///
  /// In en, this message translates to:
  /// **'Next 7 Days'**
  String get next7Days;

  /// Time-period group label in reminders_screen._groupByTimePeriod and tasks_screen._groupByTimePeriod
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Validation SnackBar in reminders_screen, tasks_screen, todos_screen save button
  ///
  /// In en, this message translates to:
  /// **'Please enter some text'**
  String get pleaseEnterSomeText;

  /// Validation SnackBar in reminders_screen, tasks_screen, todos_screen save button
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty'**
  String get titleCannotBeEmpty;

  /// RepeatType.none label — used in reminders_screen, tasks_screen, todos_screen repeat chip
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get repeatNone;

  /// RepeatType.daily label — reminders_screen, tasks_screen, todos_screen
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// RepeatType.weekly label — reminders_screen, tasks_screen, todos_screen
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// RepeatType.monthly label — reminders_screen, tasks_screen, todos_screen
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// RepeatType.yearly label — reminders_screen, tasks_screen, todos_screen
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeatYearly;

  /// Filter chip/menu item for 'All' in notes_screen tag filter, reminders_screen popup menu, todos_screen popup menu
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Filter menu item in todos_screen and tasks_screen
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Section label for color selection in notes_screen edit dialog
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// ChoiceChip label for 'no color' option in notes_screen color picker
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get colorNone;

  /// Section label in shopping_lists_screen unit-roller sheet header and edit-item dialog
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// AppBar title — brand_selection_screen.dart ~line 53
  ///
  /// In en, this message translates to:
  /// **'Select Brand'**
  String get brandSelectionTitle;

  /// hintText on search TextField — brand_selection_screen.dart ~line 68
  ///
  /// In en, this message translates to:
  /// **'Search brands...'**
  String get brandSearchHint;

  /// Text in the custom-brand InkWell card and AppBar title of _CustomBrandScreen — brand_selection_screen.dart ~lines 130, 327
  ///
  /// In en, this message translates to:
  /// **'Create Custom Brand'**
  String get createCustomBrand;

  /// Section label above brands grid — brand_selection_screen.dart ~line 155
  ///
  /// In en, this message translates to:
  /// **'Select a Brand'**
  String get selectABrand;

  /// Empty state text when brand search yields no results — brand_selection_screen.dart ~line 173
  ///
  /// In en, this message translates to:
  /// **'No brands found'**
  String get noBrandsFound;

  /// Section label above brand name TextField in _CustomBrandScreen — brand_selection_screen.dart ~line 370
  ///
  /// In en, this message translates to:
  /// **'Brand Name'**
  String get brandNameLabel;

  /// hintText on brand name TextField in _CustomBrandScreen — brand_selection_screen.dart ~line 378
  ///
  /// In en, this message translates to:
  /// **'Enter brand name'**
  String get brandNameHint;

  /// Section label above color picker in _CustomBrandScreen — brand_selection_screen.dart ~line 387
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// ElevatedButton.icon label in _CustomBrandScreen — brand_selection_screen.dart ~line 435
  ///
  /// In en, this message translates to:
  /// **'Continue to Scan'**
  String get continueToScan;

  /// AppBar title — guarantees_screen.dart ~line 34
  ///
  /// In en, this message translates to:
  /// **'Guarantees'**
  String get guaranteesTitle;

  /// Empty state text — guarantees_screen.dart ~line 61
  ///
  /// In en, this message translates to:
  /// **'No guarantees'**
  String get noGuarantees;

  /// Bottom-sheet dialog title when creating — guarantees_screen.dart ~line 171
  ///
  /// In en, this message translates to:
  /// **'Add Guarantee'**
  String get addGuarantee;

  /// Bottom-sheet dialog title when editing — guarantees_screen.dart ~line 171
  ///
  /// In en, this message translates to:
  /// **'Edit Guarantee'**
  String get editGuarantee;

  /// labelText on product name TextField — guarantees_screen.dart ~line 185
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productNameLabel;

  /// ListTile title and _DetailRow label — guarantees_screen.dart ~lines 200, 556
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDate;

  /// ListTile title and _DetailRow label — guarantees_screen.dart ~lines 218, 557
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// ElevatedButton.icon label for capturing warranty photo — guarantees_screen.dart ~line 267
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get warrantyPhotoButton;

  /// ElevatedButton.icon label for capturing receipt photo — guarantees_screen.dart ~line 283
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receiptPhotoButton;

  /// Status text shown after warranty photo is taken — guarantees_screen.dart ~line 299
  ///
  /// In en, this message translates to:
  /// **'Warranty photo captured'**
  String get warrantyPhotoCaptured;

  /// Status text shown after receipt photo is taken — guarantees_screen.dart ~line 301
  ///
  /// In en, this message translates to:
  /// **'Receipt photo captured'**
  String get receiptPhotoCaptured;

  /// labelText on notes TextField in guarantees and notes screens — guarantees_screen.dart ~line 317, notes_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// Label next to the reminder toggle switch in guarantee edit dialog — guarantees_screen.dart ~line 401
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminder;

  /// Label above reminder-months chip selector — guarantees_screen.dart ~line 418
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// ChoiceChip label when reminderMonthsBefore == 1 — guarantees_screen.dart ~lines 433, 459
  ///
  /// In en, this message translates to:
  /// **'{count} month before'**
  String reminderMonthsBeforeSingular(int count);

  /// ChoiceChip label when reminderMonthsBefore > 1 — guarantees_screen.dart ~lines 433, 459
  ///
  /// In en, this message translates to:
  /// **'{count} months before'**
  String reminderMonthsBeforePlural(int count);

  /// Bold label above warranty image in detail dialog — guarantees_screen.dart ~line 573
  ///
  /// In en, this message translates to:
  /// **'Warranty Photo:'**
  String get warrantyPhotoDetailLabel;

  /// Bold label above receipt image in detail dialog — guarantees_screen.dart ~line 581
  ///
  /// In en, this message translates to:
  /// **'Receipt Photo:'**
  String get receiptPhotoDetailLabel;

  /// Expiry date subtitle in _GuaranteeCard — guarantees_screen.dart ~line 655
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String guaranteeExpiresOn(String date);

  /// Status badge text on expired guarantee card — guarantees_screen.dart ~line 662
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get guaranteeExpired;

  /// Status badge text on soon-to-expire guarantee card — guarantees_screen.dart ~line 662
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get guaranteeExpiringSoon;

  /// AppBar title — loyalty_cards_screen.dart ~line 45
  ///
  /// In en, this message translates to:
  /// **'Loyalty Cards'**
  String get loyaltyCardsTitle;

  /// hintText on search TextField — loyalty_cards_screen.dart ~line 65
  ///
  /// In en, this message translates to:
  /// **'Search loyalty cards...'**
  String get loyaltyCardsSearchHint;

  /// Empty state when no cards and no search query — loyalty_cards_screen.dart ~line 107
  ///
  /// In en, this message translates to:
  /// **'No loyalty cards'**
  String get noLoyaltyCards;

  /// Empty state when search yields no results — loyalty_cards_screen.dart ~line 107
  ///
  /// In en, this message translates to:
  /// **'No cards found'**
  String get noCardsFound;

  /// SnackBar content after unpinning a card — loyalty_cards_screen.dart ~line 183
  ///
  /// In en, this message translates to:
  /// **'Card unpinned'**
  String get cardUnpinned;

  /// SnackBar content after pinning a card — loyalty_cards_screen.dart ~line 184
  ///
  /// In en, this message translates to:
  /// **'Card pinned to top'**
  String get cardPinnedToTop;

  /// IconButton tooltip on pin icon when card is pinned — loyalty_cards_screen.dart ~line 188
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get tooltipUnpin;

  /// IconButton tooltip on pin icon when card is not pinned — loyalty_cards_screen.dart ~line 188
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get tooltipPinToTop;

  /// IconButton tooltip on delete button in barcode-display sheet — loyalty_cards_screen.dart ~line 205
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tooltipDelete;

  /// Fallback card name when brand is null — loyalty_cards_screen.dart ~line 254
  ///
  /// In en, this message translates to:
  /// **'Loyalty Card'**
  String get defaultLoyaltyCardName;

  /// SnackBar after successfully adding a loyalty card — loyalty_cards_screen.dart ~line 260
  ///
  /// In en, this message translates to:
  /// **'Card \"{cardName}\" added successfully!'**
  String cardAddedSuccess(String cardName);

  /// Bottom-sheet title when creating a loyalty card — loyalty_cards_screen.dart ~line 436
  ///
  /// In en, this message translates to:
  /// **'Add Loyalty Card'**
  String get addLoyaltyCard;

  /// Bottom-sheet title when editing a loyalty card — loyalty_cards_screen.dart ~line 436
  ///
  /// In en, this message translates to:
  /// **'Edit Loyalty Card'**
  String get editLoyaltyCard;

  /// labelText on card name TextField — loyalty_cards_screen.dart ~line 470
  ///
  /// In en, this message translates to:
  /// **'Card Name'**
  String get cardNameLabel;

  /// Small label above selected brand name in brand-tile — loyalty_cards_screen.dart ~line 539
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandFieldLabel;

  /// Fallback brand name when no brand selected — loyalty_cards_screen.dart ~line 545
  ///
  /// In en, this message translates to:
  /// **'Generic Card'**
  String get genericCardFallback;

  /// labelText on barcode TextField — loyalty_cards_screen.dart ~line 576
  ///
  /// In en, this message translates to:
  /// **'Barcode Number'**
  String get barcodeNumberLabel;

  /// Label on scan barcode ElevatedButton.icon — loyalty_cards_screen.dart ~line 594
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanButtonLabel;

  /// Validation SnackBar when saving loyalty card without required fields — loyalty_cards_screen.dart ~line 634
  ///
  /// In en, this message translates to:
  /// **'Please fill in card name and barcode number'**
  String get fillInCardNameAndBarcode;

  /// AppBar title of inline barcode scanner screen — loyalty_cards_screen.dart ~line 686
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcodeTitle;

  /// IconButton tooltip for gallery image picker on scanner screen — loyalty_cards_screen.dart ~line 693
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get tooltipPickFromGallery;

  /// SnackBar when image scan finds no barcode — loyalty_cards_screen.dart ~line 801
  ///
  /// In en, this message translates to:
  /// **'No barcode found in the selected image'**
  String get noBarcodeFoundInImage;

  /// SnackBar on image scan error — loyalty_cards_screen.dart ~line 807
  ///
  /// In en, this message translates to:
  /// **'Error scanning image: {error}'**
  String errorScanningImage(String error);

  /// NavigationDestination label for Tasks — main_navigation.dart ~line 64
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// NavigationDestination label for Shopping — main_navigation.dart ~line 71
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// NavigationDestination label for Loyalty Cards — main_navigation.dart ~line 78
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get navCards;

  /// NavigationDestination label for Guarantees — main_navigation.dart ~line 85
  ///
  /// In en, this message translates to:
  /// **'Guarantees'**
  String get navGuarantees;

  /// NavigationDestination label for Notes — main_navigation.dart ~line 92
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// Empty-state headline when all sections are toggled off — main_navigation.dart ~line 130
  ///
  /// In en, this message translates to:
  /// **'No sections enabled'**
  String get noSectionsEnabled;

  /// Empty-state subtitle below noSectionsEnabled — main_navigation.dart ~line 136
  ///
  /// In en, this message translates to:
  /// **'Enable at least one section in Settings'**
  String get enableAtLeastOneSection;

  /// ElevatedButton.icon label in empty-state — main_navigation.dart ~line 143
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// DrawerHeader title text — main_navigation.dart ~line 162
  ///
  /// In en, this message translates to:
  /// **'Dev Mode'**
  String get devModeDrawerHeader;

  /// ListTile title in dev drawer — main_navigation.dart ~line 174
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// ListTile title in dev drawer — main_navigation.dart ~line 181
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get drawerTestNotification;

  /// ListTile subtitle in dev drawer — main_navigation.dart ~line 182
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get drawerTestNotificationSubtitle;

  /// SnackBar content after sending test notification — main_navigation.dart ~line 192
  ///
  /// In en, this message translates to:
  /// **'Test notification sent!'**
  String get testNotificationSent;

  /// ListTile title in dev drawer — main_navigation.dart ~line 198
  ///
  /// In en, this message translates to:
  /// **'Request Permissions'**
  String get drawerRequestPermissions;

  /// ListTile subtitle in dev drawer — main_navigation.dart ~line 199
  ///
  /// In en, this message translates to:
  /// **'Request notification permissions'**
  String get drawerRequestPermissionsSubtitle;

  /// SnackBar when permissions are granted — main_navigation.dart ~line 207
  ///
  /// In en, this message translates to:
  /// **'Notification permissions granted! ✅'**
  String get notificationPermissionsGranted;

  /// SnackBar when permissions are denied — main_navigation.dart ~line 208
  ///
  /// In en, this message translates to:
  /// **'Notification permissions denied. Please enable in settings.'**
  String get notificationPermissionsDenied;

  /// ListTile title in dev drawer — main_navigation.dart ~line 215
  ///
  /// In en, this message translates to:
  /// **'Check Notification Status'**
  String get drawerCheckNotificationStatus;

  /// ListTile subtitle in dev drawer — main_navigation.dart ~line 216
  ///
  /// In en, this message translates to:
  /// **'View notification status and pending notifications'**
  String get drawerCheckNotificationStatusSubtitle;

  /// AlertDialog title showing notification status — main_navigation.dart ~line 229
  ///
  /// In en, this message translates to:
  /// **'Notification Status'**
  String get notificationStatusDialogTitle;

  /// Row in notification-status dialog — main_navigation.dart ~line 234
  ///
  /// In en, this message translates to:
  /// **'Notifications Enabled: {status}'**
  String notificationsEnabledStatus(String status);

  /// Row in notification-status dialog — main_navigation.dart ~line 236
  ///
  /// In en, this message translates to:
  /// **'Pending Notifications: {count}'**
  String pendingNotificationsCount(int count);

  /// Bold label above pending notifications list — main_navigation.dart ~line 240
  ///
  /// In en, this message translates to:
  /// **'Pending:'**
  String get notificationStatusPendingHeader;

  /// Shown when pending notifications exceed 5 — main_navigation.dart ~line 244
  ///
  /// In en, this message translates to:
  /// **'... and {count} more'**
  String andNMore(int count);

  /// Warning text in notification-status dialog — main_navigation.dart ~line 249
  ///
  /// In en, this message translates to:
  /// **'⚠️ Notifications are disabled. Please enable them in Settings.'**
  String get notificationsDisabledWarning;

  /// ListTile title at bottom of dev drawer — main_navigation.dart ~line 259
  ///
  /// In en, this message translates to:
  /// **'Dev Mode - No Auth'**
  String get devModeNoAuth;

  /// ListTile subtitle in dev drawer — main_navigation.dart ~line 260
  ///
  /// In en, this message translates to:
  /// **'Authentication disabled for development'**
  String get devModeNoAuthSubtitle;

  /// AppBar title — notes_screen.dart ~line 42
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// hintText on search TextField — notes_screen.dart ~line 63
  ///
  /// In en, this message translates to:
  /// **'Search notes...'**
  String get notesSearchHint;

  /// Empty state text — notes_screen.dart ~line 114
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get noNotes;

  /// Bottom-sheet title when creating — notes_screen.dart ~line 295
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// Bottom-sheet title when editing — notes_screen.dart ~line 295
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// labelText on title TextField in note edit dialog — notes_screen.dart ~line 318
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitleLabel;

  /// labelText on content TextField in note edit dialog — notes_screen.dart ~line 338
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get noteContentLabel;

  /// labelText on tags TextField in note edit dialog — notes_screen.dart ~line 360
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get noteTagsLabel;

  /// hintText on tags TextField — notes_screen.dart ~line 361
  ///
  /// In en, this message translates to:
  /// **'work, personal, ideas'**
  String get noteTagsHint;

  /// AppBar title — reminders_screen.dart ~line 41
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// Empty state text — reminders_screen.dart ~line 94
  ///
  /// In en, this message translates to:
  /// **'No reminders'**
  String get noReminders;

  /// Bottom-sheet title when creating — reminders_screen.dart ~line 437
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// Bottom-sheet title when editing — reminders_screen.dart ~line 437
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// hintText on main text field in reminder edit dialog — reminders_screen.dart ~line 460
  ///
  /// In en, this message translates to:
  /// **'Add your reminder here'**
  String get addReminderHint;

  /// Section label above type selector — reminders_screen.dart ~line 505
  ///
  /// In en, this message translates to:
  /// **'Reminder type'**
  String get reminderTypeLabel;

  /// ReminderType.birthday display name shown in type chips
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get reminderTypeBirthday;

  /// ReminderType.appointment display name shown in type chips
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get reminderTypeAppointment;

  /// ReminderType.todo display label in reminder type chips (note: tasks_screen uses 'To-Do' via _getTypeLabel)
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get reminderTypeTodo;

  /// ReminderType.other display name — reminders_screen type chip
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reminderTypeOther;

  /// AppBar title — settings_screen.dart ~line 29
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Section title — settings_screen.dart ~line 56
  ///
  /// In en, this message translates to:
  /// **'App Sections'**
  String get settingsAppSectionsHeader;

  /// Section subtitle — settings_screen.dart ~line 60
  ///
  /// In en, this message translates to:
  /// **'Select which sections you want to see in the app'**
  String get settingsAppSectionsSubtitle;

  /// Toggle title for Tasks section — settings_screen.dart ~line 68
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get sectionTasks;

  /// Toggle title for Shopping Lists section — settings_screen.dart ~line 75
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get sectionShoppingLists;

  /// Toggle title for Guarantees section — settings_screen.dart ~line 82
  ///
  /// In en, this message translates to:
  /// **'Guarantees'**
  String get sectionGuarantees;

  /// Toggle title for Notes section — settings_screen.dart ~line 89
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get sectionNotes;

  /// Toggle title for Loyalty Cards section — settings_screen.dart ~line 96
  ///
  /// In en, this message translates to:
  /// **'Loyalty Cards'**
  String get sectionLoyaltyCards;

  /// Section title — settings_screen.dart ~line 104
  ///
  /// In en, this message translates to:
  /// **'Color Scheme'**
  String get settingsColorSchemeHeader;

  /// Section subtitle — settings_screen.dart ~line 108
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred color theme'**
  String get settingsColorSchemeSubtitle;

  /// Section title — settings_screen.dart ~line 114
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get settingsBackupHeader;

  /// Section subtitle — settings_screen.dart ~line 118
  ///
  /// In en, this message translates to:
  /// **'Backup your data to transfer to a new device'**
  String get settingsBackupSubtitle;

  /// Warning text when all sections are disabled — settings_screen.dart ~line 130
  ///
  /// In en, this message translates to:
  /// **'At least one section must be enabled'**
  String get settingsAtLeastOneSection;

  /// Section title — settings_screen.dart ~line 141
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutHeader;

  /// Section subtitle — settings_screen.dart ~line 145
  ///
  /// In en, this message translates to:
  /// **'Legal information and app details'**
  String get settingsAboutSubtitle;

  /// Shows formatted last backup date — settings_screen.dart ~line 406
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String backupLastDate(String date);

  /// Shown when no backup exists — settings_screen.dart ~line 417
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get backupNeverBackedUp;

  /// ElevatedButton.icon label — settings_screen.dart ~line 430
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackupButton;

  /// ElevatedButton.icon label — settings_screen.dart ~line 440
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreButton;

  /// Toggle label for backup reminder switch — settings_screen.dart ~line 459
  ///
  /// In en, this message translates to:
  /// **'Backup Reminders'**
  String get backupRemindersToggle;

  /// Label above backup reminder frequency segmented button — settings_screen.dart ~line 469
  ///
  /// In en, this message translates to:
  /// **'Reminder Frequency'**
  String get reminderFrequencyLabel;

  /// ButtonSegment labels: '7 days', '14 days', '30 days' — settings_screen.dart ~line 476
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String frequencyDays(int count);

  /// ListTile title in About section — settings_screen.dart ~line 499
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// ListTile title in About section — settings_screen.dart ~line 510
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// ListTile title in About section — settings_screen.dart ~line 522
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// SnackBar when URL fails to launch — settings_screen.dart ~line 539
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpenUrl(String url);

  /// SnackBar on link-launch exception — settings_screen.dart ~line 545
  ///
  /// In en, this message translates to:
  /// **'Error opening link: {error}'**
  String errorOpeningLink(String error);

  /// _formatBackupDate return value — settings_screen.dart ~line 557
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get backupDateToday;

  /// _formatBackupDate return value — settings_screen.dart ~line 559
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get backupDateYesterday;

  /// _formatBackupDate return value — settings_screen.dart ~line 561
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String backupDateDaysAgo(int count);

  /// _formatBackupDate singular week — settings_screen.dart ~line 563
  ///
  /// In en, this message translates to:
  /// **'{count} week ago'**
  String backupDateWeekAgo(int count);

  /// _formatBackupDate plural weeks — settings_screen.dart ~line 563
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String backupDateWeeksAgo(int count);

  /// _formatBackupDate singular month — settings_screen.dart ~line 565
  ///
  /// In en, this message translates to:
  /// **'{count} month ago'**
  String backupDateMonthAgo(int count);

  /// _formatBackupDate plural months — settings_screen.dart ~line 565
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String backupDateMonthsAgo(int count);

  /// AlertDialog title — settings_screen.dart ~line 575
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackupDialogTitle;

  /// AlertDialog content text — settings_screen.dart ~line 576
  ///
  /// In en, this message translates to:
  /// **'How would you like to restore the backup?\n\n• Replace: Delete all current data and restore from backup\n• Merge: Combine backup data with current data'**
  String get restoreBackupDialogContent;

  /// TextButton label in restore dialog — settings_screen.dart ~line 584
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get restoreMerge;

  /// TextButton label in restore dialog — settings_screen.dart ~line 587
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get restoreReplace;

  /// SnackBar after successful backup export — settings_screen.dart ~line 608
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully!'**
  String get backupCreatedSuccess;

  /// SnackBar when backup export is cancelled — settings_screen.dart ~line 616
  ///
  /// In en, this message translates to:
  /// **'Backup cancelled'**
  String get backupCancelled;

  /// SnackBar on backup creation error — settings_screen.dart ~line 624
  ///
  /// In en, this message translates to:
  /// **'Error creating backup: {error}'**
  String errorCreatingBackup(String error);

  /// SnackBar after successful restore — settings_screen.dart ~line 659
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully! Data reloaded.'**
  String get backupRestoredSuccess;

  /// SnackBar when restore is cancelled — settings_screen.dart ~line 666
  ///
  /// In en, this message translates to:
  /// **'Restore cancelled'**
  String get restoreCancelled;

  /// SnackBar on restore error — settings_screen.dart ~line 674
  ///
  /// In en, this message translates to:
  /// **'Error restoring backup: {error}'**
  String errorRestoringBackup(String error);

  /// AppBar title — shopping_lists_screen.dart ~line 36
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get shoppingListsTitle;

  /// IconButton tooltip for import button — shopping_lists_screen.dart ~line 48, shopping_unified_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get tooltipImportCsv;

  /// Empty state — shopping_lists_screen.dart ~line 68
  ///
  /// In en, this message translates to:
  /// **'No shopping lists'**
  String get noShoppingLists;

  /// SnackBar after successful CSV import — shopping_lists_screen.dart ~line 127, shopping_unified_screen.dart ~line 40
  ///
  /// In en, this message translates to:
  /// **'Imported \"{name}\" with {itemCount} items'**
  String importedListSuccess(String name, int itemCount);

  /// SnackBar on import failure — shopping_lists_screen.dart ~line 134, shopping_unified_screen.dart ~line 47
  ///
  /// In en, this message translates to:
  /// **'Failed to import: {error}'**
  String failedToImport(String error);

  /// SnackBar after successful CSV export — shopping_lists_screen.dart ~line 152
  ///
  /// In en, this message translates to:
  /// **'Shopping list exported!'**
  String get shoppingListExported;

  /// SnackBar on export failure — shopping_lists_screen.dart ~line 162
  ///
  /// In en, this message translates to:
  /// **'Failed to export: {error}'**
  String failedToExport(String error);

  /// IconButton tooltip on shopping list card export button — shopping_lists_screen.dart ~line 312
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get tooltipExportAsCsv;

  /// Item count subtitle on shopping list card — shopping_lists_screen.dart ~line 291
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} items'**
  String shoppingListItemsCount(int completed, int total);

  /// hintText on editable list-name TextField in AppBar — shopping_lists_screen.dart ~line 443
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get shoppingListNameHint;

  /// Empty state text in ShoppingListDetailScreen — shopping_lists_screen.dart ~line 460
  ///
  /// In en, this message translates to:
  /// **'No items yet\nStart adding below!'**
  String get shoppingListEmptyState;

  /// Header label above suggestion strip — shopping_lists_screen.dart ~line 652
  ///
  /// In en, this message translates to:
  /// **'Restore checked item'**
  String get restoreCheckedItemLabel;

  /// hintText on item name input field — shopping_lists_screen.dart ~line 697
  ///
  /// In en, this message translates to:
  /// **'Item name…'**
  String get itemNameHint;

  /// SnackBar when adding an already-active item — shopping_lists_screen.dart ~line 757
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is already on the list'**
  String itemAlreadyOnList(String name);

  /// Bottom-sheet title for editing a shopping item — shopping_lists_screen.dart ~line 822
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItemDialogTitle;

  /// labelText on item name field in edit-item dialog — shopping_lists_screen.dart ~line 840
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemNameLabel;

  /// labelText on quantity field in edit-item dialog — shopping_lists_screen.dart ~line 857
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// Validation SnackBar in edit-item dialog save — shopping_lists_screen.dart ~line 896
  ///
  /// In en, this message translates to:
  /// **'Please enter an item name'**
  String get pleaseEnterItemName;

  /// AppBar title when both shopping & loyalty tabs are shown — shopping_unified_screen.dart ~line 77
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shoppingTitle;

  /// Fallback center text when neither shopping nor loyalty cards enabled — shopping_unified_screen.dart ~line 120
  ///
  /// In en, this message translates to:
  /// **'No sections enabled'**
  String get noSectionsEnabledShopping;

  /// Tab label in TabBar — shopping_unified_screen.dart ~line 107
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get tabShoppingLists;

  /// Tab label in TabBar — shopping_unified_screen.dart ~line 111
  ///
  /// In en, this message translates to:
  /// **'Loyalty Cards'**
  String get tabLoyaltyCards;

  /// AppBar title — tasks_screen.dart ~line 27
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// Filter menu item and _filterLabel() — tasks_screen.dart ~lines 72, 1049
  ///
  /// In en, this message translates to:
  /// **'All Tasks'**
  String get filterAllTasks;

  /// Filter menu item — tasks_screen.dart ~line 74
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get filterReminders;

  /// Filter menu item and _filterLabel() — tasks_screen.dart ~lines 76, 1051
  ///
  /// In en, this message translates to:
  /// **'Todos'**
  String get filterTodos;

  /// Empty state text — tasks_screen.dart ~line 1061
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasks;

  /// Secondary empty-state line showing active filter name — tasks_screen.dart ~line 1068
  ///
  /// In en, this message translates to:
  /// **'Filter: {filter}'**
  String tasksFilterActive(String filter);

  /// Section header for tasks without a date — tasks_screen.dart ~line 1108
  ///
  /// In en, this message translates to:
  /// **'No Date'**
  String get sectionNoDate;

  /// Section header for high-priority todos without date — tasks_screen.dart ~line 1112
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get sectionHighPriority;

  /// Section header for medium-priority todos without date — tasks_screen.dart ~line 1113
  ///
  /// In en, this message translates to:
  /// **'Medium Priority'**
  String get sectionMediumPriority;

  /// Section header for low-priority todos without date — tasks_screen.dart ~line 1114
  ///
  /// In en, this message translates to:
  /// **'Low Priority'**
  String get sectionLowPriority;

  /// Bottom-sheet title when creating a task — tasks_screen.dart ~line 211
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Bottom-sheet title when editing a task — tasks_screen.dart ~line 211
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// hintText on main text field in task edit dialog — tasks_screen.dart ~line 237
  ///
  /// In en, this message translates to:
  /// **'Add your task here'**
  String get addTaskHint;

  /// Section label above type selector — tasks_screen.dart ~line 284
  ///
  /// In en, this message translates to:
  /// **'Task type'**
  String get taskTypeLabel;

  /// _getTypeLabel(ReminderType.birthday) — tasks_screen.dart ~line 895
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get taskTypeBirthday;

  /// _getTypeLabel(ReminderType.appointment) — tasks_screen.dart ~line 897
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get taskTypeAppointment;

  /// _getTypeLabel(ReminderType.todo) — tasks_screen.dart ~line 899
  ///
  /// In en, this message translates to:
  /// **'To-Do'**
  String get taskTypeToDo;

  /// _getTypeLabel(ReminderType.warranty) — tasks_screen.dart ~line 901
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get taskTypeWarranty;

  /// _getTypeLabel(ReminderType.other) — tasks_screen.dart ~line 903
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get taskTypeOther;

  /// AppBar title — todos_screen.dart ~line 42
  ///
  /// In en, this message translates to:
  /// **'To-Dos'**
  String get todosTitle;

  /// Empty state text — todos_screen.dart ~line 94
  ///
  /// In en, this message translates to:
  /// **'No to-dos'**
  String get noTodos;

  /// Bottom-sheet title when creating — todos_screen.dart ~line 421
  ///
  /// In en, this message translates to:
  /// **'Add To-Do'**
  String get addToDo;

  /// Bottom-sheet title when editing — todos_screen.dart ~line 421
  ///
  /// In en, this message translates to:
  /// **'Edit To-Do'**
  String get editToDo;

  /// hintText on main text field in to-do edit dialog — todos_screen.dart ~line 444
  ///
  /// In en, this message translates to:
  /// **'Add your to-do here'**
  String get addToDoHint;

  /// Default dialog content when no custom message is provided — delete_confirmation_dialog.dart ~line 21
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteDialogDefaultMessage;

  /// Section title for language selection in settings_screen
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageHeader;

  /// Section subtitle for language selection
  ///
  /// In en, this message translates to:
  /// **'Choose the app language'**
  String get settingsLanguageSubtitle;

  /// Option to follow device system locale
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Croatian language option
  ///
  /// In en, this message translates to:
  /// **'Hrvatski (Croatian)'**
  String get languageCroatian;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'Deutsch (German)'**
  String get languageGerman;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Español (Spanish)'**
  String get languageSpanish;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'Français (French)'**
  String get languageFrench;

  /// Italian language option
  ///
  /// In en, this message translates to:
  /// **'Italiano (Italian)'**
  String get languageItalian;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'hr',
        'it'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hr':
      return AppLocalizationsHr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
