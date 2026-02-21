// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get close => 'Chiudi';

  @override
  String get retry => 'Riprova';

  @override
  String get done => 'Fatto';

  @override
  String get ok => 'OK';

  @override
  String errorWithDetails(String error) {
    return 'Errore: $error';
  }

  @override
  String errorLoadingSettings(String error) {
    return 'Errore nel caricamento delle impostazioni: $error';
  }

  @override
  String get notSet => 'Non impostato';

  @override
  String get dateAndTime => 'Data e ora';

  @override
  String get priority => 'Priorità';

  @override
  String get repeat => 'Ripeti';

  @override
  String get pinned => 'Fissato';

  @override
  String get completed => 'Completato';

  @override
  String get overdue => 'Scaduto';

  @override
  String get today => 'Oggi';

  @override
  String get next7Days => 'Prossimi 7 giorni';

  @override
  String get later => 'Più tardi';

  @override
  String get pleaseEnterSomeText => 'Inserisci del testo';

  @override
  String get titleCannotBeEmpty => 'Il titolo non può essere vuoto';

  @override
  String get repeatNone => 'Nessuno';

  @override
  String get repeatDaily => 'Giornaliero';

  @override
  String get repeatWeekly => 'Settimanale';

  @override
  String get repeatMonthly => 'Mensile';

  @override
  String get repeatYearly => 'Annuale';

  @override
  String get all => 'Tutti';

  @override
  String get pending => 'In attesa';

  @override
  String get color => 'Colore';

  @override
  String get colorNone => 'Nessuno';

  @override
  String get unit => 'Unità';

  @override
  String get brandSelectionTitle => 'Seleziona marca';

  @override
  String get brandSearchHint => 'Cerca marche...';

  @override
  String get createCustomBrand => 'Crea marca personalizzata';

  @override
  String get selectABrand => 'Seleziona una marca';

  @override
  String get noBrandsFound => 'Nessuna marca trovata';

  @override
  String get brandNameLabel => 'Nome marca';

  @override
  String get brandNameHint => 'Inserisci il nome della marca';

  @override
  String get selectColor => 'Seleziona colore';

  @override
  String get continueToScan => 'Continua per scansionare';

  @override
  String get guaranteesTitle => 'Garanzie';

  @override
  String get noGuarantees => 'Nessuna garanzia';

  @override
  String get addGuarantee => 'Aggiungi garanzia';

  @override
  String get editGuarantee => 'Modifica garanzia';

  @override
  String get productNameLabel => 'Nome prodotto';

  @override
  String get purchaseDate => 'Data di acquisto';

  @override
  String get expiryDate => 'Data di scadenza';

  @override
  String get warrantyPhotoButton => 'Garanzia';

  @override
  String get receiptPhotoButton => 'Scontrino';

  @override
  String get warrantyPhotoCaptured => 'Foto garanzia acquisita';

  @override
  String get receiptPhotoCaptured => 'Foto scontrino acquisita';

  @override
  String get notesLabel => 'Note';

  @override
  String get setReminder => 'Imposta promemoria';

  @override
  String get remindMe => 'Ricordamelo';

  @override
  String reminderMonthsBeforeSingular(int count) {
    return '$count mese prima';
  }

  @override
  String reminderMonthsBeforePlural(int count) {
    return '$count mesi prima';
  }

  @override
  String get warrantyPhotoDetailLabel => 'Foto garanzia:';

  @override
  String get receiptPhotoDetailLabel => 'Foto scontrino:';

  @override
  String guaranteeExpiresOn(String date) {
    return 'Scade: $date';
  }

  @override
  String get guaranteeExpired => 'SCADUTO';

  @override
  String get guaranteeExpiringSoon => 'In scadenza';

  @override
  String get loyaltyCardsTitle => 'Carte fedeltà';

  @override
  String get loyaltyCardsSearchHint => 'Cerca carte fedeltà...';

  @override
  String get noLoyaltyCards => 'Nessuna carta fedeltà';

  @override
  String get noCardsFound => 'Nessuna carta trovata';

  @override
  String get cardUnpinned => 'Carta rimossa dal blocco';

  @override
  String get cardPinnedToTop => 'Carta bloccata in alto';

  @override
  String get tooltipUnpin => 'Sblocca';

  @override
  String get tooltipPinToTop => 'Blocca in alto';

  @override
  String get tooltipDelete => 'Elimina';

  @override
  String get defaultLoyaltyCardName => 'Carta fedeltà';

  @override
  String cardAddedSuccess(String cardName) {
    return 'Carta \"$cardName\" aggiunta con successo!';
  }

  @override
  String get addLoyaltyCard => 'Aggiungi carta fedeltà';

  @override
  String get editLoyaltyCard => 'Modifica carta fedeltà';

  @override
  String get cardNameLabel => 'Nome carta';

  @override
  String get brandFieldLabel => 'Marca';

  @override
  String get genericCardFallback => 'Carta generica';

  @override
  String get barcodeNumberLabel => 'Numero codice a barre';

  @override
  String get scanButtonLabel => 'Scansiona';

  @override
  String get fillInCardNameAndBarcode =>
      'Inserisci il nome della carta e il numero del codice a barre';

  @override
  String get scanBarcodeTitle => 'Scansiona codice a barre';

  @override
  String get tooltipPickFromGallery => 'Scegli dalla galleria';

  @override
  String get noBarcodeFoundInImage =>
      'Nessun codice a barre trovato nell\'immagine selezionata';

  @override
  String errorScanningImage(String error) {
    return 'Errore durante la scansione dell\'immagine: $error';
  }

  @override
  String get navTasks => 'Attività';

  @override
  String get navShopping => 'Spesa';

  @override
  String get navCards => 'Carte';

  @override
  String get navGuarantees => 'Garanzie';

  @override
  String get navNotes => 'Note';

  @override
  String get noSectionsEnabled => 'Nessuna sezione attivata';

  @override
  String get enableAtLeastOneSection =>
      'Attiva almeno una sezione nelle Impostazioni';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get devModeDrawerHeader => 'Dev Mode';

  @override
  String get drawerSettings => 'Impostazioni';

  @override
  String get drawerTestNotification => 'Notifica di test';

  @override
  String get drawerTestNotificationSubtitle => 'Invia una notifica di test';

  @override
  String get testNotificationSent => 'Notifica di test inviata!';

  @override
  String get drawerRequestPermissions => 'Richiedi autorizzazioni';

  @override
  String get drawerRequestPermissionsSubtitle =>
      'Richiedi autorizzazioni per le notifiche';

  @override
  String get notificationPermissionsGranted =>
      'Autorizzazioni notifiche concesse! ✅';

  @override
  String get notificationPermissionsDenied =>
      'Autorizzazioni notifiche negate. Abilitale nelle impostazioni.';

  @override
  String get drawerCheckNotificationStatus => 'Controlla stato notifiche';

  @override
  String get drawerCheckNotificationStatusSubtitle =>
      'Visualizza lo stato delle notifiche e le notifiche in sospeso';

  @override
  String get notificationStatusDialogTitle => 'Stato notifiche';

  @override
  String notificationsEnabledStatus(String status) {
    return 'Notifiche attivate: $status';
  }

  @override
  String pendingNotificationsCount(int count) {
    return 'Notifiche in sospeso: $count';
  }

  @override
  String get notificationStatusPendingHeader => 'In sospeso:';

  @override
  String andNMore(int count) {
    return '... e altri $count';
  }

  @override
  String get notificationsDisabledWarning =>
      '⚠️ Le notifiche sono disattivate. Abilitale nelle Impostazioni.';

  @override
  String get devModeNoAuth => 'Dev Mode - Senza autenticazione';

  @override
  String get devModeNoAuthSubtitle =>
      'Autenticazione disabilitata per lo sviluppo';

  @override
  String get notesTitle => 'Note';

  @override
  String get notesSearchHint => 'Cerca note...';

  @override
  String get noNotes => 'Nessuna nota';

  @override
  String get addNote => 'Aggiungi nota';

  @override
  String get editNote => 'Modifica nota';

  @override
  String get noteTitleLabel => 'Titolo';

  @override
  String get noteContentLabel => 'Contenuto';

  @override
  String get noteTagsLabel => 'Tag (separati da virgole)';

  @override
  String get noteTagsHint => 'lavoro, personale, idee';

  @override
  String get remindersTitle => 'Promemoria';

  @override
  String get noReminders => 'Nessun promemoria';

  @override
  String get addReminder => 'Aggiungi promemoria';

  @override
  String get editReminder => 'Modifica promemoria';

  @override
  String get addReminderHint => 'Aggiungi il tuo promemoria qui';

  @override
  String get reminderTypeLabel => 'Tipo di promemoria';

  @override
  String get reminderTypeBirthday => 'Compleanno';

  @override
  String get reminderTypeAppointment => 'Appuntamento';

  @override
  String get reminderTypeTodo => 'Da fare';

  @override
  String get reminderTypeOther => 'Altro';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsAppSectionsHeader => 'Sezioni dell\'app';

  @override
  String get settingsAppSectionsSubtitle =>
      'Seleziona le sezioni che vuoi vedere nell\'app';

  @override
  String get sectionTasks => 'Attività';

  @override
  String get sectionShoppingLists => 'Liste della spesa';

  @override
  String get sectionGuarantees => 'Garanzie';

  @override
  String get sectionNotes => 'Note';

  @override
  String get sectionLoyaltyCards => 'Carte fedeltà';

  @override
  String get settingsColorSchemeHeader => 'Schema colori';

  @override
  String get settingsColorSchemeSubtitle => 'Scegli il tema colori preferito';

  @override
  String get settingsBackupHeader => 'Backup e ripristino';

  @override
  String get settingsBackupSubtitle =>
      'Salva i tuoi dati per trasferirli su un nuovo dispositivo';

  @override
  String get settingsAtLeastOneSection =>
      'Almeno una sezione deve essere attivata';

  @override
  String get settingsAboutHeader => 'Informazioni';

  @override
  String get settingsAboutSubtitle =>
      'Informazioni legali e dettagli dell\'app';

  @override
  String backupLastDate(String date) {
    return 'Ultimo backup: $date';
  }

  @override
  String get backupNeverBackedUp => 'Nessun backup effettuato';

  @override
  String get createBackupButton => 'Crea backup';

  @override
  String get restoreButton => 'Ripristina';

  @override
  String get backupRemindersToggle => 'Promemoria backup';

  @override
  String get reminderFrequencyLabel => 'Frequenza promemoria';

  @override
  String frequencyDays(int count) {
    return '$count giorni';
  }

  @override
  String get privacyPolicyTitle => 'Informativa sulla privacy';

  @override
  String get termsOfServiceTitle => 'Termini di servizio';

  @override
  String get versionLabel => 'Versione';

  @override
  String couldNotOpenUrl(String url) {
    return 'Impossibile aprire $url';
  }

  @override
  String errorOpeningLink(String error) {
    return 'Errore nell\'apertura del link: $error';
  }

  @override
  String get backupDateToday => 'oggi';

  @override
  String get backupDateYesterday => 'ieri';

  @override
  String backupDateDaysAgo(int count) {
    return '$count giorni fa';
  }

  @override
  String backupDateWeekAgo(int count) {
    return '$count settimana fa';
  }

  @override
  String backupDateWeeksAgo(int count) {
    return '$count settimane fa';
  }

  @override
  String backupDateMonthAgo(int count) {
    return '$count mese fa';
  }

  @override
  String backupDateMonthsAgo(int count) {
    return '$count mesi fa';
  }

  @override
  String get restoreBackupDialogTitle => 'Ripristina backup';

  @override
  String get restoreBackupDialogContent =>
      'Come vuoi ripristinare il backup?\n\n• Sostituisci: Elimina tutti i dati attuali e ripristina dal backup\n• Unisci: Combina i dati del backup con i dati attuali';

  @override
  String get restoreMerge => 'Unisci';

  @override
  String get restoreReplace => 'Sostituisci';

  @override
  String get backupCreatedSuccess => 'Backup creato con successo!';

  @override
  String get backupCancelled => 'Backup annullato';

  @override
  String errorCreatingBackup(String error) {
    return 'Errore durante la creazione del backup: $error';
  }

  @override
  String get backupRestoredSuccess =>
      'Backup ripristinato con successo! Dati ricaricati.';

  @override
  String get restoreCancelled => 'Ripristino annullato';

  @override
  String errorRestoringBackup(String error) {
    return 'Errore durante il ripristino del backup: $error';
  }

  @override
  String get shoppingListsTitle => 'Liste della spesa';

  @override
  String get tooltipImportCsv => 'Importa CSV';

  @override
  String get noShoppingLists => 'Nessuna lista della spesa';

  @override
  String importedListSuccess(String name, int itemCount) {
    return '\"$name\" importato con $itemCount articoli';
  }

  @override
  String failedToImport(String error) {
    return 'Importazione fallita: $error';
  }

  @override
  String get shoppingListExported => 'Lista della spesa esportata!';

  @override
  String failedToExport(String error) {
    return 'Esportazione fallita: $error';
  }

  @override
  String get tooltipExportAsCsv => 'Esporta come CSV';

  @override
  String shoppingListItemsCount(int completed, int total) {
    return '$completed / $total articoli';
  }

  @override
  String get shoppingListNameHint => 'Nome lista';

  @override
  String get shoppingListEmptyState =>
      'Nessun articolo ancora\nInizia ad aggiungere qui sotto!';

  @override
  String get restoreCheckedItemLabel => 'Ripristina articolo selezionato';

  @override
  String get itemNameHint => 'Nome articolo…';

  @override
  String itemAlreadyOnList(String name) {
    return '\"$name\" è già nella lista';
  }

  @override
  String get editItemDialogTitle => 'Modifica articolo';

  @override
  String get itemNameLabel => 'Nome articolo';

  @override
  String get quantityLabel => 'Quantità';

  @override
  String get pleaseEnterItemName => 'Inserisci un nome per l\'articolo';

  @override
  String get shoppingTitle => 'Spesa';

  @override
  String get noSectionsEnabledShopping => 'Nessuna sezione attivata';

  @override
  String get tabShoppingLists => 'Liste della spesa';

  @override
  String get tabLoyaltyCards => 'Carte fedeltà';

  @override
  String get tasksTitle => 'Attività';

  @override
  String get filterAllTasks => 'Tutte le attività';

  @override
  String get filterReminders => 'Promemoria';

  @override
  String get filterTodos => 'Da fare';

  @override
  String get noTasks => 'Nessuna attività';

  @override
  String tasksFilterActive(String filter) {
    return 'Filtro: $filter';
  }

  @override
  String get sectionNoDate => 'Senza data';

  @override
  String get sectionHighPriority => 'Priorità alta';

  @override
  String get sectionMediumPriority => 'Priorità media';

  @override
  String get sectionLowPriority => 'Priorità bassa';

  @override
  String get addTask => 'Aggiungi attività';

  @override
  String get editTask => 'Modifica attività';

  @override
  String get addTaskHint => 'Aggiungi la tua attività qui';

  @override
  String get taskTypeLabel => 'Tipo di attività';

  @override
  String get taskTypeBirthday => 'Compleanno';

  @override
  String get taskTypeAppointment => 'Appuntamento';

  @override
  String get taskTypeToDo => 'Da fare';

  @override
  String get taskTypeWarranty => 'Garanzia';

  @override
  String get taskTypeOther => 'Altro';

  @override
  String get todosTitle => 'Da fare';

  @override
  String get noTodos => 'Nessun elemento da fare';

  @override
  String get addToDo => 'Aggiungi da fare';

  @override
  String get editToDo => 'Modifica da fare';

  @override
  String get addToDoHint => 'Aggiungi il tuo elemento qui';

  @override
  String get deleteDialogDefaultMessage =>
      'Questa azione non può essere annullata.';

  @override
  String get settingsLanguageHeader => 'Lingua';

  @override
  String get settingsLanguageSubtitle => 'Scegli la lingua dell\'app';

  @override
  String get languageSystemDefault => 'Predefinito di sistema';

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
