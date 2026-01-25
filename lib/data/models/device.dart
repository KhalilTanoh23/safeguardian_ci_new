// lib/data/models/device.dart

class BraceletDevice {
  final String id;
  final String userId;
  final String deviceName;
  final String macAddress;
  final DeviceStatus status;
  final int batteryLevel;
  final DateTime lastConnected;
  final DeviceSettings settings;
  final List<DeviceEvent> events;

  BraceletDevice({
    required this.id,
    required this.userId,
    required this.deviceName,
    required this.macAddress,
    this.status = DeviceStatus.disconnected,
    this.batteryLevel = 100,
    required this.lastConnected,
    required this.settings,
    this.events = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deviceName': deviceName,
      'macAddress': macAddress,
      'status': status.name,
      'batteryLevel': batteryLevel,
      'lastConnected': lastConnected.toIso8601String(),
      'settings': settings.toJson(),
      'events': events.map((event) => event.toJson()).toList(),
    };
  }

  factory BraceletDevice.fromJson(Map<String, dynamic> json) {
    return BraceletDevice(
      id: json['id'],
      userId: json['userId'],
      deviceName: json['deviceName'],
      macAddress: json['macAddress'],
      status: DeviceStatus.values.firstWhere((e) => e.name == json['status']),
      batteryLevel: json['batteryLevel'],
      lastConnected: DateTime.parse(json['lastConnected']),
      settings: DeviceSettings.fromJson(json['settings']),
      events: (json['events'] as List)
          .map((event) => DeviceEvent.fromJson(event))
          .toList(),
    );
  }
}

class DeviceSettings {
  final bool vibrationEnabled;
  final bool soundEnabled;
  final int vibrationPattern;
  final int emergencyButtonHoldTime;
  final bool removalDetection;
  final bool sleepModeEnabled;
  final int sleepModeStartHour;
  final int sleepModeEndHour;

  DeviceSettings({
    this.vibrationEnabled = true,
    this.soundEnabled = true,
    this.vibrationPattern = 1,
    this.emergencyButtonHoldTime = 3,
    this.removalDetection = true,
    this.sleepModeEnabled = false,
    this.sleepModeStartHour = 22,
    this.sleepModeEndHour = 7,
  });

  Map<String, dynamic> toJson() {
    return {
      'vibrationEnabled': vibrationEnabled,
      'soundEnabled': soundEnabled,
      'vibrationPattern': vibrationPattern,
      'emergencyButtonHoldTime': emergencyButtonHoldTime,
      'removalDetection': removalDetection,
      'sleepModeEnabled': sleepModeEnabled,
      'sleepModeStartHour': sleepModeStartHour,
      'sleepModeEndHour': sleepModeEndHour,
    };
  }

  factory DeviceSettings.fromJson(Map<String, dynamic> json) {
    return DeviceSettings(
      vibrationEnabled: json['vibrationEnabled'],
      soundEnabled: json['soundEnabled'],
      vibrationPattern: json['vibrationPattern'],
      emergencyButtonHoldTime: json['emergencyButtonHoldTime'],
      removalDetection: json['removalDetection'],
      sleepModeEnabled: json['sleepModeEnabled'],
      sleepModeStartHour: json['sleepModeStartHour'],
      sleepModeEndHour: json['sleepModeEndHour'],
    );
  }
}

class DeviceEvent {
  final String id;
  final DeviceEventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  DeviceEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }

  factory DeviceEvent.fromJson(Map<String, dynamic> json) {
    return DeviceEvent(
      id: json['id'],
      type: DeviceEventType.values.firstWhere((e) => e.name == json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      data: json['data'],
    );
  }
}

enum DeviceStatus { connected, disconnected, connecting, error, lowBattery }

enum DeviceEventType {
  emergencyPressed,
  braceletRemoved,
  braceletReattached,
  batteryLow,
  batteryCritical,
  sleepModeActivated,
  sleepModeDeactivated,
  connectionLost,
  connectionRestored,
}
