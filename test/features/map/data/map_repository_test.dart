import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:biodiversitaets_radar/features/map/data/map_observation_model.dart';
import 'package:biodiversitaets_radar/features/map/data/map_repository.dart';


class MockHttpClient extends Mock implements http.Client {

  void main() {
    late MockHttpClient mockClient;
    late MapRepository repository;

    setUp(() {
      mockClient = MockHttpClient();
      repository = MapRepository(client: mockClient);
    });

    final tUrl = Uri.parse('https://github.io/KonstantinKoenigshofen/biodiversitaets_radar/map_data.json');

    test('sollte eine Liste von MapObservation zurückgeben (HTTP 200)', () async {
      final jsonString = '[{"latitude": 52.15, "longitude": 9.95, "photo_url": "url", "species_guess": "Rotmilan"}]';
    
      when(() => mockClient.get(tUrl))
          .thenAnswer((_) async => http.Response(jsonString, 200));

      final result = await repository.fetchObservations();

      // Überprüfung
      expect(result, isA<List<MapObservation>>());
      expect(result.length, 1);
      expect(result.first.speciesGuess, 'Rotmilan');
    });
  }

}