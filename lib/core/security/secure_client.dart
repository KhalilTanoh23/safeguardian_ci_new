// 🔒 SECURE HTTP CLIENT - SafeGuardian CI
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔐 SECURE TOKEN STORAGE
class SecureTokenStorage {
  static const _tokenKey = 'jwt_token_safeguardian';

  /// Sauvegarder le token
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      debugPrint('✅ Token sauvegardé');
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      rethrow;
    }
  }

  /// Récupérer le token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      return null;
    }
  }

  /// Supprimer le token
  static Future<void> deleteToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      debugPrint('✅ Token supprimé');
    } catch (e) {
      debugPrint('❌ Erreur: $e');
    }
  }

  /// Vérifier expiration (< 5 minutes)
  static Future<bool> isTokenExpiringSoon() async {
    try {
      final token = await getToken();
      if (token == null) return true;

      final parts = token.split('.');
      if (parts.length != 3) return true;

      final decodedParts = base64Url.decode(
        parts[1] + '=' * (4 - parts[1].length % 4),
      );
      final decodedToken = jsonDecode(utf8.decode(decodedParts));

      final exp = decodedToken['exp'] as int?;
      if (exp == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final remainingTime = exp - now;

      return remainingTime < 300;
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      return true;
    }
  }
}

/// 🔐 SECURE HTTP CLIENT
class SecureHttpClient extends http.BaseClient {
  static const String apiBaseUrl = 'https://api.safeguardian.app';

  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(_getSecurityHeaders());

    final token = await SecureTokenStorage.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (!request.url.toString().startsWith('https://')) {
      throw SecurityException('HTTPS obligatoire');
    }

    try {
      final response = await _inner.send(request);
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException('Erreur réseau: $e');
    }
  }

  Map<String, String> _getSecurityHeaders() {
    return {
      'X-Requested-With': 'XMLHttpRequest',
      'X-Frame-Options': 'DENY',
      'X-Content-Type-Options': 'nosniff',
      'X-XSS-Protection': '1; mode=block',
    };
  }

  http.StreamedResponse _handleResponse(http.StreamedResponse response) {
    if (response.statusCode == 401) {
      throw AuthenticationException('Token invalide');
    }
    if (response.statusCode == 403) {
      throw AuthorizationException('Accès refusé');
    }
    if (response.statusCode >= 500) {
      throw ServerException('Erreur serveur');
    }
    return response;
  }
}

/// Exceptions
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => 'SecurityException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  @override
  String toString() => 'AuthenticationException: $message';
}

class AuthorizationException implements Exception {
  final String message;
  AuthorizationException(this.message);
  @override
  String toString() => 'AuthorizationException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => 'ServerException: $message';
}
