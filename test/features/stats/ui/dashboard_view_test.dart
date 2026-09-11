import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biodiversitaets_radar/features/stats/data/stats_model.dart';
import 'package:biodiversitaets_radar/features/stats/ui/dashboard_view.dart';


void main() {

  testWidgets('Dashboard rendert Top 5 Arten und Kategorien', (WidgetTester tester) async {

    final dummyStats = StatsModel(
      top5Species: [{'name': 'Rotmilan', 'count': 12}],
      categories: [{'category': 'Aves', 'count': 12}],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DashboardView(stats: dummyStats),)
      )
    );

    expect(find.text('Top 5 Arten'), findsOneWidget);
    expect(find.text('Rotmilan (12x)'), findsOneWidget);
    
    expect(find.text('Kategorien'), findsOneWidget);
    expect(find.text('Aves: 12'), findsOneWidget);

  });

}