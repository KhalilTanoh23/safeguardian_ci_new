import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safeguardian_ci_new/core/constants/api_constants.dart';

/// Service API pour toutes les requêtes HTTP vers le backend
class ApiService {
  static final ApiService _instance = ApiService._internal();

  late String _baseUrl;
  late http.Client _httpClient;
  late String? _token;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _baseUrl = apiBaseUrl;
    _httpClient = http.Client();
    _initToken();
  }

  /// Initialiser le token depuis le stockage local
  Future<void> _initToken() async {
    // TODO: Implémenter le stockage sécurisé avec flutter_secure_storage
    // Pour l'instant, on utilise juste une variable
    _token = null;
  }

  /// Sauvegarder le token
  Future<void> saveToken(String token) async {
    _token = token;
    // TODO: Sauvegarder dans flutter_secure_storage en production
  }

  /// Supprimer le token
  Future<void> deleteToken() async {
    _token = null;
    // TODO: Supprimer du flutter_secure_storage en production
  }

  /// Obtenir les headers avec token
  Map<String, String> _getHeaders() {
    final headers = Map<String, String>.from(defaultHeaders);
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// ═══════════════════════════════════════════════════════════════
  /// AUTH ENDPOINTS
  /// ═══════════════════════════════════════════════════════════════

  /// Register - Enregistrer un nouvel utilisateur
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl${apiEndpoints['register']}'),
            headers: _getHeaders(),
            body: jsonEncode({
              'email': email,
              'password': password,
              'first_name': firstName,
              'last_name': lastName,
              'phone': phone ?? '',
            }),
          )
          .timeout(requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Login - Se connecter
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl${apiEndpoints['login']}'),
            headers: _getHeaders(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(requestTimeout);

      final result = _handleResponse(response);
      if (result['token'] != null) {
        await saveToken(result['token']);
      }
      return result;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout - Se déconnecter
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl${apiEndpoints['logout']}'),
            headers: _getHeaders(),
          )
          .timeout(requestTimeout);

      await deleteToken();
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Profile - Récupérer le profil
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('$_baseUrl${apiEndpoints['profile']}'),
            headers: _getHeaders(),
          )
          .timeout(requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// ALERTS ENDPOINTS
  /// ═══════════════════════════════════════════════════════════════

  /// Create Alert - Créer une alerte
  Future<Map<String, dynamic>> createAlert({
    required String title,
    required String description,
    String type = 'info',
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl${apiEndpoints['createAlert']}'),
            headers: _getHeaders(),
            body: jsonEncode({
              'title': title,
              'description': description,
              'type': type,
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Alerts - Récupérer les alertes
  Future<Map<String, dynamic>> getAlerts() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('$_baseUrl${apiEndpoints['getAlerts']}'),
            headers: _getHeaders(),
          )
          .timeout(requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// CONTACTS ENDPOINTS
  /// ═══════════════════════════════════════════════════════════════

  /// Get Contacts - Récupérer les contacts d'urgence
  Future<Map<String, dynamic>> getContacts() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('$_baseUrl${apiEndpoints['getContacts']}'),
            headers: _getHeaders(),
          )
          .timeout(requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Add Contact - Ajouter un contact d'urgence
  Future<Map<String, dynamic>> addContact({
    required String name,
    required String phone,
    String? email,
    String? relationship,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl${apiEndpoints['addContact']}'),
            headers: _getHeaders(),
            body: jsonEncode({
              'name': name,
              'phone': phone,
              'email': email,
              'relationship': relationship,
            }),
          )
          .timeout(requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// ITEMS ENDPOINTS
  /// ═══════════════════════════════════════════════════════════════

  /// Get Items - Récupérer les objets
  Future<Map<String, dynamic>> getItems() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('$_baseUrl${apiEndpoints['getItems']}'),
            headers: _getHeaders(),
          )
          .timeout(requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Add Item - Ajouter un objet
  Future<Map<String, dynamic>> addItem({
    required String name,
    required String category,
    String? description,
    String? serialNumber,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl${apiEndpoints['addItem']}'),
            headers: _getHeaders(),
            body: jsonEncode({
              'name': name,
              'category': category,
              'description': description,
              'serial_number': serialNumber,
            }),
          )
          .timeout(requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// HELPER METHODS
  /// ═══════════════════════════════════════════════════════════════

  /// Traiter la réponse HTTP
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        throw ApiException(
          message: body['message'] ?? 'Erreur serveur',
          statusCode: response.statusCode,
          errors: body['errors'],
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Erreur de parsing: $e',
        statusCode: response.statusCode,
      );
    }
  }

  /// Gérer les erreurs
  ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    String message = 'Erreur de connexion';
    int statusCode = 0;

    if (error is http.ClientException) {
      message = 'Erreur de connexion: ${error.message}';
    }

    return ApiException(message: message, statusCode: statusCode);
  }
}

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, required this.statusCode, this.errors});

  @override
  String toString() => message;
}

