// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get close => 'Cerrar';

  @override
  String get retry => 'Reintentar';

  @override
  String get done => 'Hecho';

  @override
  String get ok => 'OK';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String errorLoadingSettings(String error) {
    return 'Error al cargar la configuración: $error';
  }

  @override
  String get notSet => 'No establecido';

  @override
  String get dateAndTime => 'Fecha y hora';

  @override
  String get priority => 'Prioridad';

  @override
  String get repeat => 'Repetir';

  @override
  String get pinned => 'Fijado';

  @override
  String get completed => 'Completado';

  @override
  String get overdue => 'Vencido';

  @override
  String get today => 'Hoy';

  @override
  String get next7Days => 'Próximos 7 días';

  @override
  String get later => 'Más tarde';

  @override
  String get pleaseEnterSomeText => 'Por favor, introduce algún texto';

  @override
  String get titleCannotBeEmpty => 'El título no puede estar vacío';

  @override
  String get repeatNone => 'Ninguno';

  @override
  String get repeatDaily => 'Diario';

  @override
  String get repeatWeekly => 'Semanal';

  @override
  String get repeatMonthly => 'Mensual';

  @override
  String get repeatYearly => 'Anual';

  @override
  String get all => 'Todos';

  @override
  String get pending => 'Pendiente';

  @override
  String get color => 'Color';

  @override
  String get colorNone => 'Ninguno';

  @override
  String get unit => 'Unidad';

  @override
  String get brandSelectionTitle => 'Seleccionar marca';

  @override
  String get brandSearchHint => 'Buscar marcas...';

  @override
  String get createCustomBrand => 'Crear marca personalizada';

  @override
  String get selectABrand => 'Seleccionar una marca';

  @override
  String get noBrandsFound => 'No se encontraron marcas';

  @override
  String get brandNameLabel => 'Nombre de marca';

  @override
  String get brandNameHint => 'Introduce el nombre de la marca';

  @override
  String get selectColor => 'Seleccionar color';

  @override
  String get continueToScan => 'Continuar al escaneo';

  @override
  String get guaranteesTitle => 'Garantías';

  @override
  String get noGuarantees => 'No hay garantías';

  @override
  String get addGuarantee => 'Añadir garantía';

  @override
  String get editGuarantee => 'Editar garantía';

  @override
  String get productNameLabel => 'Nombre del producto';

  @override
  String get purchaseDate => 'Fecha de compra';

  @override
  String get expiryDate => 'Fecha de vencimiento';

  @override
  String get warrantyPhotoButton => 'Garantía';

  @override
  String get receiptPhotoButton => 'Recibo';

  @override
  String get warrantyPhotoCaptured => 'Foto de garantía capturada';

  @override
  String get receiptPhotoCaptured => 'Foto de recibo capturada';

  @override
  String get notesLabel => 'Notas';

  @override
  String get setReminder => 'Establecer recordatorio';

  @override
  String get remindMe => 'Recuérdame';

  @override
  String reminderMonthsBeforeSingular(int count) {
    return '$count mes antes';
  }

  @override
  String reminderMonthsBeforePlural(int count) {
    return '$count meses antes';
  }

  @override
  String get warrantyPhotoDetailLabel => 'Foto de garantía:';

  @override
  String get receiptPhotoDetailLabel => 'Foto de recibo:';

  @override
  String guaranteeExpiresOn(String date) {
    return 'Vence: $date';
  }

  @override
  String get guaranteeExpired => 'VENCIDO';

  @override
  String get guaranteeExpiringSoon => 'Vence pronto';

  @override
  String get loyaltyCardsTitle => 'Tarjetas de fidelización';

  @override
  String get loyaltyCardsSearchHint => 'Buscar tarjetas de fidelización...';

  @override
  String get noLoyaltyCards => 'No hay tarjetas de fidelización';

  @override
  String get noCardsFound => 'No se encontraron tarjetas';

  @override
  String get cardUnpinned => 'Tarjeta desanclada';

  @override
  String get cardPinnedToTop => 'Tarjeta anclada arriba';

  @override
  String get tooltipUnpin => 'Desanclar';

  @override
  String get tooltipPinToTop => 'Anclar arriba';

  @override
  String get tooltipDelete => 'Eliminar';

  @override
  String get defaultLoyaltyCardName => 'Tarjeta de fidelización';

  @override
  String cardAddedSuccess(String cardName) {
    return '¡Tarjeta \"$cardName\" añadida correctamente!';
  }

  @override
  String get addLoyaltyCard => 'Añadir tarjeta de fidelización';

  @override
  String get editLoyaltyCard => 'Editar tarjeta de fidelización';

  @override
  String get cardNameLabel => 'Nombre de la tarjeta';

  @override
  String get brandFieldLabel => 'Marca';

  @override
  String get genericCardFallback => 'Tarjeta genérica';

  @override
  String get barcodeNumberLabel => 'Número de código de barras';

  @override
  String get scanButtonLabel => 'Escanear';

  @override
  String get fillInCardNameAndBarcode =>
      'Por favor, rellena el nombre de la tarjeta y el código de barras';

  @override
  String get scanBarcodeTitle => 'Escanear código de barras';

  @override
  String get tooltipPickFromGallery => 'Seleccionar de la galería';

  @override
  String get noBarcodeFoundInImage =>
      'No se encontró código de barras en la imagen seleccionada';

  @override
  String errorScanningImage(String error) {
    return 'Error al escanear la imagen: $error';
  }

  @override
  String get navTasks => 'Tareas';

  @override
  String get navShopping => 'Compras';

  @override
  String get navCards => 'Tarjetas';

  @override
  String get navGuarantees => 'Garantías';

  @override
  String get navNotes => 'Notas';

  @override
  String get noSectionsEnabled => 'No hay secciones activadas';

  @override
  String get enableAtLeastOneSection =>
      'Activa al menos una sección en Configuración';

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get devModeDrawerHeader => 'Dev Mode';

  @override
  String get drawerSettings => 'Configuración';

  @override
  String get drawerTestNotification => 'Notificación de prueba';

  @override
  String get drawerTestNotificationSubtitle =>
      'Enviar una notificación de prueba';

  @override
  String get testNotificationSent => '¡Notificación de prueba enviada!';

  @override
  String get drawerRequestPermissions => 'Solicitar permisos';

  @override
  String get drawerRequestPermissionsSubtitle =>
      'Solicitar permisos de notificación';

  @override
  String get notificationPermissionsGranted =>
      '¡Permisos de notificación concedidos! ✅';

  @override
  String get notificationPermissionsDenied =>
      'Permisos de notificación denegados. Por favor, actívalos en la configuración.';

  @override
  String get drawerCheckNotificationStatus =>
      'Comprobar estado de notificaciones';

  @override
  String get drawerCheckNotificationStatusSubtitle =>
      'Ver el estado de notificaciones y notificaciones pendientes';

  @override
  String get notificationStatusDialogTitle => 'Estado de notificaciones';

  @override
  String notificationsEnabledStatus(String status) {
    return 'Notificaciones activadas: $status';
  }

  @override
  String pendingNotificationsCount(int count) {
    return 'Notificaciones pendientes: $count';
  }

  @override
  String get notificationStatusPendingHeader => 'Pendientes:';

  @override
  String andNMore(int count) {
    return '... y $count más';
  }

  @override
  String get notificationsDisabledWarning =>
      '⚠️ Las notificaciones están desactivadas. Por favor, actívalas en Configuración.';

  @override
  String get devModeNoAuth => 'Dev Mode - Sin autenticación';

  @override
  String get devModeNoAuthSubtitle =>
      'Autenticación desactivada para desarrollo';

  @override
  String get notesTitle => 'Notas';

  @override
  String get notesSearchHint => 'Buscar notas...';

  @override
  String get noNotes => 'No hay notas';

  @override
  String get addNote => 'Añadir nota';

  @override
  String get editNote => 'Editar nota';

  @override
  String get noteTitleLabel => 'Título';

  @override
  String get noteContentLabel => 'Contenido';

  @override
  String get noteTagsLabel => 'Etiquetas (separadas por comas)';

  @override
  String get noteTagsHint => 'trabajo, personal, ideas';

  @override
  String get remindersTitle => 'Recordatorios';

  @override
  String get noReminders => 'No hay recordatorios';

  @override
  String get addReminder => 'Añadir recordatorio';

  @override
  String get editReminder => 'Editar recordatorio';

  @override
  String get addReminderHint => 'Añade tu recordatorio aquí';

  @override
  String get reminderTypeLabel => 'Tipo de recordatorio';

  @override
  String get reminderTypeBirthday => 'Cumpleaños';

  @override
  String get reminderTypeAppointment => 'Cita';

  @override
  String get reminderTypeTodo => 'Tarea pendiente';

  @override
  String get reminderTypeOther => 'Otro';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAppSectionsHeader => 'Secciones de la app';

  @override
  String get settingsAppSectionsSubtitle =>
      'Selecciona qué secciones quieres ver en la app';

  @override
  String get sectionTasks => 'Tareas';

  @override
  String get sectionShoppingLists => 'Listas de compras';

  @override
  String get sectionGuarantees => 'Garantías';

  @override
  String get sectionNotes => 'Notas';

  @override
  String get sectionLoyaltyCards => 'Tarjetas de fidelización';

  @override
  String get settingsColorSchemeHeader => 'Esquema de colores';

  @override
  String get settingsColorSchemeSubtitle => 'Elige tu tema de color preferido';

  @override
  String get settingsBackupHeader => 'Backup y restauración';

  @override
  String get settingsBackupSubtitle =>
      'Haz un backup de tus datos para transferirlos a un nuevo dispositivo';

  @override
  String get settingsAtLeastOneSection =>
      'Al menos una sección debe estar activada';

  @override
  String get settingsAboutHeader => 'Acerca de';

  @override
  String get settingsAboutSubtitle => 'Información legal y detalles de la app';

  @override
  String backupLastDate(String date) {
    return 'Último backup: $date';
  }

  @override
  String get backupNeverBackedUp => 'Nunca se ha hecho un backup';

  @override
  String get createBackupButton => 'Crear backup';

  @override
  String get restoreButton => 'Restaurar';

  @override
  String get backupRemindersToggle => 'Recordatorios de backup';

  @override
  String get reminderFrequencyLabel => 'Frecuencia de recordatorio';

  @override
  String frequencyDays(int count) {
    return '$count días';
  }

  @override
  String get privacyPolicyTitle => 'Política de privacidad';

  @override
  String get termsOfServiceTitle => 'Términos de servicio';

  @override
  String get versionLabel => 'Versión';

  @override
  String couldNotOpenUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String errorOpeningLink(String error) {
    return 'Error al abrir el enlace: $error';
  }

  @override
  String get backupDateToday => 'hoy';

  @override
  String get backupDateYesterday => 'ayer';

  @override
  String backupDateDaysAgo(int count) {
    return 'hace $count días';
  }

  @override
  String backupDateWeekAgo(int count) {
    return 'hace $count semana';
  }

  @override
  String backupDateWeeksAgo(int count) {
    return 'hace $count semanas';
  }

  @override
  String backupDateMonthAgo(int count) {
    return 'hace $count mes';
  }

  @override
  String backupDateMonthsAgo(int count) {
    return 'hace $count meses';
  }

  @override
  String get restoreBackupDialogTitle => 'Restaurar backup';

  @override
  String get restoreBackupDialogContent =>
      '¿Cómo deseas restaurar el backup?\n\n• Reemplazar: Eliminar todos los datos actuales y restaurar desde el backup\n• Combinar: Combinar los datos del backup con los datos actuales';

  @override
  String get restoreMerge => 'Combinar';

  @override
  String get restoreReplace => 'Reemplazar';

  @override
  String get backupCreatedSuccess => '¡Backup creado correctamente!';

  @override
  String get backupCancelled => 'Backup cancelado';

  @override
  String errorCreatingBackup(String error) {
    return 'Error al crear el backup: $error';
  }

  @override
  String get backupRestoredSuccess =>
      '¡Backup restaurado correctamente! Datos recargados.';

  @override
  String get restoreCancelled => 'Restauración cancelada';

  @override
  String errorRestoringBackup(String error) {
    return 'Error al restaurar el backup: $error';
  }

  @override
  String get shoppingListsTitle => 'Listas de compras';

  @override
  String get tooltipImportCsv => 'Importar CSV';

  @override
  String get noShoppingLists => 'No hay listas de compras';

  @override
  String importedListSuccess(String name, int itemCount) {
    return '\"$name\" importado con $itemCount artículos';
  }

  @override
  String failedToImport(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get shoppingListExported => '¡Lista de compras exportada!';

  @override
  String failedToExport(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get tooltipExportAsCsv => 'Exportar como CSV';

  @override
  String shoppingListItemsCount(int completed, int total) {
    return '$completed / $total artículos';
  }

  @override
  String get shoppingListNameHint => 'Nombre de la lista';

  @override
  String get shoppingListEmptyState =>
      'Sin artículos todavía\n¡Empieza a añadir abajo!';

  @override
  String get restoreCheckedItemLabel => 'Restaurar artículo marcado';

  @override
  String get itemNameHint => 'Nombre del artículo…';

  @override
  String itemAlreadyOnList(String name) {
    return '\"$name\" ya está en la lista';
  }

  @override
  String get editItemDialogTitle => 'Editar artículo';

  @override
  String get itemNameLabel => 'Nombre del artículo';

  @override
  String get quantityLabel => 'Cantidad';

  @override
  String get pleaseEnterItemName =>
      'Por favor, introduce un nombre de artículo';

  @override
  String get shoppingTitle => 'Compras';

  @override
  String get noSectionsEnabledShopping => 'No hay secciones activadas';

  @override
  String get tabShoppingLists => 'Listas de compras';

  @override
  String get tabLoyaltyCards => 'Tarjetas de fidelización';

  @override
  String get tasksTitle => 'Tareas';

  @override
  String get filterAllTasks => 'Todas las tareas';

  @override
  String get filterReminders => 'Recordatorios';

  @override
  String get filterTodos => 'Tareas pendientes';

  @override
  String get noTasks => 'No hay tareas';

  @override
  String tasksFilterActive(String filter) {
    return 'Filtro: $filter';
  }

  @override
  String get sectionNoDate => 'Sin fecha';

  @override
  String get sectionHighPriority => 'Prioridad alta';

  @override
  String get sectionMediumPriority => 'Prioridad media';

  @override
  String get sectionLowPriority => 'Prioridad baja';

  @override
  String get addTask => 'Añadir tarea';

  @override
  String get editTask => 'Editar tarea';

  @override
  String get addTaskHint => 'Añade tu tarea aquí';

  @override
  String get taskTypeLabel => 'Tipo de tarea';

  @override
  String get taskTypeBirthday => 'Cumpleaños';

  @override
  String get taskTypeAppointment => 'Cita';

  @override
  String get taskTypeToDo => 'Tarea pendiente';

  @override
  String get taskTypeWarranty => 'Garantía';

  @override
  String get taskTypeOther => 'Otro';

  @override
  String get todosTitle => 'Tareas pendientes';

  @override
  String get noTodos => 'No hay tareas pendientes';

  @override
  String get addToDo => 'Añadir tarea pendiente';

  @override
  String get editToDo => 'Editar tarea pendiente';

  @override
  String get addToDoHint => 'Añade tu tarea pendiente aquí';

  @override
  String get deleteDialogDefaultMessage => 'Esta acción no se puede deshacer.';

  @override
  String get settingsLanguageHeader => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Elige el idioma de la aplicación';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

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
