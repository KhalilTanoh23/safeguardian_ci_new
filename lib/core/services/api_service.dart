import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/emergency_contact.dart';
import '../../data/models/alert.dart';
import '../../data/models/item.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:8000/api'; // Changez selon votre configuration
  static const String tokenKey = 'auth_token';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<void> initialize() async {
    // Initialisation si nécessaire
  }

  // Gestion du token JWT
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Headers avec authentification
  Future<Map<String, String>> _getHeaders({bool auth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Gestion des erreurs
  Exception _handleError(http.Response response) {
    final data = json.decode(response.body);
    final message = data['error'] ?? 'Erreur inconnue';
    return Exception(message);
  }

  // Authentification
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _getHeaders(auth: false),
      body: json.encode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await setToken(data['token']);
      return data;
    } else {
      throw _handleError(response);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _getHeaders(auth: false),
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await setToken(data['token']);
      return data;
    } else {
      throw _handleError(response);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  Future<Map<String, dynamic>> updateUserSettings(
    Map<String, dynamic> settings,
  ) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/auth/settings'),
      headers: await _getHeaders(),
      body: json.encode(settings),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  Future<void> logout() async {
    await removeToken();
  }

  // Contacts d'urgence
  Future<List<EmergencyContact>> getContacts() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/contacts'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => EmergencyContact.fromJson(json)).toList();
    } else {
      throw _handleError(response);
    }
  }

  Future<EmergencyContact> addContact(EmergencyContact contact) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/contacts'),
      headers: await _getHeaders(),
      body: json.encode({
        'name': contact.name,
        'relationship': contact.relationship,
        'phone': contact.phone,
        'email': contact.email,
        'priority': contact.priority,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return EmergencyContact(
        id: data['id'],
        userId: contact.userId,
        name: contact.name,
        relationship: contact.relationship,
        phone: contact.phone,
        email: contact.email,
        priority: contact.priority,
        color: contact.color,
        isVerified: contact.isVerified,
        canSeeLiveLocation: contact.canSeeLiveLocation,
        lastAlert: contact.lastAlert,
        responseTime: contact.responseTime,
        addedDate: contact.addedDate,
        notes: contact.notes,
      );
    } else {
      throw _handleError(response);
    }
  }

  Future<void> updateContact(EmergencyContact contact) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/contacts/${contact.id}'),
      headers: await _getHeaders(),
      body: json.encode({
        'name': contact.name,
        'relationship': contact.relationship,
        'phone': contact.phone,
        'email': contact.email,
        'priority': contact.priority,
      }),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  Future<void> deleteContact(String contactId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/contacts/$contactId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  // Alertes
  Future<List<EmergencyAlert>> getAlerts() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/alerts'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => EmergencyAlert.fromJson(json)).toList();
    } else {
      throw _handleError(response);
    }
  }

  Future<EmergencyAlert> createAlert({
    required double latitude,
    required double longitude,
    String? message,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/alerts'),
      headers: await _getHeaders(),
      body: json.encode({
        'latitude': latitude,
        'longitude': longitude,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Retourner une alerte basique (l'API retournera les détails complets)
      return EmergencyAlert(
        id: data['id'],
        userId: '', // Sera défini côté serveur
        location: LatLng(latitude, longitude),
        timestamp: DateTime.now(),
        message: message,
      );
    } else {
      throw _handleError(response);
    }
  }

  Future<void> updateAlertStatus(String alertId, AlertStatus status) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/alerts/$alertId'),
      headers: await _getHeaders(),
      body: json.encode({'status': status.name}),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  // Objets
  Future<List<ValuedItem>> getItems() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/items'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => ValuedItem.fromJson(json)).toList();
    } else {
      throw _handleError(response);
    }
  }

  Future<ValuedItem> addItem(ValuedItem item) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/items'),
      headers: await _getHeaders(),
      body: json.encode({
        'name': item.name,
        'description': item.description,
        'category': item.category.name,
        'value': item.estimatedValue,
        'imageUrl': item.photoPath,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return item.copyWith(id: data['id']);
    } else {
      throw _handleError(response);
    }
  }

  Future<void> updateItem(ValuedItem item) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/items/${item.id}'),
      headers: await _getHeaders(),
      body: json.encode({
        'name': item.name,
        'description': item.description,
        'category': item.category.name,
        'value': item.estimatedValue,
        'imageUrl': item.photoPath,
        'isLost': item.isLost,
      }),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  Future<void> deleteItem(String itemId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/items/$itemId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  Future<void> markItemAsLost(String itemId, bool isLost) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/items/$itemId'),
      headers: await _getHeaders(),
      body: json.encode({'isLost': isLost}),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  // Documents (à implémenter selon les besoins)
  Future<List<Map<String, dynamic>>> getDocuments() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/documents'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw _handleError(response);
    }
  }

  Future<Map<String, dynamic>> addDocument(
    Map<String, dynamic> document,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/documents'),
      headers: await _getHeaders(),
      body: json.encode(document),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  Future<void> deleteDocument(String documentId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/documents/$documentId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }
}
