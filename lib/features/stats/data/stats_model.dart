class StatsModel {
  final List<dynamic> top5Species;
  final List<dynamic> categories;

  StatsModel({
      required this.top5Species,
      required this.categories,
    });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
      return StatsModel(
        // Wenn der Key nicht existiert (??), wird eine leere Liste übergeben
        top5Species: json['top_5_species'] ?? [],
        categories: json['categories'] ?? [],
      );
    }
}