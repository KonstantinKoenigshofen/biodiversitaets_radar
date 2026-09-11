import 'package:flutter/material.dart';
import 'package:biodiversitaets_radar/features/stats/data/stats_model.dart';

class DashboardView extends StatelessWidget {
  final StatsModel stats;

  const DashboardView({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linke Spalte: Top 5 Arten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top 5 Arten', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                ...stats.top5Species.map((item) => Text('${item['name']} (${item['count']}x)')),
              ],
            ),
          ),
          
          // Rechte Spalte: Kategorien
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kategorien', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                ...stats.categories.map((item) => Text('${item['category'] ?? "Unbekannt"}: ${item['count']}')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}