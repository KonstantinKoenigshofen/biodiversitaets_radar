class MapObservation {
  final double latitude;
  final double longitude;
  final String photoUrl;
  final String speciesGuess;

  MapObservation({
      required this.latitude,
      required this.longitude,
      required this.photoUrl,
      required this.speciesGuess,
    });

  factory MapObservation.fromJson(Map<String, dynamic> json) {
    return MapObservation(
      // num fängt sowohl int als auch double ab, der Wert soll aber double sein (toDouble())
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      // ?? bedeutet: Nimm den linken Wert, falls der Null ist, nimm den rechten Wert.
      photoUrl: json['photo_url'] as String? ?? '',
      speciesGuess: json['species_guess'] as String? ?? 'Unbekannt',
    );
  }

}