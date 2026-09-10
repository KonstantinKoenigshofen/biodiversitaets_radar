import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'features/map/data/map_observation_model.dart';
import 'features/map/data/map_repository.dart';
import 'features/map/ui/map_view.dart';


void main() {
  final httpClient = http.Client();
  final repository = MapRepository(client: httpClient);
  runApp(BiodiversitaetsRadarApp(repository: repository));
}


class BiodiversitaetsRadarApp extends StatelessWidget {
  final MapRepository repository;

  const BiodiversitaetsRadarApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biodiversitäts-Radar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MapScreen(repository: repository),
    );
  }
}


class MapScreen extends StatelessWidget {
  final MapRepository repository;

  const MapScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    // FutureBuilder wartet auf die HTTP-Antwort
    return FutureBuilder<List<MapObservation>>(
      future: repository.fetchObservations(),
      builder: (context, snapshot) {
        
        // Lade-Kreis anzeigen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Fehler anzeigen
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Fehler beim Laden der Daten:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        
        // Karte mit Daten anzeigen
        if (snapshot.hasData) {
          final observations = snapshot.data!;
          return MapView(observations: observations);
        }
        
        // Fallback
        return const Scaffold(
          body: Center(child: Text('Keine Beobachtungen gefunden.')),
        );
      },
    );
  }
}