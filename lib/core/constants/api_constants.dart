// Configuration API Flutter - Fichier à ajouter dans lib/core/services/

const String apiBaseUrl =
    'http://10.0.2.2:8000/api'; // 10.0.2.2 = localhost pour émulateur Android

// Endpoints
const Map<String, String> apiEndpoints = {
  // Auth
  'login': '/auth/login',
  'register': '/auth/register',
  'logout': '/auth/logout',
  'profile': '/auth/profile',
  'updateProfile': '/auth/profile/update',

  // Alerts
  'createAlert': '/alerts/create',
  'getAlerts': '/alerts',
  'getAlert': '/alerts/:id',
  'updateAlert': '/alerts/:id',
  'deleteAlert': '/alerts/:id',
  'getAlertHistory': '/alerts/history',

  // Emergency Contacts
  'getContacts': '/contacts',
  'addContact': '/contacts/add',
  'updateContact': '/contacts/:id',
  'deleteContact': '/contacts/:id',
  'verifyContact': '/contacts/:id/verify',

  // Items
  'getItems': '/items',
  'addItem': '/items/add',
  'updateItem': '/items/:id',
  'deleteItem': '/items/:id',
  'markItemLost': '/items/:id/lost',
  'markItemFound': '/items/:id/found',

  // Documents
  'getDocuments': '/documents',
  'uploadDocument': '/documents/upload',
  'deleteDocument': '/documents/:id',
  'shareDocument': '/documents/:id/share',
  'getSharedDocuments': '/documents/shared',

  // Location
  'updateLocation': '/location/update',
  'getLocations': '/location/history',

  // Settings
  'getSettings': '/settings',
  'updateSettings': '/settings/update',
};

// Timeouts
const Duration requestTimeout = Duration(seconds: 30);
const Duration connectTimeout = Duration(seconds: 10);

// Headers
const Map<String, String> defaultHeaders = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'User-Agent': 'SafeGuardian/1.0.0',
};

// Error Messages
const Map<int, String> httpErrorMessages = {
  400: 'Requête invalide',
  401: 'Non authentifié',
  403: 'Accès refusé',
  404: 'Ressource non trouvée',
  422: 'Données invalides',
  429: 'Trop de requêtes',
  500: 'Erreur serveur',
  503: 'Service indisponible',
};
