import 'package:flutter_test/flutter_test.dart';
import 'package:biodiversitaets_radar/features/stats/data/stats_model.dart';

void main() {
  test('fromJson wertet die Daten korrekt aus', () {
    
    final Map<String, dynamic> jsonMap = {
      "top_5_species": [
              {"name": "Rotmilan", "count": 12},
              {"name": "Eichhörnchen", "count": 5}
            ],
            "categories": [
              {"category": "Aves", "count": 12},
              {"category": "Mammalia", "count": 5}
            ],
    };

    final stats = StatsModel.fromJson(jsonMap);

    expect(stats.top5Species.length, 2);
    expect(stats.top5Species.first['name'], 'Rotmilan');
    expect(stats.categories.last['category'], 'Mammalia');

  });

  test('fromJson fängt Null-Werte ab', () {
    final Map<String, dynamic> emptyJson = {};

    final stats = StatsModel.fromJson(emptyJson);

    expect(stats.top5Species, isEmpty);
    expect(stats.categories, isEmpty);
  });
}
