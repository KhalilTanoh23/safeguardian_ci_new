import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion Bluetooth pour les appareils SafeGuardian
class BluetoothService extends ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;
  bool _isConnecting = false;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;
  final List<StreamSubscription<List<int>>> _notificationSubscriptions = [];

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;

  final List<BluetoothDevice> _discoveredDevices = [];
  final Set<String> _discoveredDeviceIds = {}; // prevent duplicates by id

  List<BluetoothDevice> get discoveredDevices =>
      List.unmodifiable(_discoveredDevices);

  // UUIDs pour le service SafeGuardian
  static const String serviceUUID = "0000ff00-0000-1000-8000-00805f9b34fb";
  static const String characteristicUUID =
      "0000ff01-0000-1000-8000-00805f9b34fb";

  // Battery level
  int? _batteryLevel;
  int? get batteryLevel => _batteryLevel;

  // Callbacks for emergency handling
  Function(Map<String, dynamic>)? _onEmergencyAlert;
  Function()? _onBraceletRemoval;

  /// Set callback for emergency alerts
  void setEmergencyCallback(Function(Map<String, dynamic>) callback) {
    _onEmergencyAlert = callback;
  }

  /// Set callback for bracelet removal
  void setBraceletRemovalCallback(Function() callback) {
    _onBraceletRemoval = callback;
  }

  BluetoothService() {
    _initializeBluetooth();
    reconnectToSavedDevice();
  }

  /// Initialise le service Bluetooth
  Future<void> _initializeBluetooth() async {
    try {
      // Demander les permissions Bluetooth
      if (!await _requestBluetoothPermissions()) {
        debugPrint(
          '⚠️ Permissions Bluetooth refusées - Bluetooth indisponible',
        );
        // Ne pas échouer, continuer sans Bluetooth
        return;
      }

      final state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        debugPrint('⚠️ Bluetooth adapter not on: $state');
      } else {
        debugPrint('✅ Bluetooth adapter ready');
      }
    } catch (e, st) {
      debugPrint('❌ Erreur initialisation Bluetooth: $e\n$st');
      // Ne pas échouer, continuer sans Bluetooth
    }
  }

  /// Demande les permissions Bluetooth
  Future<bool> _requestBluetoothPermissions() async {
    try {
      // Pour Android 12+ (API 31+)
      if (await Permission.bluetoothScan.isGranted == false) {
        final scanStatus = await Permission.bluetoothScan.request();
        if (scanStatus != PermissionStatus.granted) {
          debugPrint('❌ Permission Bluetooth Scan refusée');
          return false;
        }
      }

      if (await Permission.bluetoothConnect.isGranted == false) {
        final connectStatus = await Permission.bluetoothConnect.request();
        if (connectStatus != PermissionStatus.granted) {
          debugPrint('❌ Permission Bluetooth Connect refusée');
          return false;
        }
      }

      // Pour les anciennes versions Android
      if (await Permission.bluetooth.isGranted == false) {
        final bluetoothStatus = await Permission.bluetooth.request();
        if (bluetoothStatus != PermissionStatus.granted) {
          debugPrint('❌ Permission Bluetooth refusée');
          return false;
        }
      }

      debugPrint('✅ Permissions Bluetooth accordées');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la demande des permissions Bluetooth: $e');
      return false;
    }
  }

  /// Scanne les appareils Bluetooth à proximité
  Future<void> scanForDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_isScanning) {
      debugPrint('⚠️ Scan déjà en cours');
      return;
    }

    _isScanning = true;
    _discoveredDevices.clear();
    _discoveredDeviceIds.clear();
    notifyListeners();

    debugPrint('🔍 Démarrage du scan Bluetooth...');

    try {
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          for (var result in results) {
            final dev = result.device;
            final adv = result.advertisementData;
            final name = (dev.platformName).trim();

            // Filtrer les appareils pertinents
            final hasTargetName =
                name.isNotEmpty &&
                (name.contains('SILENTOPS') ||
                    name.contains('SafeGuardian') ||
                    name.contains('SG-'));

            final hasTargetService = adv.serviceUuids
                .map((e) => e.toString().toLowerCase())
                .contains(serviceUUID.toLowerCase());

            if (!_discoveredDeviceIds.contains(dev.remoteId.str) &&
                (hasTargetName || hasTargetService)) {
              _discoveredDeviceIds.add(dev.remoteId.str);
              _discoveredDevices.add(dev);
              debugPrint(
                '📱 Appareil trouvé: ${dev.platformName} (${dev.remoteId.str})',
              );
              notifyListeners();
            }
          }
        },
        onError: (error) {
          debugPrint('❌ Erreur dans le stream de scan: $error');
        },
      );

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );

      // Attendre la fin du scan
      await Future.delayed(timeout);
    } catch (e, st) {
      debugPrint('❌ Erreur scan Bluetooth: $e\n$st');
    } finally {
      try {
        await FlutterBluePlus.stopScan();
        debugPrint(
          '🛑 Scan Bluetooth terminé. ${_discoveredDevices.length} appareils trouvés',
        );
      } catch (_) {}

      await _scanSubscription?.cancel();
      _scanSubscription = null;
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Se connecte à un appareil Bluetooth
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_connectedDevice != null &&
        _connectedDevice!.remoteId.str == device.remoteId.str) {
      debugPrint('✅ Déjà connecté à ${device.platformName}');
      return true;
    }

    _isConnecting = true;
    notifyListeners();

    debugPrint('🔗 Tentative de connexion à ${device.platformName}...');

    try {
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 15),
        license: '' as dynamic,
      );

      _connectedDevice = device;
      debugPrint('✅ Connecté à ${device.platformName}');

      // Écouter les changements d'état de connexion
      _deviceStateSubscription?.cancel();
      _deviceStateSubscription = device.connectionState.listen(
        (state) {
          debugPrint('📡 État de connexion: $state');
          if (state == BluetoothConnectionState.disconnected) {
            _handleDeviceDisconnected();
          }
        },
        onError: (error) {
          debugPrint('❌ Erreur dans le stream de connexion: $error');
        },
      );

      // Configurer les notifications
      await _setupNotifications(device);

      // Sauvegarder l'appareil pour reconnexion automatique
      await _saveConnectedDevice(device);

      _isConnecting = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('❌ Erreur connexion à ${device.platformName}: $e\n$st');
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  /// Configure les notifications pour recevoir les données du bracelet
  Future<void> _setupNotifications(BluetoothDevice device) async {
    try {
      debugPrint('🔧 Configuration des notifications...');

      final services = await device.discoverServices();

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() ==
            serviceUUID.toLowerCase()) {
          debugPrint('✅ Service SafeGuardian trouvé');

          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() ==
                characteristicUUID.toLowerCase()) {
              debugPrint('✅ Caractéristique trouvée');

              // Activer les notifications
              if (characteristic.properties.notify) {
                await characteristic.setNotifyValue(true);

                final sub = characteristic.lastValueStream.listen(
                  _handleBraceletData,
                  onError: (err) {
                    debugPrint('❌ Erreur notification stream: $err');
                  },
                );

                _notificationSubscriptions.add(sub);
                debugPrint('✅ Notifications activées');
              }
            }
          }
        }
      }
    } catch (e, st) {
      debugPrint('❌ Erreur setup notifications: $e\n$st');
    }
  }

  /// Gère les données reçues du bracelet
  void _handleBraceletData(List<int> data) {
    if (data.isEmpty) return;

    try {
      final decoded = utf8.decode(data);
      debugPrint('📥 Données reçues: $decoded');

      final jsonData = json.decode(decoded) as Map<String, dynamic>;
      final type = jsonData['type'] as String?;
      final payload = jsonData['data'] as Map<String, dynamic>?;

      switch (type) {
        case 'emergency':
          debugPrint('🚨 ALERTE D\'URGENCE: $payload');
          _handleEmergencyAlert(payload);
          break;

        case 'battery':
          final level = payload?['level'] as int? ?? 0;
          debugPrint('🔋 Niveau batterie: $level%');
          _handleBatteryUpdate(level);
          break;

        case 'removal':
          debugPrint('⚠️ BRACELET RETIRÉ!');
          _handleBraceletRemoval();
          break;

        case 'sleep_mode':
          final enabled = payload?['enabled'] as bool? ?? false;
          debugPrint('😴 Mode sommeil: ${enabled ? "activé" : "désactivé"}');
          break;

        case 'heartbeat':
          // Heartbeat silencieux pour maintenir la connexion
          break;

        default:
          debugPrint('❓ Type de message inconnu: $type');
      }
    } catch (e, st) {
      debugPrint('❌ Erreur décodage données bracelet: $e\n$st');
      // Afficher les données brutes en cas d'erreur
      debugPrint(
        'Données brutes: ${data.map((b) => b.toRadixString(16)).join(' ')}',
      );
    }
  }

  /// Gère les alertes d'urgence du bracelet
  void _handleEmergencyAlert(Map<String, dynamic>? payload) {
    debugPrint('🚨 ALERTE BRACELET: $payload');
    if (_onEmergencyAlert != null) {
      _onEmergencyAlert!(payload ?? {});
    }
    notifyListeners();
  }

  /// Gère les mises à jour de batterie
  void _handleBatteryUpdate(int level) {
    debugPrint('🔋 Mise à jour batterie: $level%');
    _batteryLevel = level;
    notifyListeners();
  }

  /// Gère le retrait du bracelet
  void _handleBraceletRemoval() {
    debugPrint('⚠️ BRACELET RETIRÉ - Déclenchement alerte');
    if (_onBraceletRemoval != null) {
      _onBraceletRemoval!();
    }
    notifyListeners();
  }

  /// Déconnecte l'appareil actuel
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        debugPrint('🔌 Déconnexion de ${_connectedDevice!.platformName}...');
        await _connectedDevice!.disconnect();
        debugPrint('✅ Déconnecté');
      } catch (e) {
        debugPrint('❌ Erreur lors de la déconnexion: $e');
      }

      _handleDeviceDisconnected();
      await _clearConnectedDevice();
      notifyListeners();
    }
  }

  /// Envoie une commande au bracelet
  Future<void> sendCommand(
    String command,
    Map<String, dynamic>? data, {
    bool withoutResponse = false,
  }) async {
    if (_connectedDevice == null) {
      debugPrint('⚠️ Aucun appareil connecté');
      return;
    }

    try {
      final payload = json.encode({
        'command': command,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final bytes = utf8.encode(payload);
      debugPrint('📤 Envoi commande: $command');

      final services = await _connectedDevice!.discoverServices();

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() ==
            serviceUUID.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() ==
                characteristicUUID.toLowerCase()) {
              await characteristic.write(
                bytes,
                withoutResponse: withoutResponse,
              );
              debugPrint('✅ Commande "$command" envoyée avec succès');
              return;
            }
          }
        }
      }

      debugPrint('⚠️ Caractéristique non trouvée pour la commande');
    } catch (e, st) {
      debugPrint('❌ Erreur envoi commande "$command": $e\n$st');
      rethrow;
    }
  }

  // ==================== Commandes utilitaires ====================

  /// Active le mode sommeil pour X heures
  Future<void> activateSleepMode(int hours) async {
    await sendCommand('activate_sleep_mode', {'hours': hours});
  }

  /// Désactive le mode sommeil
  Future<void> deactivateSleepMode() async {
    await sendCommand('deactivate_sleep_mode', null);
  }

  /// Demande le niveau de batterie
  Future<void> requestBatteryLevel() async {
    await sendCommand('get_battery', null);
  }

  /// Déclenche une alerte de test
  Future<void> triggerTestAlert() async {
    await sendCommand('test_alert', null);
  }

  /// Configure les paramètres du bracelet
  Future<void> configureBracelet({
    bool? vibrationEnabled,
    bool? soundEnabled,
    int? alertSensitivity,
  }) async {
    await sendCommand('configure', {
      if (vibrationEnabled != null) 'vibration': vibrationEnabled,
      if (soundEnabled != null) 'sound': soundEnabled,
      if (alertSensitivity != null) 'sensitivity': alertSensitivity,
    });
  }

  // ==================== Stockage local ====================

  /// Sauvegarde l'appareil connecté pour reconnexion automatique
  Future<void> _saveConnectedDevice(BluetoothDevice device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_device_id', device.remoteId.str);
      await prefs.setString('last_device_name', device.platformName);
      debugPrint('💾 Appareil sauvegardé: ${device.platformName}');
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde appareil: $e');
    }
  }

  /// Supprime l'appareil sauvegardé
  Future<void> _clearConnectedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_device_id');
      await prefs.remove('last_device_name');
      debugPrint('🗑️ Appareil sauvegardé supprimé');
    } catch (e) {
      debugPrint('❌ Erreur suppression appareil: $e');
    }
  }

  /// Tente de se reconnecter au dernier appareil connu
  Future<void> reconnectToSavedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString('last_device_id');
      final lastName = prefs.getString('last_device_name');

      if (lastId == null) {
        debugPrint('ℹ️ Aucun appareil sauvegardé');
        return;
      }

      debugPrint('🔄 Tentative de reconnexion à $lastName ($lastId)...');

      // Vérifier si l'appareil est déjà connecté
      final connectedDevices = FlutterBluePlus.connectedDevices;

      for (var device in connectedDevices) {
        if (device.remoteId.str == lastId) {
          debugPrint('✅ Appareil déjà connecté');
          await connectToDevice(device);
          return;
        }
      }

      // Scanner pour trouver l'appareil
      debugPrint('🔍 Scan rapide pour retrouver l\'appareil...');
      await scanForDevices(timeout: const Duration(seconds: 5));

      final found = _discoveredDevices
          .where((d) => d.remoteId.str == lastId)
          .firstOrNull;

      if (found != null) {
        debugPrint('✅ Appareil retrouvé, connexion...');
        await connectToDevice(found);
      } else {
        debugPrint('⚠️ Appareil $lastName non trouvé lors du scan');
      }
    } catch (e, st) {
      debugPrint('❌ Impossible de reconnecter: $e\n$st');
    }
  }

  /// Gère la déconnexion d'un appareil
  void _handleDeviceDisconnected() {
    debugPrint('📡 Appareil déconnecté');

    _connectedDevice = null;

    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;

    for (var sub in _notificationSubscriptions) {
      try {
        sub.cancel();
      } catch (e) {
        debugPrint('⚠️ Erreur annulation subscription: $e');
      }
    }
    _notificationSubscriptions.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('🧹 Nettoyage BluetoothService');

    _scanSubscription?.cancel();
    _deviceStateSubscription?.cancel();

    for (var sub in _notificationSubscriptions) {
      sub.cancel();
    }
    _notificationSubscriptions.clear();

    super.dispose();
  }
}
