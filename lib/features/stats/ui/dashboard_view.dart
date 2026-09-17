import 'package:flutter/material.dart';
import '../data/stats_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardView extends StatelessWidget {
  final StatsModel stats;

  const DashboardView({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Karte mit Top 5 Arten
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header mit Icon
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        Text('Top 5 Arten', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const Divider(height: 24),
         
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.top5Species.length,
                      itemBuilder: (context, index) {
                        final item = stats.top5Species[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          title: Text(item['name']),
                          trailing: Text(
                            '${item['count']}x', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Karte mit Kategorien

          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header mit Icon
                    Row(
                      children: [
                        Icon(Icons.category, color: Theme.of(context).colorScheme.primary, size: 28),
                        const SizedBox(width: 8),
                        Text('Kategorien', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const Divider(height: 24),
                    
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.categories.length,
                      itemBuilder: (context, index) {
                        final item = stats.categories[index];
                        final categoryName = item['category'] ?? "Unbekannt";
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          // Ein passendes Icon zur Kategorie finden
                          leading: FaIcon(_getIconForCategory(categoryName), color: Colors.grey[700]),
                          title: Text(categoryName),
                          trailing: Text(
                            '${item['count']}', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

// Gibt nun FontAwesome-Icons statt Material-Icons zurück
  FaIconData _getIconForCategory(String category) {
    switch (category) {
      case 'Aves': return FontAwesomeIcons.crow;       
      case 'Mammalia': return FontAwesomeIcons.otter;  
      case 'Amphibia': return FontAwesomeIcons.frog;   
      case 'Reptilia': return FontAwesomeIcons.dragon; 
      default: return FontAwesomeIcons.circleQuestion; // Unbekannt
    }
  }
}