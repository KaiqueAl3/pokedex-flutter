import 'package:flutter/foundation.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';
import '../services/firebase_service.dart';

enum LoadingState { idle, loading, loaded, error }

class PokemonProvider extends ChangeNotifier {
  final PokeApiService _api = PokeApiService();
  final FirebaseService _firebase = FirebaseService();

  // ─── Estado da lista principal ───────────────────────────
  List<PokemonListItem> _pokemonList = [];
  List<PokemonListItem> get pokemonList => _pokemonList;

  LoadingState _listState = LoadingState.idle;
  LoadingState get listState => _listState;

  int _offset = 0;
  int _totalCount = 0;
  bool get hasMore => _pokemonList.length < _totalCount;

  // ─── Estado do detalhe ──────────────────────────────────
  Pokemon? _selectedPokemon;
  Pokemon? get selectedPokemon => _selectedPokemon;

  LoadingState _detailState = LoadingState.idle;
  LoadingState get detailState => _detailState;

  // ─── Estado dos favoritos ────────────────────────────────
  Set<int> _favoriteIds = {};
  Set<int> get favoriteIds => _favoriteIds;

  // ─── Busca / filtro ─────────────────────────────────────
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedType;
  String? get selectedType => _selectedType;

  List<String> _types = [];
  List<String> get types => _types;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ─── Init ────────────────────────────────────────────────
  Future<void> init() async {
    await Future.wait([
      loadPokemonList(),
      _loadFavoriteIds(),
      _loadTypes(),
    ]);
    _listenToFavorites();
  }

  // ─── LISTA ───────────────────────────────────────────────
  Future<void> loadPokemonList({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _pokemonList = [];
    }

    if (_listState == LoadingState.loading) return;

    _listState = LoadingState.loading;
    notifyListeners();

    try {
      final result = await _api.fetchPokemonList(offset: _offset);
      _totalCount = result['count'] as int;
      final items = result['items'] as List<PokemonListItem>;
      _pokemonList = [..._pokemonList, ...items];
      _offset = _pokemonList.length;
      _listState = LoadingState.loaded;
    } catch (e) {
      _listState = LoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!hasMore || _listState == LoadingState.loading) return;
    await loadPokemonList();
  }

  Future<void> refresh() async {
    await loadPokemonList(refresh: true);
  }

  // ─── DETALHE ─────────────────────────────────────────────
  Future<void> loadPokemonDetail(dynamic idOrName) async {
    _detailState = LoadingState.loading;
    _selectedPokemon = null;
    notifyListeners();

    try {
      _selectedPokemon = await _api.fetchPokemonDetail(idOrName);
      _detailState = LoadingState.loaded;

      // Salva no Firebase como recente
      await _firebase.saveRecentlyViewed(_selectedPokemon!);
      await _firebase.logPokemonViewed(_selectedPokemon!);
    } catch (e) {
      _detailState = LoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ─── BUSCA ───────────────────────────────────────────────
  Future<void> search(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _selectedType = null;
      await refresh();
      return;
    }

    _listState = LoadingState.loading;
    notifyListeners();

    await _firebase.logSearch(query);

    try {
      // Tenta buscar por nome/id direto
      final pokemon = await _api.searchPokemon(query);
      if (pokemon != null) {
        _pokemonList = [PokemonListItem(name: pokemon.name, url: 'https://pokeapi.co/api/v2/pokemon/${pokemon.id}/')];
        _totalCount = 1;
        _listState = LoadingState.loaded;
      } else {
        _pokemonList = [];
        _totalCount = 0;
        _listState = LoadingState.loaded;
      }
    } catch (e) {
      _listState = LoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ─── FILTRO POR TIPO ────────────────────────────────────
  Future<void> filterByType(String? type) async {
    _selectedType = type;
    _searchQuery = '';

    if (type == null) {
      await refresh();
      return;
    }

    _listState = LoadingState.loading;
    notifyListeners();

    try {
      final items = await _api.fetchPokemonByType(type);
      _pokemonList = items;
      _totalCount = items.length;
      _listState = LoadingState.loaded;
    } catch (e) {
      _listState = LoadingState.error;
    }
    notifyListeners();
  }

  Future<void> _loadTypes() async {
    _types = await _api.fetchTypes();
    notifyListeners();
  }

  // ─── FAVORITOS ───────────────────────────────────────────
  Future<void> _loadFavoriteIds() async {
    // Carregado via stream abaixo
  }

  void _listenToFavorites() {
    _firebase.favoritesStream().listen((favorites) {
      _favoriteIds = favorites.map((p) => p.id).toSet();
      notifyListeners();
    });
  }

  bool isFavorite(int id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(Pokemon pokemon) async {
    final isFav = await _firebase.toggleFavorite(pokemon);
    if (isFav) {
      _favoriteIds.add(pokemon.id);
    } else {
      _favoriteIds.remove(pokemon.id);
    }
    notifyListeners();
  }
}
