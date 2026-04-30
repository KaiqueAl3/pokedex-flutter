import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const int _defaultLimit = 20;

  static final PokeApiService _instance = PokeApiService._internal();
  factory PokeApiService() => _instance;
  PokeApiService._internal();

  final http.Client _client = http.Client();

  /// Busca lista paginada de Pokémon
  Future<Map<String, dynamic>> fetchPokemonList({
    int offset = 0,
    int limit = _defaultLimit,
  }) async {
    final uri = Uri.parse('$_baseUrl/pokemon?offset=$offset&limit=$limit');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (data['results'] as List)
          .map((e) => PokemonListItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return {
        'count': data['count'] as int,
        'items': items,
      };
    }
    throw Exception('Erro ao buscar lista: ${response.statusCode}');
  }

  /// Busca detalhes de um Pokémon pelo ID ou nome
  Future<Pokemon> fetchPokemonDetail(dynamic idOrName) async {
    final uri = Uri.parse('$_baseUrl/pokemon/$idOrName');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      var pokemon = Pokemon.fromJson(data);

      // Busca a descrição da espécie
      try {
        final desc = await fetchPokemonDescription(pokemon.id);
        pokemon = pokemon.copyWith(description: desc);
      } catch (_) {}

      return pokemon;
    }
    throw Exception('Pokémon não encontrado: $idOrName');
  }

  /// Busca a descrição (flavor text) em português ou inglês
  Future<String> fetchPokemonDescription(int id) async {
    final uri = Uri.parse('$_baseUrl/pokemon-species/$id');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final entries = data['flavor_text_entries'] as List;

      // Tenta português primeiro, depois inglês
      final ptEntry = entries.firstWhere(
        (e) => e['language']['name'] == 'pt',
        orElse: () => null,
      );

      if (ptEntry != null) {
        return (ptEntry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
      }

      final enEntry = entries.firstWhere(
        (e) => e['language']['name'] == 'en',
        orElse: () => null,
      );

      if (enEntry != null) {
        return (enEntry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
      }
    }
    return 'Sem descrição disponível.';
  }

  /// Busca Pokémon por nome (search)
  Future<Pokemon?> searchPokemon(String name) async {
    try {
      return await fetchPokemonDetail(name.toLowerCase().trim());
    } catch (_) {
      return null;
    }
  }

  /// Busca lista de tipos disponíveis
  Future<List<String>> fetchTypes() async {
    final uri = Uri.parse('$_baseUrl/type');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['results'] as List)
          .map((e) => e['name'] as String)
          .where((t) => t != 'unknown' && t != 'shadow')
          .toList();
    }
    return [];
  }

  /// Busca Pokémon de um tipo específico
  Future<List<PokemonListItem>> fetchPokemonByType(String type) async {
    final uri = Uri.parse('$_baseUrl/type/$type');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final pokemon = (data['pokemon'] as List)
          .map((e) => PokemonListItem.fromJson(
                e['pokemon'] as Map<String, dynamic>,
              ))
          .toList();
      return pokemon.take(20).toList();
    }
    return [];
  }

  void dispose() {
    _client.close();
  }
}
