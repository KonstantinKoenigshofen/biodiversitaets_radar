import 'package:flutter_test/flutter_test.dart';
import 'package:biodiversitaets_radar/features/map/data/map_observation_model.dart';

void main() {
  test('fromJson wertet die Koordinaten und Namen korrekt aus', () {
    
    final Map<String, dynamic> jsonMap = {
      "latitude": 52.15,
      "longitude": 9.95,
      "photo_url": "https://example.com/bird.jpg",
      "species_guess": "Rotmilan"
    };

    final observation = MapObservation.fromJson(jsonMap);

    expect(observation.latitude, 52.15);
    expect(observation.longitude, 9.95);
    expect(observation.photoUrl, "https://example.com/bird.jpg");
    expect(observation.speciesGuess, 'Rotmilan');

  });

  test('fromJson wandelt ganze Zahlen in double um', () {
    final Map<String, dynamic> jsonMap = {
      "latitude": 52, // int statt double!
      "longitude": 9, // int statt double!
      "photo_url": "https://example.com/bird.jpg",
      "species_guess": "Rotmilan"
    };

    final observation = MapObservation.fromJson(jsonMap);
    
    expect(observation.latitude, 52.0);
  });

  test('fromJson geht sicher mit Null-Werten um', () {
    final Map<String, dynamic> jsonMap = {
      "latitude": 52.15,
      "longitude": 9.95,
      "photo_url": null, 
      "species_guess": null 
    };

    final observation = MapObservation.fromJson(jsonMap);
    
    expect(observation.photoUrl, ''); 
    expect(observation.speciesGuess, 'Unbekannt');
  });
}
