import 'dart:convert';
import 'package:http/http.dart' as http;
import 'map_observation_model.dart';

class MapRepository {

  final http.Client client;

  MapRepository({required this.client});

  Future<List<MapObservation>> fetchObservations() async {
    final url = Uri.parse('https://konstantinkoenigshofen.github.io/biodiversitaets_radar/map_data.json');

    final response = await client.get(url);

    if (response.statusCode == 200) {
        
        final List<dynamic> jsonList = json.decode(response.body);
        
        // Elemente auf Model mappen
        return jsonList.map((json) => MapObservation.fromJson(json)).toList();
    } else {
        throw Exception('Fehler beim Laden der map_data.json');
    }
  }
}