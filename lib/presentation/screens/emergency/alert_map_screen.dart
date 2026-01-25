import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AlertMapScreen extends StatefulWidget {
  final LatLng alertLocation;
  final String alertId;

  const AlertMapScreen({
    super.key,
    required this.alertLocation,
    required this.alertId,
  });

  @override
  State<AlertMapScreen> createState() => _AlertMapScreenState();
}

class _AlertMapScreenState extends State<AlertMapScreen> {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.alertLocation,
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: MarkerId(widget.alertId),
          position: widget.alertLocation,
          infoWindow: const InfoWindow(
            title: 'Alerte d\'urgence',
            snippet: 'Localisation de l\'alerte',
          ),
        ),
      },
      onMapCreated: (_) {
        // Map controller not needed for this screen
      },
    );
  }
}
