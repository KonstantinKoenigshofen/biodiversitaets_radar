import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'features/map/data/map_observation_model.dart';
import 'features/map/data/map_repository.dart';
import 'features/map/ui/map_view.dart';
import 'features/stats/data/stats_model.dart';
import 'features/stats/ui/dashboard_view.dart';


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
            body: Column(
              //mainAxisAlignment: MainAxisAlignment.center,     
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text
                Center(
                  child: SizedBox(
                    width: 1000,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        // clipBehavior sorgt dafür, dass die Karte sauber innerhalb der runden Ecken abgeschnitten wird
                        clipBehavior: Clip.antiAlias, 
                        child: Text("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."),
                      ),
                    ),
                  ),
                ),
                // Karte
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    width: 1000,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        // clipBehavior sorgt dafür, dass die Karte sauber innerhalb der runden Ecken abgeschnitten wird
                        clipBehavior: Clip.antiAlias, 
                        child: MapView(observations: observations),
                      ),
                    ),
                  ),
                ),
                
                // Dashboard
                SizedBox(
                  width: 1000,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      // clipBehavior sorgt dafür, dass die Karte sauber innerhalb der runden Ecken abgeschnitten wird
                      clipBehavior: Clip.antiAlias, 
                      child: DashboardView(stats: stats),
                    ),
                  )
                )
              ],
            ),
          );
        }
        
        return const Scaffold(body: Center(child: Text('Keine Daten gefunden.')));
      },
    );
  }
}