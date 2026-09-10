import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:biodiversitaets_radar/features/map/data/map_observation_model.dart';
import 'package:biodiversitaets_radar/features/map/ui/map_view.dart';

void main() {

  testWidgets('Zeigt eine Karte mit einer Markierung an', (WidgetTester tester) async {

    final dummyObservation = MapObservation(
      latitude: 52.15,
      longitude: 9.95,
      photoUrl: '',
      speciesGuess: 'Rotmilan',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapView(observations: [dummyObservation]),
      ),
    );

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);
  

  });



}