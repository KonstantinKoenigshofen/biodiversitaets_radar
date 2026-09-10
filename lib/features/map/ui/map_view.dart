import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/map_observation_model.dart';


class MapView extends StatelessWidget {

  final List<MapObservation> observations;

  const MapView({super.key, required this.observations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biodiversitäts-Radar')),
      body: FlutterMap(
        // Start-Einstellungen der Karte (Zentriert auf Hildesheim)
        options: const MapOptions(
          initialCenter: LatLng(52.15, 9.95), 
          initialZoom: 11.0,
        ),
        children: [
          // Karte
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.biodiversitaets_radar',
          ),
          // Markierungen
          MarkerLayer(
            markers: observations.map((obs) {
              return Marker(
                point: LatLng(obs.latitude, obs.longitude),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on, 
                  color: Colors.red, 
                  size: 40,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}