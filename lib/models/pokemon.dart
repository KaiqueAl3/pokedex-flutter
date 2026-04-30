class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final String shinyImageUrl;
  final List<String> types;
  final int height;
  final int weight;
  final List<PokemonStat> stats;
  final List<PokemonAbility> abilities;
  final String description;
  final int baseExperience;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.shinyImageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.stats,
    required this.abilities,
    required this.description,
    required this.baseExperience,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List)
        .map((t) => t['type']['name'] as String)
        .toList();

    final stats = (json['stats'] as List)
        .map((s) => PokemonStat(
              name: s['stat']['name'] as String,
              value: s['base_stat'] as int,
            ))
        .toList();

    final abilities = (json['abilities'] as List)
        .map((a) => PokemonAbility(
              name: a['ability']['name'] as String,
              isHidden: a['is_hidden'] as bool,
            ))
        .toList();

    final id = json['id'] as int;

    return Pokemon(
      id: id,
      name: json['name'] as String,
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ??
          json['sprites']['front_default'] ??
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
      shinyImageUrl: json['sprites']['other']['official-artwork']['front_shiny'] ??
          json['sprites']['front_shiny'] ??
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/$id.png',
      types: types,
      height: json['height'] as int,
      weight: json['weight'] as int,
      stats: stats,
      abilities: abilities,
      description: '',
      baseExperience: json['base_experience'] ?? 0,
    );
  }

  Pokemon copyWith({String? description}) {
    return Pokemon(
      id: id,
      name: name,
      imageUrl: imageUrl,
      shinyImageUrl: shinyImageUrl,
      types: types,
      height: height,
      weight: weight,
      stats: stats,
      abilities: abilities,
      description: description ?? this.description,
      baseExperience: baseExperience,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'shinyImageUrl': shinyImageUrl,
      'types': types,
      'height': height,
      'weight': weight,
      'baseExperience': baseExperience,
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  factory Pokemon.fromFirestore(Map<String, dynamic> data) {
    return Pokemon(
      id: data['id'] as int,
      name: data['name'] as String,
      imageUrl: data['imageUrl'] as String,
      shinyImageUrl: data['shinyImageUrl'] as String? ?? '',
      types: List<String>.from(data['types']),
      height: data['height'] as int,
      weight: data['weight'] as int,
      stats: [],
      abilities: [],
      description: '',
      baseExperience: data['baseExperience'] as int? ?? 0,
    );
  }

  String get formattedId => '#${id.toString().padLeft(4, '0')}';

  String get formattedHeight => '${(height / 10).toStringAsFixed(1)} m';

  String get formattedWeight => '${(weight / 10).toStringAsFixed(1)} kg';

  String get capitalizedName =>
      name[0].toUpperCase() + name.substring(1).replaceAll('-', ' ');
}

class PokemonStat {
  final String name;
  final int value;

  const PokemonStat({required this.name, required this.value});

  String get displayName {
    const names = {
      'hp': 'HP',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'SP.ATK',
      'special-defense': 'SP.DEF',
      'speed': 'SPD',
    };
    return names[name] ?? name.toUpperCase();
  }
}

class PokemonAbility {
  final String name;
  final bool isHidden;

  const PokemonAbility({required this.name, required this.isHidden});

  String get capitalizedName =>
      name[0].toUpperCase() + name.substring(1).replaceAll('-', ' ');
}

class PokemonListItem {
  final String name;
  final String url;

  const PokemonListItem({required this.name, required this.url});

  int get id {
    final segments = url.split('/');
    return int.parse(segments[segments.length - 2]);
  }

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
