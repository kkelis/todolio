// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get close => 'Fermer';

  @override
  String get retry => 'Réessayer';

  @override
  String get done => 'Terminé';

  @override
  String get ok => 'OK';

  @override
  String errorWithDetails(String error) {
    return 'Erreur : $error';
  }

  @override
  String errorLoadingSettings(String error) {
    return 'Erreur lors du chargement des paramètres : $error';
  }

  @override
  String get notSet => 'Non défini';

  @override
  String get dateAndTime => 'Date et heure';

  @override
  String get priority => 'Priorité';

  @override
  String get repeat => 'Répéter';

  @override
  String get pinned => 'Épinglé';

  @override
  String get completed => 'Terminé';

  @override
  String get overdue => 'En retard';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get next7Days => '7 prochains jours';

  @override
  String get later => 'Plus tard';

  @override
  String get pleaseEnterSomeText => 'Veuillez saisir du texte';

  @override
  String get titleCannotBeEmpty => 'Le titre ne peut pas être vide';

  @override
  String get repeatNone => 'Aucune';

  @override
  String get repeatDaily => 'Quotidien';

  @override
  String get repeatWeekly => 'Hebdomadaire';

  @override
  String get repeatMonthly => 'Mensuel';

  @override
  String get repeatYearly => 'Annuel';

  @override
  String get all => 'Tous';

  @override
  String get pending => 'En attente';

  @override
  String get color => 'Couleur';

  @override
  String get colorNone => 'Aucune';

  @override
  String get unit => 'Unité';

  @override
  String get brandSelectionTitle => 'Sélectionner une marque';

  @override
  String get brandSearchHint => 'Rechercher des marques...';

  @override
  String get createCustomBrand => 'Créer une marque personnalisée';

  @override
  String get selectABrand => 'Sélectionner une marque';

  @override
  String get noBrandsFound => 'Aucune marque trouvée';

  @override
  String get brandNameLabel => 'Nom de la marque';

  @override
  String get brandNameHint => 'Saisir le nom de la marque';

  @override
  String get selectColor => 'Sélectionner une couleur';

  @override
  String get continueToScan => 'Continuer pour scanner';

  @override
  String get guaranteesTitle => 'Garanties';

  @override
  String get noGuarantees => 'Aucune garantie';

  @override
  String get addGuarantee => 'Ajouter une garantie';

  @override
  String get editGuarantee => 'Modifier la garantie';

  @override
  String get productNameLabel => 'Nom du produit';

  @override
  String get purchaseDate => 'Date d\'achat';

  @override
  String get expiryDate => 'Date d\'expiration';

  @override
  String get warrantyPhotoButton => 'Garantie';

  @override
  String get receiptPhotoButton => 'Reçu';

  @override
  String get warrantyPhotoCaptured => 'Photo de garantie prise';

  @override
  String get receiptPhotoCaptured => 'Photo de reçu prise';

  @override
  String get notesLabel => 'Notes';

  @override
  String get setReminder => 'Définir un rappel';

  @override
  String get remindMe => 'Me rappeler';

  @override
  String reminderMonthsBeforeSingular(int count) {
    return '$count mois avant';
  }

  @override
  String reminderMonthsBeforePlural(int count) {
    return '$count mois avant';
  }

  @override
  String get warrantyPhotoDetailLabel => 'Photo de garantie :';

  @override
  String get receiptPhotoDetailLabel => 'Photo de reçu :';

  @override
  String guaranteeExpiresOn(String date) {
    return 'Expire le : $date';
  }

  @override
  String get guaranteeExpired => 'EXPIRÉ';

  @override
  String get guaranteeExpiringSoon => 'Expire bientôt';

  @override
  String get loyaltyCardsTitle => 'Cartes de fidélité';

  @override
  String get loyaltyCardsSearchHint => 'Rechercher des cartes de fidélité...';

  @override
  String get noLoyaltyCards => 'Aucune carte de fidélité';

  @override
  String get noCardsFound => 'Aucune carte trouvée';

  @override
  String get cardUnpinned => 'Carte désépinglée';

  @override
  String get cardPinnedToTop => 'Carte épinglée en haut';

  @override
  String get tooltipUnpin => 'Désépingler';

  @override
  String get tooltipPinToTop => 'Épingler en haut';

  @override
  String get tooltipDelete => 'Supprimer';

  @override
  String get defaultLoyaltyCardName => 'Carte de fidélité';

  @override
  String cardAddedSuccess(String cardName) {
    return 'Carte \"$cardName\" ajoutée avec succès !';
  }

  @override
  String get addLoyaltyCard => 'Ajouter une carte de fidélité';

  @override
  String get editLoyaltyCard => 'Modifier la carte de fidélité';

  @override
  String get cardNameLabel => 'Nom de la carte';

  @override
  String get brandFieldLabel => 'Marque';

  @override
  String get genericCardFallback => 'Carte générique';

  @override
  String get barcodeNumberLabel => 'Numéro de code-barres';

  @override
  String get scanButtonLabel => 'Scanner';

  @override
  String get fillInCardNameAndBarcode =>
      'Veuillez renseigner le nom de la carte et le numéro de code-barres';

  @override
  String get scanBarcodeTitle => 'Scanner le code-barres';

  @override
  String get tooltipPickFromGallery => 'Choisir dans la galerie';

  @override
  String get noBarcodeFoundInImage =>
      'Aucun code-barres trouvé dans l\'image sélectionnée';

  @override
  String errorScanningImage(String error) {
    return 'Erreur lors du scan de l\'image : $error';
  }

  @override
  String get navTasks => 'Tâches';

  @override
  String get navShopping => 'Achats';

  @override
  String get navCards => 'Cartes';

  @override
  String get navGuarantees => 'Garanties';

  @override
  String get navNotes => 'Notes';

  @override
  String get noSectionsEnabled => 'Aucune section activée';

  @override
  String get enableAtLeastOneSection =>
      'Activer au moins une section dans les Paramètres';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get devModeDrawerHeader => 'Dev Mode';

  @override
  String get drawerSettings => 'Paramètres';

  @override
  String get drawerTestNotification => 'Notification de test';

  @override
  String get drawerTestNotificationSubtitle =>
      'Envoyer une notification de test';

  @override
  String get testNotificationSent => 'Notification de test envoyée !';

  @override
  String get drawerRequestPermissions => 'Demander les autorisations';

  @override
  String get drawerRequestPermissionsSubtitle =>
      'Demander les autorisations de notification';

  @override
  String get notificationPermissionsGranted =>
      'Autorisations de notification accordées ! ✅';

  @override
  String get notificationPermissionsDenied =>
      'Autorisations de notification refusées. Veuillez les activer dans les paramètres.';

  @override
  String get drawerCheckNotificationStatus =>
      'Vérifier le statut des notifications';

  @override
  String get drawerCheckNotificationStatusSubtitle =>
      'Afficher le statut des notifications et les notifications en attente';

  @override
  String get notificationStatusDialogTitle => 'Statut des notifications';

  @override
  String notificationsEnabledStatus(String status) {
    return 'Notifications activées : $status';
  }

  @override
  String pendingNotificationsCount(int count) {
    return 'Notifications en attente : $count';
  }

  @override
  String get notificationStatusPendingHeader => 'En attente :';

  @override
  String andNMore(int count) {
    return '... et $count de plus';
  }

  @override
  String get notificationsDisabledWarning =>
      '⚠️ Les notifications sont désactivées. Veuillez les activer dans les Paramètres.';

  @override
  String get devModeNoAuth => 'Dev Mode - Sans authentification';

  @override
  String get devModeNoAuthSubtitle =>
      'Authentification désactivée pour le développement';

  @override
  String get notesTitle => 'Notes';

  @override
  String get notesSearchHint => 'Rechercher des notes...';

  @override
  String get noNotes => 'Aucune note';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String get editNote => 'Modifier la note';

  @override
  String get noteTitleLabel => 'Titre';

  @override
  String get noteContentLabel => 'Contenu';

  @override
  String get noteTagsLabel => 'Étiquettes (séparées par des virgules)';

  @override
  String get noteTagsHint => 'travail, personnel, idées';

  @override
  String get remindersTitle => 'Rappels';

  @override
  String get noReminders => 'Aucun rappel';

  @override
  String get addReminder => 'Ajouter un rappel';

  @override
  String get editReminder => 'Modifier le rappel';

  @override
  String get addReminderHint => 'Ajoutez votre rappel ici';

  @override
  String get reminderTypeLabel => 'Type de rappel';

  @override
  String get reminderTypeBirthday => 'Anniversaire';

  @override
  String get reminderTypeAppointment => 'Rendez-vous';

  @override
  String get reminderTypeTodo => 'Tâche';

  @override
  String get reminderTypeOther => 'Autre';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppSectionsHeader => 'Sections de l\'application';

  @override
  String get settingsAppSectionsSubtitle =>
      'Sélectionnez les sections que vous souhaitez voir dans l\'application';

  @override
  String get sectionTasks => 'Tâches';

  @override
  String get sectionShoppingLists => 'Listes de courses';

  @override
  String get sectionGuarantees => 'Garanties';

  @override
  String get sectionNotes => 'Notes';

  @override
  String get sectionLoyaltyCards => 'Cartes de fidélité';

  @override
  String get settingsColorSchemeHeader => 'Schéma de couleurs';

  @override
  String get settingsColorSchemeSubtitle =>
      'Choisissez votre thème de couleur préféré';

  @override
  String get settingsBackupHeader => 'Backup et restauration';

  @override
  String get settingsBackupSubtitle =>
      'Sauvegardez vos données pour les transférer sur un nouvel appareil';

  @override
  String get settingsAtLeastOneSection =>
      'Au moins une section doit être activée';

  @override
  String get settingsAboutHeader => 'À propos';

  @override
  String get settingsAboutSubtitle =>
      'Informations légales et détails de l\'application';

  @override
  String backupLastDate(String date) {
    return 'Dernier backup : $date';
  }

  @override
  String get backupNeverBackedUp => 'Jamais sauvegardé';

  @override
  String get createBackupButton => 'Créer un backup';

  @override
  String get restoreButton => 'Restaurer';

  @override
  String get backupRemindersToggle => 'Rappels de backup';

  @override
  String get reminderFrequencyLabel => 'Fréquence des rappels';

  @override
  String frequencyDays(int count) {
    return '$count jours';
  }

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get termsOfServiceTitle => 'Conditions d\'utilisation';

  @override
  String get versionLabel => 'Version';

  @override
  String couldNotOpenUrl(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String errorOpeningLink(String error) {
    return 'Erreur lors de l\'ouverture du lien : $error';
  }

  @override
  String get backupDateToday => 'aujourd\'hui';

  @override
  String get backupDateYesterday => 'hier';

  @override
  String backupDateDaysAgo(int count) {
    return 'il y a $count jours';
  }

  @override
  String backupDateWeekAgo(int count) {
    return 'il y a $count semaine';
  }

  @override
  String backupDateWeeksAgo(int count) {
    return 'il y a $count semaines';
  }

  @override
  String backupDateMonthAgo(int count) {
    return 'il y a $count mois';
  }

  @override
  String backupDateMonthsAgo(int count) {
    return 'il y a $count mois';
  }

  @override
  String get restoreBackupDialogTitle => 'Restaurer le backup';

  @override
  String get restoreBackupDialogContent =>
      'Comment souhaitez-vous restaurer le backup ?\n\n• Remplacer : Supprimer toutes les données actuelles et restaurer depuis le backup\n• Fusionner : Combiner les données du backup avec les données actuelles';

  @override
  String get restoreMerge => 'Fusionner';

  @override
  String get restoreReplace => 'Remplacer';

  @override
  String get backupCreatedSuccess => 'Backup créé avec succès !';

  @override
  String get backupCancelled => 'Backup annulé';

  @override
  String errorCreatingBackup(String error) {
    return 'Erreur lors de la création du backup : $error';
  }

  @override
  String get backupRestoredSuccess =>
      'Backup restauré avec succès ! Données rechargées.';

  @override
  String get restoreCancelled => 'Restauration annulée';

  @override
  String errorRestoringBackup(String error) {
    return 'Erreur lors de la restauration du backup : $error';
  }

  @override
  String get shoppingListsTitle => 'Listes de courses';

  @override
  String get tooltipImportCsv => 'Importer CSV';

  @override
  String get noShoppingLists => 'Aucune liste de courses';

  @override
  String importedListSuccess(String name, int itemCount) {
    return '\"$name\" importé avec $itemCount articles';
  }

  @override
  String failedToImport(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get shoppingListExported => 'Liste de courses exportée !';

  @override
  String failedToExport(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get tooltipExportAsCsv => 'Exporter en CSV';

  @override
  String shoppingListItemsCount(int completed, int total) {
    return '$completed / $total articles';
  }

  @override
  String get shoppingListNameHint => 'Nom de la liste';

  @override
  String get shoppingListEmptyState =>
      'Aucun article pour l\'instant\nCommencez à en ajouter ci-dessous !';

  @override
  String get restoreCheckedItemLabel => 'Restaurer l\'article coché';

  @override
  String get itemNameHint => 'Nom de l\'article…';

  @override
  String itemAlreadyOnList(String name) {
    return '\"$name\" est déjà sur la liste';
  }

  @override
  String get editItemDialogTitle => 'Modifier l\'article';

  @override
  String get itemNameLabel => 'Nom de l\'article';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get pleaseEnterItemName => 'Veuillez saisir un nom d\'article';

  @override
  String get shoppingTitle => 'Achats';

  @override
  String get noSectionsEnabledShopping => 'Aucune section activée';

  @override
  String get tabShoppingLists => 'Listes de courses';

  @override
  String get tabLoyaltyCards => 'Cartes de fidélité';

  @override
  String get tasksTitle => 'Tâches';

  @override
  String get filterAllTasks => 'Toutes les tâches';

  @override
  String get filterReminders => 'Rappels';

  @override
  String get filterTodos => 'Tâches';

  @override
  String get noTasks => 'Aucune tâche';

  @override
  String tasksFilterActive(String filter) {
    return 'Filtre : $filter';
  }

  @override
  String get sectionNoDate => 'Sans date';

  @override
  String get sectionHighPriority => 'Priorité haute';

  @override
  String get sectionMediumPriority => 'Priorité moyenne';

  @override
  String get sectionLowPriority => 'Priorité basse';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String get editTask => 'Modifier la tâche';

  @override
  String get addTaskHint => 'Ajoutez votre tâche ici';

  @override
  String get taskTypeLabel => 'Type de tâche';

  @override
  String get taskTypeBirthday => 'Anniversaire';

  @override
  String get taskTypeAppointment => 'Rendez-vous';

  @override
  String get taskTypeToDo => 'Tâche';

  @override
  String get taskTypeWarranty => 'Garantie';

  @override
  String get taskTypeOther => 'Autre';

  @override
  String get todosTitle => 'Tâches';

  @override
  String get noTodos => 'Aucune tâche';

  @override
  String get addToDo => 'Ajouter une tâche';

  @override
  String get editToDo => 'Modifier la tâche';

  @override
  String get addToDoHint => 'Ajoutez votre tâche ici';

  @override
  String get deleteDialogDefaultMessage => 'Cette action est irréversible.';

  @override
  String get settingsLanguageHeader => 'Langue';

  @override
  String get settingsLanguageSubtitle =>
      'Choisissez la langue de l\'application';

  @override
  String get languageSystemDefault => 'Par défaut du système';

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
