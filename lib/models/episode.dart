class Episode {
  final int id;
  final String name;
  final String episode;
  final String airDate;
  final List<String> characters;

  Episode({
    required this.id,
    required this.name,
    required this.episode,
    required this.airDate,
    required this.characters,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      name: json['name'],
      episode: json['episode'],
      airDate: json['air_date'],
      characters: List<String>.from(json['characters']),
    );
  }
}