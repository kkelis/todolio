// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get save => 'Spremi';

  @override
  String get cancel => 'Odustani';

  @override
  String get delete => 'Obriši';

  @override
  String get edit => 'Uredi';

  @override
  String get close => 'Zatvori';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get done => 'Gotovo';

  @override
  String get ok => 'U redu';

  @override
  String errorWithDetails(String error) {
    return 'Greška: $error';
  }

  @override
  String errorLoadingSettings(String error) {
    return 'Greška pri učitavanju postavki: $error';
  }

  @override
  String get notSet => 'Nije postavljeno';

  @override
  String get dateAndTime => 'Datum i vrijeme';

  @override
  String get priority => 'Prioritet';

  @override
  String get repeat => 'Ponavljanje';

  @override
  String get pinned => 'Zakačeno';

  @override
  String get completed => 'Završeno';

  @override
  String get overdue => 'Zakašnjelo';

  @override
  String get today => 'Danas';

  @override
  String get next7Days => 'Sljedećih 7 dana';

  @override
  String get later => 'Kasnije';

  @override
  String get pleaseEnterSomeText => 'Unesite neki tekst';

  @override
  String get titleCannotBeEmpty => 'Naslov ne može biti prazan';

  @override
  String get repeatNone => 'Bez ponavljanja';

  @override
  String get repeatDaily => 'Svaki dan';

  @override
  String get repeatWeekly => 'Svaki tjedan';

  @override
  String get repeatMonthly => 'Svaki mjesec';

  @override
  String get repeatYearly => 'Svake godine';

  @override
  String get all => 'Sve';

  @override
  String get pending => 'Na čekanju';

  @override
  String get color => 'Boja';

  @override
  String get colorNone => 'Bez boje';

  @override
  String get unit => 'Jedinica';

  @override
  String get brandSelectionTitle => 'Odaberi brend';

  @override
  String get brandSearchHint => 'Pretraži brendove...';

  @override
  String get createCustomBrand => 'Stvori prilagođeni brend';

  @override
  String get selectABrand => 'Odaberi brend';

  @override
  String get noBrandsFound => 'Nema pronađenih brendova';

  @override
  String get brandNameLabel => 'Naziv brenda';

  @override
  String get brandNameHint => 'Unesite naziv brenda';

  @override
  String get selectColor => 'Odaberi boju';

  @override
  String get continueToScan => 'Nastavi na skeniranje';

  @override
  String get guaranteesTitle => 'Garancije';

  @override
  String get noGuarantees => 'Nema garancija';

  @override
  String get addGuarantee => 'Dodaj garanciju';

  @override
  String get editGuarantee => 'Uredi garanciju';

  @override
  String get productNameLabel => 'Naziv proizvoda';

  @override
  String get purchaseDate => 'Datum kupnje';

  @override
  String get expiryDate => 'Datum isteka';

  @override
  String get warrantyPhotoButton => 'Garancija';

  @override
  String get receiptPhotoButton => 'Račun';

  @override
  String get warrantyPhotoCaptured => 'Fotografija garancije snimljena';

  @override
  String get receiptPhotoCaptured => 'Fotografija računa snimljena';

  @override
  String get notesLabel => 'Bilješke';

  @override
  String get setReminder => 'Postavi podsjetnik';

  @override
  String get remindMe => 'Podsjeti me';

  @override
  String reminderMonthsBeforeSingular(int count) {
    return '$count mjesec prije';
  }

  @override
  String reminderMonthsBeforePlural(int count) {
    return '$count mjeseca prije';
  }

  @override
  String get warrantyPhotoDetailLabel => 'Fotografija garancije:';

  @override
  String get receiptPhotoDetailLabel => 'Fotografija računa:';

  @override
  String guaranteeExpiresOn(String date) {
    return 'Ističe: $date';
  }

  @override
  String get guaranteeExpired => 'ISTEKLO';

  @override
  String get guaranteeExpiringSoon => 'Uskoro ističe';

  @override
  String get loyaltyCardsTitle => 'Kartice vjernosti';

  @override
  String get loyaltyCardsSearchHint => 'Pretražite kartice vjernosti...';

  @override
  String get noLoyaltyCards => 'Nema kartica vjernosti';

  @override
  String get noCardsFound => 'Nema pronađenih kartica';

  @override
  String get cardUnpinned => 'Kartica otkačena';

  @override
  String get cardPinnedToTop => 'Kartica zakačena na vrh';

  @override
  String get tooltipUnpin => 'Otkači';

  @override
  String get tooltipPinToTop => 'Zakači na vrh';

  @override
  String get tooltipDelete => 'Obriši';

  @override
  String get defaultLoyaltyCardName => 'Kartica vjernosti';

  @override
  String cardAddedSuccess(String cardName) {
    return 'Kartica \"$cardName\" uspješno dodana!';
  }

  @override
  String get addLoyaltyCard => 'Dodaj karticu vjernosti';

  @override
  String get editLoyaltyCard => 'Uredi karticu vjernosti';

  @override
  String get cardNameLabel => 'Naziv kartice';

  @override
  String get brandFieldLabel => 'Brend';

  @override
  String get genericCardFallback => 'Generička kartica';

  @override
  String get barcodeNumberLabel => 'Broj barkoda';

  @override
  String get scanButtonLabel => 'Skeniraj';

  @override
  String get fillInCardNameAndBarcode =>
      'Molimo ispunite naziv kartice i broj barkoda';

  @override
  String get scanBarcodeTitle => 'Skenirajte barkod';

  @override
  String get tooltipPickFromGallery => 'Odaberi iz galerije';

  @override
  String get noBarcodeFoundInImage => 'U odabranoj slici nije pronađen barkod';

  @override
  String errorScanningImage(String error) {
    return 'Greška pri skeniranju slike: $error';
  }

  @override
  String get navTasks => 'Zadaci';

  @override
  String get navShopping => 'Kupovina';

  @override
  String get navCards => 'Kartice';

  @override
  String get navGuarantees => 'Garancije';

  @override
  String get navNotes => 'Bilješke';

  @override
  String get noSectionsEnabled => 'Nema aktivnih sekcija';

  @override
  String get enableAtLeastOneSection =>
      'Aktivirajte barem jednu sekciju u Postavkama';

  @override
  String get openSettings => 'Otvori postavke';

  @override
  String get devModeDrawerHeader => 'Dev Mode';

  @override
  String get drawerSettings => 'Postavke';

  @override
  String get drawerTestNotification => 'Test obavijest';

  @override
  String get drawerTestNotificationSubtitle => 'Pošalji testnu obavijest';

  @override
  String get testNotificationSent => 'Testna obavijest poslana!';

  @override
  String get drawerRequestPermissions => 'Zatraži dozvole';

  @override
  String get drawerRequestPermissionsSubtitle =>
      'Zatraži dozvole za obavijesti';

  @override
  String get notificationPermissionsGranted =>
      'Dozvole za obavijesti odobrene! ✅';

  @override
  String get notificationPermissionsDenied =>
      'Dozvole za obavijesti odbijene. Molimo omogućite ih u postavkama.';

  @override
  String get drawerCheckNotificationStatus => 'Provjeri status obavijesti';

  @override
  String get drawerCheckNotificationStatusSubtitle =>
      'Pogledajte status obavijesti i čekajuće obavijesti';

  @override
  String get notificationStatusDialogTitle => 'Status obavijesti';

  @override
  String notificationsEnabledStatus(String status) {
    return 'Obavijesti omogućene: $status';
  }

  @override
  String pendingNotificationsCount(int count) {
    return 'Čekajuće obavijesti: $count';
  }

  @override
  String get notificationStatusPendingHeader => 'Na čekanju:';

  @override
  String andNMore(int count) {
    return '... i još $count';
  }

  @override
  String get notificationsDisabledWarning =>
      '⚠️ Obavijesti su onemogućene. Molimo omogućite ih u Postavkama.';

  @override
  String get devModeNoAuth => 'Dev Mode - Bez autentifikacije';

  @override
  String get devModeNoAuthSubtitle => 'Autentifikacija onemogućena za razvoj';

  @override
  String get notesTitle => 'Bilješke';

  @override
  String get notesSearchHint => 'Pretražite bilješke...';

  @override
  String get noNotes => 'Nema bilješki';

  @override
  String get addNote => 'Dodaj bilješku';

  @override
  String get editNote => 'Uredi bilješku';

  @override
  String get noteTitleLabel => 'Naslov';

  @override
  String get noteContentLabel => 'Sadržaj';

  @override
  String get noteTagsLabel => 'Oznake (odvojene zarezom)';

  @override
  String get noteTagsHint => 'posao, osobno, ideje';

  @override
  String get remindersTitle => 'Podsjetnici';

  @override
  String get noReminders => 'Nema podsjetnika';

  @override
  String get addReminder => 'Dodaj podsjetnik';

  @override
  String get editReminder => 'Uredi podsjetnik';

  @override
  String get addReminderHint => 'Ovdje dodajte podsjetnik';

  @override
  String get reminderTypeLabel => 'Vrsta podsjetnika';

  @override
  String get reminderTypeBirthday => 'Rođendan';

  @override
  String get reminderTypeAppointment => 'Termin';

  @override
  String get reminderTypeTodo => 'Obveza';

  @override
  String get reminderTypeOther => 'Ostalo';

  @override
  String get settingsTitle => 'Postavke';

  @override
  String get settingsAppSectionsHeader => 'Sekcije aplikacije';

  @override
  String get settingsAppSectionsSubtitle =>
      'Odaberite koje sekcije želite vidjeti u aplikaciji';

  @override
  String get sectionTasks => 'Zadaci';

  @override
  String get sectionShoppingLists => 'Liste kupovine';

  @override
  String get sectionGuarantees => 'Garancije';

  @override
  String get sectionNotes => 'Bilješke';

  @override
  String get sectionLoyaltyCards => 'Kartice vjernosti';

  @override
  String get settingsColorSchemeHeader => 'Shema boja';

  @override
  String get settingsColorSchemeSubtitle => 'Odaberite željenu temu boja';

  @override
  String get settingsBackupHeader => 'Backup i obnova';

  @override
  String get settingsBackupSubtitle =>
      'Napravite backup podataka za prijenos na novi uređaj';

  @override
  String get settingsAtLeastOneSection =>
      'Barem jedna sekcija mora biti aktivna';

  @override
  String get settingsAboutHeader => 'O aplikaciji';

  @override
  String get settingsAboutSubtitle => 'Pravne informacije i detalji aplikacije';

  @override
  String backupLastDate(String date) {
    return 'Zadnji backup: $date';
  }

  @override
  String get backupNeverBackedUp => 'Nikad nije napravljen backup';

  @override
  String get createBackupButton => 'Stvori backup';

  @override
  String get restoreButton => 'Obnovi';

  @override
  String get backupRemindersToggle => 'Podsjetnici za backup';

  @override
  String get reminderFrequencyLabel => 'Učestalost podsjetnika';

  @override
  String frequencyDays(int count) {
    return '$count dana';
  }

  @override
  String get privacyPolicyTitle => 'Politika privatnosti';

  @override
  String get termsOfServiceTitle => 'Uvjeti korištenja';

  @override
  String get versionLabel => 'Verzija';

  @override
  String couldNotOpenUrl(String url) {
    return 'Nije moguće otvoriti $url';
  }

  @override
  String errorOpeningLink(String error) {
    return 'Greška pri otvaranju linka: $error';
  }

  @override
  String get backupDateToday => 'danas';

  @override
  String get backupDateYesterday => 'jučer';

  @override
  String backupDateDaysAgo(int count) {
    return 'prije $count dana';
  }

  @override
  String backupDateWeekAgo(int count) {
    return 'prije $count tjedan';
  }

  @override
  String backupDateWeeksAgo(int count) {
    return 'prije $count tjedna';
  }

  @override
  String backupDateMonthAgo(int count) {
    return 'prije $count mjesec';
  }

  @override
  String backupDateMonthsAgo(int count) {
    return 'prije $count mjeseci';
  }

  @override
  String get restoreBackupDialogTitle => 'Obnovi backup';

  @override
  String get restoreBackupDialogContent =>
      'Kako želite obnoviti backup?\n\n• Zamijeni: Izbriši sve trenutne podatke i obnovi iz backupa\n• Spoji: Kombiniraj podatke iz backupa s trenutnim podacima';

  @override
  String get restoreMerge => 'Spoji';

  @override
  String get restoreReplace => 'Zamijeni';

  @override
  String get backupCreatedSuccess => 'Backup uspješno stvoren!';

  @override
  String get backupCancelled => 'Backup otkazan';

  @override
  String errorCreatingBackup(String error) {
    return 'Greška pri stvaranju backupa: $error';
  }

  @override
  String get backupRestoredSuccess =>
      'Backup uspješno obnovljen! Podaci ponovno učitani.';

  @override
  String get restoreCancelled => 'Obnova otkazana';

  @override
  String errorRestoringBackup(String error) {
    return 'Greška pri obnovi backupa: $error';
  }

  @override
  String get shoppingListsTitle => 'Liste kupovine';

  @override
  String get tooltipImportCsv => 'Uvezi CSV';

  @override
  String get noShoppingLists => 'Nema lista kupovine';

  @override
  String importedListSuccess(String name, int itemCount) {
    return 'Uvezeno \"$name\" s $itemCount stavki';
  }

  @override
  String failedToImport(String error) {
    return 'Uvoz nije uspio: $error';
  }

  @override
  String get shoppingListExported => 'Lista kupovine izvezena!';

  @override
  String failedToExport(String error) {
    return 'Izvoz nije uspio: $error';
  }

  @override
  String get tooltipExportAsCsv => 'Izvezi kao CSV';

  @override
  String shoppingListItemsCount(int completed, int total) {
    return '$completed / $total stavki';
  }

  @override
  String get shoppingListNameHint => 'Naziv liste';

  @override
  String get shoppingListEmptyState => 'Nema stavki\nPočnite dodavati ispod!';

  @override
  String get restoreCheckedItemLabel => 'Obnovi označenu stavku';

  @override
  String get itemNameHint => 'Naziv stavke…';

  @override
  String itemAlreadyOnList(String name) {
    return '\"$name\" je već na listi';
  }

  @override
  String get editItemDialogTitle => 'Uredi stavku';

  @override
  String get itemNameLabel => 'Naziv stavke';

  @override
  String get quantityLabel => 'Količina';

  @override
  String get pleaseEnterItemName => 'Molimo unesite naziv stavke';

  @override
  String get shoppingTitle => 'Kupovina';

  @override
  String get noSectionsEnabledShopping => 'Nema aktivnih sekcija';

  @override
  String get tabShoppingLists => 'Liste kupovine';

  @override
  String get tabLoyaltyCards => 'Kartice vjernosti';

  @override
  String get tasksTitle => 'Zadaci';

  @override
  String get filterAllTasks => 'Svi zadaci';

  @override
  String get filterReminders => 'Podsjetnici';

  @override
  String get filterTodos => 'Obveze';

  @override
  String get noTasks => 'Nema zadataka';

  @override
  String tasksFilterActive(String filter) {
    return 'Filtar: $filter';
  }

  @override
  String get sectionNoDate => 'Bez datuma';

  @override
  String get sectionHighPriority => 'Visoki prioritet';

  @override
  String get sectionMediumPriority => 'Srednji prioritet';

  @override
  String get sectionLowPriority => 'Niski prioritet';

  @override
  String get addTask => 'Dodaj zadatak';

  @override
  String get editTask => 'Uredi zadatak';

  @override
  String get addTaskHint => 'Ovdje dodajte zadatak';

  @override
  String get taskTypeLabel => 'Vrsta zadatka';

  @override
  String get taskTypeBirthday => 'Rođendan';

  @override
  String get taskTypeAppointment => 'Termin';

  @override
  String get taskTypeToDo => 'Obveza';

  @override
  String get taskTypeWarranty => 'Garancija';

  @override
  String get taskTypeOther => 'Ostalo';

  @override
  String get todosTitle => 'Obveze';

  @override
  String get noTodos => 'Nema obveza';

  @override
  String get addToDo => 'Dodaj obvezu';

  @override
  String get editToDo => 'Uredi obvezu';

  @override
  String get addToDoHint => 'Ovdje dodajte obvezu';

  @override
  String get deleteDialogDefaultMessage => 'Ova radnja se ne može poništiti.';

  @override
  String get settingsLanguageHeader => 'Jezik';

  @override
  String get settingsLanguageSubtitle => 'Odaberi jezik aplikacije';

  @override
  String get languageSystemDefault => 'Zadano (sustav)';

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
