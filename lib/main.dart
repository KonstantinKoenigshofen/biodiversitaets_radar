import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'features/map/data/map_observation_model.dart';
import 'features/map/data/map_repository.dart';
import 'features/map/ui/map_view.dart';
import 'features/stats/data/stats_model.dart';
import 'features/stats/ui/dashboard_view.dart';
import 'package:url_launcher/url_launcher.dart';


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
    // FutureBuilder wartet auf die HTTP-Antworten mit wait
    return FutureBuilder(
      future: Future.wait([
        repository.fetchObservations(),
        repository.fetchStats(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        
      if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Fehler: ${snapshot.error}')));
        }
        
        if (snapshot.hasData) {
          // Die Reihenfolge entspricht dem Future.wait Array von oben
          final observations = snapshot.data![0] as List<MapObservation>;
          final stats = snapshot.data![1] as StatsModel;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Biodiversitäts-Radar'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Textbereich
                  Center(
                    child: SizedBox(
                      width: 1000,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Diese Seite zeigt Beobachtungen von Säugetieren, Vögeln, Amphibien und Reptilien in ganz Deutschland an. '
                                'Dabei stammen die Daten aus der API von INaturalist und werden wöchentlich aktualisiert. Durch Klicken auf '
                                'eine Markierung kann der Name der jeweiligen beobachteten Tierart sowie ein Bild angezeigt werden. '
                                'Für weitere Informationen und den Programmcode:',
                                style: TextStyle(fontSize: 16, height: 1.5),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () async {
                                  final Uri url = Uri.parse('https://github.com/KonstantinKoenigshofen/biodiversitaets_radar');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Text(
                                  'https://github.com/KonstantinKoenigshofen/biodiversitaets_radar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue[700],
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Karte 
                  Center(
                    child: SizedBox(
                      height: 600, 
                      width: 1000,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          clipBehavior: Clip.antiAlias, 
                          child: MapView(observations: observations),
                        ),
                      ),
                    ),
                  ),
                  
                  // Dashboard 
                  Center(
                    child: SizedBox(
                      width: 1000,
                      child: DashboardView(stats: stats),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: Text('Keine Daten gefunden.')));
      },
    );
  }
}