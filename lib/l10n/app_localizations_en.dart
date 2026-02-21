// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get done => 'Done';

  @override
  String get ok => 'OK';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String errorLoadingSettings(String error) {
    return 'Error loading settings: $error';
  }

  @override
  String get notSet => 'Not set';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get priority => 'Priority';

  @override
  String get repeat => 'Repeat';

  @override
  String get pinned => 'Pinned';

  @override
  String get completed => 'Completed';

  @override
  String get overdue => 'Overdue';

  @override
  String get today => 'Today';

  @override
  String get next7Days => 'Next 7 Days';

  @override
  String get later => 'Later';

  @override
  String get pleaseEnterSomeText => 'Please enter some text';

  @override
  String get titleCannotBeEmpty => 'Title cannot be empty';

  @override
  String get repeatNone => 'None';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatYearly => 'Yearly';

  @override
  String get all => 'All';

  @override
  String get pending => 'Pending';

  @override
  String get color => 'Color';

  @override
  String get colorNone => 'None';

  @override
  String get unit => 'Unit';

  @override
  String get brandSelectionTitle => 'Select Brand';

  @override
  String get brandSearchHint => 'Search brands...';

  @override
  String get createCustomBrand => 'Create Custom Brand';

  @override
  String get selectABrand => 'Select a Brand';

  @override
  String get noBrandsFound => 'No brands found';

  @override
  String get brandNameLabel => 'Brand Name';

  @override
  String get brandNameHint => 'Enter brand name';

  @override
  String get selectColor => 'Select Color';

  @override
  String get continueToScan => 'Continue to Scan';

  @override
  String get guaranteesTitle => 'Guarantees';

  @override
  String get noGuarantees => 'No guarantees';

  @override
  String get addGuarantee => 'Add Guarantee';

  @override
  String get editGuarantee => 'Edit Guarantee';

  @override
  String get productNameLabel => 'Product Name';

  @override
  String get purchaseDate => 'Purchase Date';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get warrantyPhotoButton => 'Warranty';

  @override
  String get receiptPhotoButton => 'Receipt';

  @override
  String get warrantyPhotoCaptured => 'Warranty photo captured';

  @override
  String get receiptPhotoCaptured => 'Receipt photo captured';

  @override
  String get notesLabel => 'Notes';

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get remindMe => 'Remind me';

  @override
  String reminderMonthsBeforeSingular(int count) {
    return '$count month before';
  }

  @override
  String reminderMonthsBeforePlural(int count) {
    return '$count months before';
  }

  @override
  String get warrantyPhotoDetailLabel => 'Warranty Photo:';

  @override
  String get receiptPhotoDetailLabel => 'Receipt Photo:';

  @override
  String guaranteeExpiresOn(String date) {
    return 'Expires: $date';
  }

  @override
  String get guaranteeExpired => 'EXPIRED';

  @override
  String get guaranteeExpiringSoon => 'Expiring soon';

  @override
  String get loyaltyCardsTitle => 'Loyalty Cards';

  @override
  String get loyaltyCardsSearchHint => 'Search loyalty cards...';

  @override
  String get noLoyaltyCards => 'No loyalty cards';

  @override
  String get noCardsFound => 'No cards found';

  @override
  String get cardUnpinned => 'Card unpinned';

  @override
  String get cardPinnedToTop => 'Card pinned to top';

  @override
  String get tooltipUnpin => 'Unpin';

  @override
  String get tooltipPinToTop => 'Pin to top';

  @override
  String get tooltipDelete => 'Delete';

  @override
  String get defaultLoyaltyCardName => 'Loyalty Card';

  @override
  String cardAddedSuccess(String cardName) {
    return 'Card \"$cardName\" added successfully!';
  }

  @override
  String get addLoyaltyCard => 'Add Loyalty Card';

  @override
  String get editLoyaltyCard => 'Edit Loyalty Card';

  @override
  String get cardNameLabel => 'Card Name';

  @override
  String get brandFieldLabel => 'Brand';

  @override
  String get genericCardFallback => 'Generic Card';

  @override
  String get barcodeNumberLabel => 'Barcode Number';

  @override
  String get scanButtonLabel => 'Scan';

  @override
  String get fillInCardNameAndBarcode =>
      'Please fill in card name and barcode number';

  @override
  String get scanBarcodeTitle => 'Scan Barcode';

  @override
  String get tooltipPickFromGallery => 'Pick from gallery';

  @override
  String get noBarcodeFoundInImage => 'No barcode found in the selected image';

  @override
  String errorScanningImage(String error) {
    return 'Error scanning image: $error';
  }

  @override
  String get navTasks => 'Tasks';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navCards => 'Cards';

  @override
  String get navGuarantees => 'Guarantees';

  @override
  String get navNotes => 'Notes';

  @override
  String get noSectionsEnabled => 'No sections enabled';

  @override
  String get enableAtLeastOneSection =>
      'Enable at least one section in Settings';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get devModeDrawerHeader => 'Dev Mode';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerTestNotification => 'Test Notification';

  @override
  String get drawerTestNotificationSubtitle => 'Send a test notification';

  @override
  String get testNotificationSent => 'Test notification sent!';

  @override
  String get drawerRequestPermissions => 'Request Permissions';

  @override
  String get drawerRequestPermissionsSubtitle =>
      'Request notification permissions';

  @override
  String get notificationPermissionsGranted =>
      'Notification permissions granted! ✅';

  @override
  String get notificationPermissionsDenied =>
      'Notification permissions denied. Please enable in settings.';

  @override
  String get drawerCheckNotificationStatus => 'Check Notification Status';

  @override
  String get drawerCheckNotificationStatusSubtitle =>
      'View notification status and pending notifications';

  @override
  String get notificationStatusDialogTitle => 'Notification Status';

  @override
  String notificationsEnabledStatus(String status) {
    return 'Notifications Enabled: $status';
  }

  @override
  String pendingNotificationsCount(int count) {
    return 'Pending Notifications: $count';
  }

  @override
  String get notificationStatusPendingHeader => 'Pending:';

  @override
  String andNMore(int count) {
    return '... and $count more';
  }

  @override
  String get notificationsDisabledWarning =>
      '⚠️ Notifications are disabled. Please enable them in Settings.';

  @override
  String get devModeNoAuth => 'Dev Mode - No Auth';

  @override
  String get devModeNoAuthSubtitle => 'Authentication disabled for development';

  @override
  String get notesTitle => 'Notes';

  @override
  String get notesSearchHint => 'Search notes...';

  @override
  String get noNotes => 'No notes';

  @override
  String get addNote => 'Add Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get noteTitleLabel => 'Title';

  @override
  String get noteContentLabel => 'Content';

  @override
  String get noteTagsLabel => 'Tags (comma separated)';

  @override
  String get noteTagsHint => 'work, personal, ideas';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get noReminders => 'No reminders';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get addReminderHint => 'Add your reminder here';

  @override
  String get reminderTypeLabel => 'Reminder type';

  @override
  String get reminderTypeBirthday => 'Birthday';

  @override
  String get reminderTypeAppointment => 'Appointment';

  @override
  String get reminderTypeTodo => 'Todo';

  @override
  String get reminderTypeOther => 'Other';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppSectionsHeader => 'App Sections';

  @override
  String get settingsAppSectionsSubtitle =>
      'Select which sections you want to see in the app';

  @override
  String get sectionTasks => 'Tasks';

  @override
  String get sectionShoppingLists => 'Shopping Lists';

  @override
  String get sectionGuarantees => 'Guarantees';

  @override
  String get sectionNotes => 'Notes';

  @override
  String get sectionLoyaltyCards => 'Loyalty Cards';

  @override
  String get settingsColorSchemeHeader => 'Color Scheme';

  @override
  String get settingsColorSchemeSubtitle => 'Choose your preferred color theme';

  @override
  String get settingsBackupHeader => 'Backup & Restore';

  @override
  String get settingsBackupSubtitle =>
      'Backup your data to transfer to a new device';

  @override
  String get settingsAtLeastOneSection =>
      'At least one section must be enabled';

  @override
  String get settingsAboutHeader => 'About';

  @override
  String get settingsAboutSubtitle => 'Legal information and app details';

  @override
  String backupLastDate(String date) {
    return 'Last backup: $date';
  }

  @override
  String get backupNeverBackedUp => 'Never backed up';

  @override
  String get createBackupButton => 'Create Backup';

  @override
  String get restoreButton => 'Restore';

  @override
  String get backupRemindersToggle => 'Backup Reminders';

  @override
  String get reminderFrequencyLabel => 'Reminder Frequency';

  @override
  String frequencyDays(int count) {
    return '$count days';
  }

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get versionLabel => 'Version';

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String errorOpeningLink(String error) {
    return 'Error opening link: $error';
  }

  @override
  String get backupDateToday => 'today';

  @override
  String get backupDateYesterday => 'yesterday';

  @override
  String backupDateDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String backupDateWeekAgo(int count) {
    return '$count week ago';
  }

  @override
  String backupDateWeeksAgo(int count) {
    return '$count weeks ago';
  }

  @override
  String backupDateMonthAgo(int count) {
    return '$count month ago';
  }

  @override
  String backupDateMonthsAgo(int count) {
    return '$count months ago';
  }

  @override
  String get restoreBackupDialogTitle => 'Restore Backup';

  @override
  String get restoreBackupDialogContent =>
      'How would you like to restore the backup?\n\n• Replace: Delete all current data and restore from backup\n• Merge: Combine backup data with current data';

  @override
  String get restoreMerge => 'Merge';

  @override
  String get restoreReplace => 'Replace';

  @override
  String get backupCreatedSuccess => 'Backup created successfully!';

  @override
  String get backupCancelled => 'Backup cancelled';

  @override
  String errorCreatingBackup(String error) {
    return 'Error creating backup: $error';
  }

  @override
  String get backupRestoredSuccess =>
      'Backup restored successfully! Data reloaded.';

  @override
  String get restoreCancelled => 'Restore cancelled';

  @override
  String errorRestoringBackup(String error) {
    return 'Error restoring backup: $error';
  }

  @override
  String get shoppingListsTitle => 'Shopping Lists';

  @override
  String get tooltipImportCsv => 'Import CSV';

  @override
  String get noShoppingLists => 'No shopping lists';

  @override
  String importedListSuccess(String name, int itemCount) {
    return 'Imported \"$name\" with $itemCount items';
  }

  @override
  String failedToImport(String error) {
    return 'Failed to import: $error';
  }

  @override
  String get shoppingListExported => 'Shopping list exported!';

  @override
  String failedToExport(String error) {
    return 'Failed to export: $error';
  }

  @override
  String get tooltipExportAsCsv => 'Export as CSV';

  @override
  String shoppingListItemsCount(int completed, int total) {
    return '$completed / $total items';
  }

  @override
  String get shoppingListNameHint => 'List name';

  @override
  String get shoppingListEmptyState => 'No items yet\nStart adding below!';

  @override
  String get restoreCheckedItemLabel => 'Restore checked item';

  @override
  String get itemNameHint => 'Item name…';

  @override
  String itemAlreadyOnList(String name) {
    return '\"$name\" is already on the list';
  }

  @override
  String get editItemDialogTitle => 'Edit Item';

  @override
  String get itemNameLabel => 'Item Name';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get pleaseEnterItemName => 'Please enter an item name';

  @override
  String get shoppingTitle => 'Shopping';

  @override
  String get noSectionsEnabledShopping => 'No sections enabled';

  @override
  String get tabShoppingLists => 'Shopping Lists';

  @override
  String get tabLoyaltyCards => 'Loyalty Cards';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get filterAllTasks => 'All Tasks';

  @override
  String get filterReminders => 'Reminders';

  @override
  String get filterTodos => 'Todos';

  @override
  String get noTasks => 'No tasks';

  @override
  String tasksFilterActive(String filter) {
    return 'Filter: $filter';
  }

  @override
  String get sectionNoDate => 'No Date';

  @override
  String get sectionHighPriority => 'High Priority';

  @override
  String get sectionMediumPriority => 'Medium Priority';

  @override
  String get sectionLowPriority => 'Low Priority';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get addTaskHint => 'Add your task here';

  @override
  String get taskTypeLabel => 'Task type';

  @override
  String get taskTypeBirthday => 'Birthday';

  @override
  String get taskTypeAppointment => 'Appointment';

  @override
  String get taskTypeToDo => 'To-Do';

  @override
  String get taskTypeWarranty => 'Warranty';

  @override
  String get taskTypeOther => 'Other';

  @override
  String get todosTitle => 'To-Dos';

  @override
  String get noTodos => 'No to-dos';

  @override
  String get addToDo => 'Add To-Do';

  @override
  String get editToDo => 'Edit To-Do';

  @override
  String get addToDoHint => 'Add your to-do here';

  @override
  String get deleteDialogDefaultMessage => 'This action cannot be undone.';

  @override
  String get settingsLanguageHeader => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the app language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageCroatian => 'Hrvatski (Croatian)';

  @override
  String get languageGerman => 'Deutsch (German)';

  @override
  String get languageSpanish => 'Español (Spanish)';

  @override
  String get languageFrench => 'Français (French)';

  @override
  String get languageItalian => 'Italiano (Italian)';
}
