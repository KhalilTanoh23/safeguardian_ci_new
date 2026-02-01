import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service de gestion de la localisation GPS
class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  StreamSubscription<Position>? _positionStream;

  bool _isTracking = false;
  bool _permissionGranted = false;
  bool _isLoading = false;

  LocationAccuracy _accuracy = LocationAccuracy.high;
  String? _lastError;

  // Getters
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isTracking => _isTracking;
  bool get permissionGranted => _permissionGranted;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  LatLng? get currentLatLng => _currentPosition != null
      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
      : null;

  LocationService() {
    _initialize();
  }

  /// Initialise le service de localisation
  Future<void> _initialize() async {
    debugPrint('📍 Initialisation LocationService...');
    await _checkPermissions();
  }

  /// Vérifie et demande les permissions de localisation
  Future<bool> _checkPermissions() async {
    try {
      // Vérifier si le service de localisation est activé
      if (!await Geolocator.isLocationServiceEnabled()) {
        _lastError = 'Le service de localisation est désactivé';
        _permissionGranted = false;
        debugPrint('⚠️ Service de localisation désactivé');
        notifyListeners();
        return false;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        debugPrint('🔐 Demande de permission de localisation...');
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _lastError = 'Permission de localisation refusée';
          _permissionGranted = false;
          debugPrint('❌ Permission refusée');
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _lastError = 'Permission de localisation refusée définitivement';
        _permissionGranted = false;
        debugPrint('❌ Permission refusée définitivement');
        notifyListeners();
        return false;
      }

      _permissionGranted = true;
      _lastError = null;
      debugPrint('✅ Permission de localisation accordée');
      notifyListeners();

      // Obtenir la position initiale
      await getCurrentLocation();
      return true;
    } catch (e, stackTrace) {
      _lastError = 'Erreur lors de la vérification des permissions: $e';
      debugPrint('❌ Erreur permissions: $e\n$stackTrace');
      _permissionGranted = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtient la position actuelle
  Future<Position?> getCurrentLocation() async {
    if (!_permissionGranted) {
      final granted = await _checkPermissions();
      if (!granted) return null;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      debugPrint('📍 Récupération de la position...');

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: _accuracy,
          distanceFilter: 10,
          timeLimit: const Duration(seconds: 30),
        ),
      );

      debugPrint(
        '✅ Position obtenue: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
      );

      // Obtenir l'adresse
      await _updateAddress();

      _isLoading = false;
      notifyListeners();
      return _currentPosition;
    } catch (e, stackTrace) {
      _lastError = 'Erreur lors de la récupération de la position: $e';
      debugPrint('❌ Erreur récupération position: $e\n$stackTrace');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Met à jour l'adresse actuelle
  Future<void> _updateAddress() async {
    if (_currentPosition == null) return;

    try {
      _currentAddress = await getAddressFromPosition(_currentPosition!);
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Erreur mise à jour adresse: $e');
    }
  }

  /// Démarre le suivi de position en temps réel
  Future<void> startTracking() async {
    if (_isTracking) {
      debugPrint('⚠️ Tracking déjà actif');
      return;
    }

    if (!_permissionGranted) {
      final granted = await _checkPermissions();
      if (!granted) return;
    }

    try {
      debugPrint('🎯 Démarrage du tracking GPS...');

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: LocationSettings(
              accuracy: _accuracy,
              distanceFilter: 10,
              timeLimit: const Duration(seconds: 30),
            ),
          ).listen(
            (position) {
              _currentPosition = position;
              debugPrint(
                '📍 Position mise à jour: ${position.latitude}, ${position.longitude}',
              );
              _updateAddress();
              notifyListeners();
            },
            onError: (error) {
              _lastError = 'Erreur de tracking: $error';
              debugPrint('❌ Erreur tracking: $error');
              notifyListeners();
            },
          );

      _isTracking = true;
      _lastError = null;
      debugPrint('✅ Tracking GPS actif');
      notifyListeners();
    } catch (e, stackTrace) {
      _lastError = 'Erreur lors du démarrage du tracking: $e';
      debugPrint('❌ Erreur démarrage tracking: $e\n$stackTrace');
      notifyListeners();
    }
  }

  /// Arrête le suivi de position
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    try {
      await _positionStream?.cancel();
      _positionStream = null;
      _isTracking = false;
      debugPrint('🛑 Tracking GPS arrêté');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur arrêt tracking: $e');
    }
  }

  /// Calcule la distance entre deux points (en mètres)
  Future<double> calculateDistance(LatLng start, LatLng end) async {
    try {
      final distance = Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
      return distance;
    } catch (e) {
      debugPrint('❌ Erreur calcul distance: $e');
      return 0.0;
    }
  }

  /// Calcule la distance depuis la position actuelle (en mètres)
  Future<double?> calculateDistanceFromCurrent(LatLng destination) async {
    if (_currentPosition == null) {
      await getCurrentLocation();
      if (_currentPosition == null) return null;
    }

    return calculateDistance(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      destination,
    );
  }

  /// Formate une distance en texte lisible
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Obtient l'adresse à partir de coordonnées
  Future<String> getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return _formatPlacemark(placemark);
      }

      return '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
    } catch (e) {
      debugPrint('❌ Erreur récupération adresse: $e');
      return '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
    }
  }

  /// Obtient l'adresse à partir d'une position
  Future<String> getAddressFromPosition(Position position) async {
    return getAddressFromLatLng(LatLng(position.latitude, position.longitude));
  }

  /// Formate un Placemark en adresse lisible
  String _formatPlacemark(Placemark placemark) {
    final parts = <String>[];

    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      parts.add(placemark.country!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Adresse inconnue';
  }

  /// Obtient les coordonnées à partir d'une adresse
  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Erreur récupération coordonnées: $e');
      return null;
    }
  }

  /// Ouvre les paramètres de localisation du système
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
      debugPrint('📱 Ouverture des paramètres de localisation');
    } catch (e) {
      debugPrint('❌ Erreur ouverture paramètres: $e');
    }
  }

  /// Ouvre les paramètres de l'application
  Future<void> openAppSettings() async {
    try {
      await Permission.location.request();
      debugPrint('📱 Ouverture des paramètres de l\'app');
    } catch (e) {
      debugPrint('❌ Erreur ouverture paramètres app: $e');
    }
  }

  /// Demande les permissions de localisation
  Future<bool> requestPermissions() async {
    return await _checkPermissions();
  }

  /// Vérifie si les permissions sont accordées
  Future<bool> checkPermissions() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return false;
      }

      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  /// Définit la précision de localisation
  void setAccuracy(LocationAccuracy accuracy) {
    _accuracy = accuracy;
    debugPrint('🎯 Précision définie à: $accuracy');
    notifyListeners();

    // Redémarrer le tracking si actif
    if (_isTracking) {
      stopTracking().then((_) => startTracking());
    }
  }

  /// Vérifie si une position est dans un rayon donné (en mètres)
  bool isWithinRadius(LatLng position, LatLng center, double radiusMeters) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      center.latitude,
      center.longitude,
    );
    return distance <= radiusMeters;
  }

  /// Crée un cercle pour Google Maps
  Circle createCircle({
    required String circleId,
    required LatLng center,
    required double radiusMeters,
    Color fillColor = Colors.blue,
    Color strokeColor = Colors.blue,
  }) {
    return Circle(
      circleId: CircleId(circleId),
      center: center,
      radius: radiusMeters,
      fillColor: fillColor.withValues(alpha: 0.2),
      strokeColor: strokeColor,
      strokeWidth: 2,
    );
  }

  /// Méthode helper pour obtenir LatLng depuis Position
  LatLng? getCurrentLatLng() => currentLatLng;

  @override
  void dispose() {
    debugPrint('🧹 Nettoyage LocationService');
    _positionStream?.cancel();
    super.dispose();
  }
}

