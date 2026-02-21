// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get close => 'Schließen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get done => 'Fertig';

  @override
  String get ok => 'OK';

  @override
  String errorWithDetails(String error) {
    return 'Fehler: $error';
  }

  @override
  String errorLoadingSettings(String error) {
    return 'Fehler beim Laden der Einstellungen: $error';
  }

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get dateAndTime => 'Datum & Uhrzeit';

  @override
  String get priority => 'Priorität';

  @override
  String get repeat => 'Wiederholen';

  @override
  String get pinned => 'Angeheftet';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get overdue => 'Überfällig';

  @override
  String get today => 'Heute';

  @override
  String get next7Days => 'Nächste 7 Tage';

  @override
  String get later => 'Später';

  @override
  String get pleaseEnterSomeText => 'Bitte Text eingeben';

  @override
  String get titleCannotBeEmpty => 'Titel darf nicht leer sein';

  @override
  String get repeatNone => 'Keine';

  @override
  String get repeatDaily => 'Täglich';

  @override
  String get repeatWeekly => 'Wöchentlich';

  @override
  String get repeatMonthly => 'Monatlich';

  @override
  String get repeatYearly => 'Jährlich';

  @override
  String get all => 'Alle';

  @override
  String get pending => 'Ausstehend';

  @override
  String get color => 'Farbe';

  @override
  String get colorNone => 'Keine';

  @override
  String get unit => 'Einheit';

  @override
  String get brandSelectionTitle => 'Marke auswählen';

  @override
  String get brandSearchHint => 'Marken suchen...';

  @override
  String get createCustomBrand => 'Eigene Marke erstellen';

  @override
  String get selectABrand => 'Marke auswählen';

  @override
  String get noBrandsFound => 'Keine Marken gefunden';

  @override
  String get brandNameLabel => 'Markenname';

  @override
  String get brandNameHint => 'Markennamen eingeben';

  @override
  String get selectColor => 'Farbe auswählen';

  @override
  String get continueToScan => 'Weiter zum Scannen';

  @override
  String get guaranteesTitle => 'Garantien';

  @override
  String get noGuarantees => 'Keine Garantien';

  @override
  String get addGuarantee => 'Garantie hinzufügen';

  @override
  String get editGuarantee => 'Garantie bearbeiten';

  @override
  String get productNameLabel => 'Produktname';

  @override
  String get purchaseDate => 'Kaufdatum';

  @override
  String get expiryDate => 'Ablaufdatum';

  @override
  String get warrantyPhotoButton => 'Garantie';

  @override
  String get receiptPhotoButton => 'Kassenbon';

  @override
  String get warrantyPhotoCaptured => 'Garantiefoto aufgenommen';

  @override
  String get receiptPhotoCaptured => 'Kassenbonfoto aufgenommen';

  @override
  String get notesLabel => 'Notizen';

  @override
  String get setReminder => 'Erinnerung setzen';

  @override
  String get remindMe => 'Erinnerung';

  @override
  String reminderMonthsBeforeSingular(int count) {
    return '$count Monat vorher';
  }

  @override
  String reminderMonthsBeforePlural(int count) {
    return '$count Monate vorher';
  }

  @override
  String get warrantyPhotoDetailLabel => 'Garantiefoto:';

  @override
  String get receiptPhotoDetailLabel => 'Kassenbonfoto:';

  @override
  String guaranteeExpiresOn(String date) {
    return 'Läuft ab: $date';
  }

  @override
  String get guaranteeExpired => 'ABGELAUFEN';

  @override
  String get guaranteeExpiringSoon => 'Läuft bald ab';

  @override
  String get loyaltyCardsTitle => 'Treuekarten';

  @override
  String get loyaltyCardsSearchHint => 'Treuekarten suchen...';

  @override
  String get noLoyaltyCards => 'Keine Treuekarten';

  @override
  String get noCardsFound => 'Keine Karten gefunden';

  @override
  String get cardUnpinned => 'Karte abgeheftet';

  @override
  String get cardPinnedToTop => 'Karte oben angeheftet';

  @override
  String get tooltipUnpin => 'Loslösen';

  @override
  String get tooltipPinToTop => 'Oben anheften';

  @override
  String get tooltipDelete => 'Löschen';

  @override
  String get defaultLoyaltyCardName => 'Treuekarte';

  @override
  String cardAddedSuccess(String cardName) {
    return 'Karte \"$cardName\" erfolgreich hinzugefügt!';
  }

  @override
  String get addLoyaltyCard => 'Treuekarte hinzufügen';

  @override
  String get editLoyaltyCard => 'Treuekarte bearbeiten';

  @override
  String get cardNameLabel => 'Kartenname';

  @override
  String get brandFieldLabel => 'Marke';

  @override
  String get genericCardFallback => 'Generische Karte';

  @override
  String get barcodeNumberLabel => 'Barcode-Nummer';

  @override
  String get scanButtonLabel => 'Scannen';

  @override
  String get fillInCardNameAndBarcode =>
      'Bitte Kartenname und Barcode-Nummer ausfüllen';

  @override
  String get scanBarcodeTitle => 'Barcode scannen';

  @override
  String get tooltipPickFromGallery => 'Aus Galerie wählen';

  @override
  String get noBarcodeFoundInImage =>
      'Kein Barcode im ausgewählten Bild gefunden';

  @override
  String errorScanningImage(String error) {
    return 'Fehler beim Scannen des Bildes: $error';
  }

  @override
  String get navTasks => 'Aufgaben';

  @override
  String get navShopping => 'Einkaufen';

  @override
  String get navCards => 'Karten';

  @override
  String get navGuarantees => 'Garantien';

  @override
  String get navNotes => 'Notizen';

  @override
  String get noSectionsEnabled => 'Keine Bereiche aktiviert';

  @override
  String get enableAtLeastOneSection =>
      'Mindestens einen Bereich in den Einstellungen aktivieren';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get devModeDrawerHeader => 'Dev Mode';

  @override
  String get drawerSettings => 'Einstellungen';

  @override
  String get drawerTestNotification => 'Testbenachrichtigung';

  @override
  String get drawerTestNotificationSubtitle =>
      'Eine Testbenachrichtigung senden';

  @override
  String get testNotificationSent => 'Testbenachrichtigung gesendet!';

  @override
  String get drawerRequestPermissions => 'Berechtigungen anfordern';

  @override
  String get drawerRequestPermissionsSubtitle =>
      'Benachrichtigungsberechtigungen anfordern';

  @override
  String get notificationPermissionsGranted =>
      'Benachrichtigungsberechtigungen erteilt! ✅';

  @override
  String get notificationPermissionsDenied =>
      'Benachrichtigungsberechtigungen abgelehnt. Bitte in den Einstellungen aktivieren.';

  @override
  String get drawerCheckNotificationStatus => 'Benachrichtigungsstatus prüfen';

  @override
  String get drawerCheckNotificationStatusSubtitle =>
      'Benachrichtigungsstatus und ausstehende Benachrichtigungen anzeigen';

  @override
  String get notificationStatusDialogTitle => 'Benachrichtigungsstatus';

  @override
  String notificationsEnabledStatus(String status) {
    return 'Benachrichtigungen aktiviert: $status';
  }

  @override
  String pendingNotificationsCount(int count) {
    return 'Ausstehende Benachrichtigungen: $count';
  }

  @override
  String get notificationStatusPendingHeader => 'Ausstehend:';

  @override
  String andNMore(int count) {
    return '... und $count weitere';
  }

  @override
  String get notificationsDisabledWarning =>
      '⚠️ Benachrichtigungen sind deaktiviert. Bitte in den Einstellungen aktivieren.';

  @override
  String get devModeNoAuth => 'Dev Mode - Keine Authentifizierung';

  @override
  String get devModeNoAuthSubtitle =>
      'Authentifizierung für die Entwicklung deaktiviert';

  @override
  String get notesTitle => 'Notizen';

  @override
  String get notesSearchHint => 'Notizen suchen...';

  @override
  String get noNotes => 'Keine Notizen';

  @override
  String get addNote => 'Notiz hinzufügen';

  @override
  String get editNote => 'Notiz bearbeiten';

  @override
  String get noteTitleLabel => 'Titel';

  @override
  String get noteContentLabel => 'Inhalt';

  @override
  String get noteTagsLabel => 'Tags (kommagetrennt)';

  @override
  String get noteTagsHint => 'Arbeit, persönlich, Ideen';

  @override
  String get remindersTitle => 'Erinnerungen';

  @override
  String get noReminders => 'Keine Erinnerungen';

  @override
  String get addReminder => 'Erinnerung hinzufügen';

  @override
  String get editReminder => 'Erinnerung bearbeiten';

  @override
  String get addReminderHint => 'Erinnerung hier hinzufügen';

  @override
  String get reminderTypeLabel => 'Erinnerungstyp';

  @override
  String get reminderTypeBirthday => 'Geburtstag';

  @override
  String get reminderTypeAppointment => 'Termin';

  @override
  String get reminderTypeTodo => 'Aufgabe';

  @override
  String get reminderTypeOther => 'Sonstiges';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAppSectionsHeader => 'App-Bereiche';

  @override
  String get settingsAppSectionsSubtitle =>
      'Wählen Sie, welche Bereiche in der App angezeigt werden sollen';

  @override
  String get sectionTasks => 'Aufgaben';

  @override
  String get sectionShoppingLists => 'Einkaufslisten';

  @override
  String get sectionGuarantees => 'Garantien';

  @override
  String get sectionNotes => 'Notizen';

  @override
  String get sectionLoyaltyCards => 'Treuekarten';

  @override
  String get settingsColorSchemeHeader => 'Farbschema';

  @override
  String get settingsColorSchemeSubtitle =>
      'Wählen Sie Ihr bevorzugtes Farbthema';

  @override
  String get settingsBackupHeader => 'Backup & Wiederherstellung';

  @override
  String get settingsBackupSubtitle =>
      'Sichern Sie Ihre Daten für die Übertragung auf ein neues Gerät';

  @override
  String get settingsAtLeastOneSection =>
      'Mindestens ein Bereich muss aktiviert sein';

  @override
  String get settingsAboutHeader => 'Über';

  @override
  String get settingsAboutSubtitle =>
      'Rechtliche Informationen und App-Details';

  @override
  String backupLastDate(String date) {
    return 'Letztes Backup: $date';
  }

  @override
  String get backupNeverBackedUp => 'Noch nie gesichert';

  @override
  String get createBackupButton => 'Backup erstellen';

  @override
  String get restoreButton => 'Wiederherstellen';

  @override
  String get backupRemindersToggle => 'Backup-Erinnerungen';

  @override
  String get reminderFrequencyLabel => 'Erinnerungshäufigkeit';

  @override
  String frequencyDays(int count) {
    return '$count Tage';
  }

  @override
  String get privacyPolicyTitle => 'Datenschutzrichtlinie';

  @override
  String get termsOfServiceTitle => 'Nutzungsbedingungen';

  @override
  String get versionLabel => 'Version';

  @override
  String couldNotOpenUrl(String url) {
    return '$url konnte nicht geöffnet werden';
  }

  @override
  String errorOpeningLink(String error) {
    return 'Fehler beim Öffnen des Links: $error';
  }

  @override
  String get backupDateToday => 'heute';

  @override
  String get backupDateYesterday => 'gestern';

  @override
  String backupDateDaysAgo(int count) {
    return 'vor $count Tagen';
  }

  @override
  String backupDateWeekAgo(int count) {
    return 'vor $count Woche';
  }

  @override
  String backupDateWeeksAgo(int count) {
    return 'vor $count Wochen';
  }

  @override
  String backupDateMonthAgo(int count) {
    return 'vor $count Monat';
  }

  @override
  String backupDateMonthsAgo(int count) {
    return 'vor $count Monaten';
  }

  @override
  String get restoreBackupDialogTitle => 'Backup wiederherstellen';

  @override
  String get restoreBackupDialogContent =>
      'Wie möchten Sie das Backup wiederherstellen?\n\n• Ersetzen: Alle aktuellen Daten löschen und aus Backup wiederherstellen\n• Zusammenführen: Backup-Daten mit aktuellen Daten kombinieren';

  @override
  String get restoreMerge => 'Zusammenführen';

  @override
  String get restoreReplace => 'Ersetzen';

  @override
  String get backupCreatedSuccess => 'Backup erfolgreich erstellt!';

  @override
  String get backupCancelled => 'Backup abgebrochen';

  @override
  String errorCreatingBackup(String error) {
    return 'Fehler beim Erstellen des Backups: $error';
  }

  @override
  String get backupRestoredSuccess =>
      'Backup erfolgreich wiederhergestellt! Daten neu geladen.';

  @override
  String get restoreCancelled => 'Wiederherstellung abgebrochen';

  @override
  String errorRestoringBackup(String error) {
    return 'Fehler beim Wiederherstellen des Backups: $error';
  }

  @override
  String get shoppingListsTitle => 'Einkaufslisten';

  @override
  String get tooltipImportCsv => 'CSV importieren';

  @override
  String get noShoppingLists => 'Keine Einkaufslisten';

  @override
  String importedListSuccess(String name, int itemCount) {
    return '\"$name\" mit $itemCount Artikeln importiert';
  }

  @override
  String failedToImport(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get shoppingListExported => 'Einkaufsliste exportiert!';

  @override
  String failedToExport(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get tooltipExportAsCsv => 'Als CSV exportieren';

  @override
  String shoppingListItemsCount(int completed, int total) {
    return '$completed / $total Artikel';
  }

  @override
  String get shoppingListNameHint => 'Listenname';

  @override
  String get shoppingListEmptyState => 'Noch keine Artikel\nUnten hinzufügen!';

  @override
  String get restoreCheckedItemLabel => 'Markierten Artikel wiederherstellen';

  @override
  String get itemNameHint => 'Artikelname…';

  @override
  String itemAlreadyOnList(String name) {
    return '\"$name\" ist bereits auf der Liste';
  }

  @override
  String get editItemDialogTitle => 'Artikel bearbeiten';

  @override
  String get itemNameLabel => 'Artikelname';

  @override
  String get quantityLabel => 'Menge';

  @override
  String get pleaseEnterItemName => 'Bitte einen Artikelnamen eingeben';

  @override
  String get shoppingTitle => 'Einkaufen';

  @override
  String get noSectionsEnabledShopping => 'Keine Bereiche aktiviert';

  @override
  String get tabShoppingLists => 'Einkaufslisten';

  @override
  String get tabLoyaltyCards => 'Treuekarten';

  @override
  String get tasksTitle => 'Aufgaben';

  @override
  String get filterAllTasks => 'Alle Aufgaben';

  @override
  String get filterReminders => 'Erinnerungen';

  @override
  String get filterTodos => 'Aufgaben';

  @override
  String get noTasks => 'Keine Aufgaben';

  @override
  String tasksFilterActive(String filter) {
    return 'Filter: $filter';
  }

  @override
  String get sectionNoDate => 'Kein Datum';

  @override
  String get sectionHighPriority => 'Hohe Priorität';

  @override
  String get sectionMediumPriority => 'Mittlere Priorität';

  @override
  String get sectionLowPriority => 'Niedrige Priorität';

  @override
  String get addTask => 'Aufgabe hinzufügen';

  @override
  String get editTask => 'Aufgabe bearbeiten';

  @override
  String get addTaskHint => 'Aufgabe hier hinzufügen';

  @override
  String get taskTypeLabel => 'Aufgabentyp';

  @override
  String get taskTypeBirthday => 'Geburtstag';

  @override
  String get taskTypeAppointment => 'Termin';

  @override
  String get taskTypeToDo => 'Aufgabe';

  @override
  String get taskTypeWarranty => 'Garantie';

  @override
  String get taskTypeOther => 'Sonstiges';

  @override
  String get todosTitle => 'Aufgaben';

  @override
  String get noTodos => 'Keine Aufgaben';

  @override
  String get addToDo => 'Aufgabe hinzufügen';

  @override
  String get editToDo => 'Aufgabe bearbeiten';

  @override
  String get addToDoHint => 'Aufgabe hier hinzufügen';

  @override
  String get deleteDialogDefaultMessage =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get settingsLanguageHeader => 'Sprache';

  @override
  String get settingsLanguageSubtitle => 'App-Sprache auswählen';

  @override
  String get languageSystemDefault => 'Systemstandard';

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
