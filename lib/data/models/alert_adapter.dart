import 'package:hive/hive.dart';
import 'dart:convert';
import 'alert.dart';

/// Hive TypeAdapter for EmergencyAlert
class EmergencyAlertAdapter extends TypeAdapter<EmergencyAlert> {
  @override
  final int typeId = 1;

  @override
  EmergencyAlert read(BinaryReader reader) {
    final jsonStr = reader.readString();
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return EmergencyAlert.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, EmergencyAlert obj) {
    writer.writeString(json.encode(obj.toJson()));
  }
}
