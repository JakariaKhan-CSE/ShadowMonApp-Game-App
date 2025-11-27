// --- DATA MODEL ---
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      // Official artwork is higher res, fallback to front_default if needed
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ??
          json['sprites']['front_default'],
      types: (json['types'] as List)
          .map((t) => t['type']['name'].toString())
          .toList(),
    );
  }
}