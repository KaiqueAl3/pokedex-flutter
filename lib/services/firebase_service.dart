import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/pokemon.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Coleção de favoritos (sem autenticação: usa um userId genérico local)
  static const String _favoritesCollection = 'favorites';
  static const String _defaultUserId = 'user_default';

  CollectionReference<Map<String, dynamic>> get _favRef =>
      _firestore
          .collection(_favoritesCollection)
          .doc(_defaultUserId)
          .collection('pokemon');

  // ─── FAVORITOS ─────────────────────────────────────────────

  /// Stream em tempo real dos favoritos
  Stream<List<Pokemon>> favoritesStream() {
    return _favRef.orderBy('savedAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((doc) => Pokemon.fromFirestore(doc.data()))
              .toList(),
        );
  }

  /// Verifica se um Pokémon está nos favoritos
  Future<bool> isFavorite(int pokemonId) async {
    final doc = await _favRef.doc(pokemonId.toString()).get();
    return doc.exists;
  }

  /// Adiciona Pokémon aos favoritos
  Future<void> addFavorite(Pokemon pokemon) async {
    await _favRef.doc(pokemon.id.toString()).set(pokemon.toFirestore());

    await _analytics.logEvent(
      name: 'add_favorite',
      parameters: {
        'pokemon_id': pokemon.id,
        'pokemon_name': pokemon.name,
        'pokemon_type': pokemon.types.first,
      },
    );
  }

  /// Remove Pokémon dos favoritos
  Future<void> removeFavorite(int pokemonId) async {
    await _favRef.doc(pokemonId.toString()).delete();

    await _analytics.logEvent(
      name: 'remove_favorite',
      parameters: {'pokemon_id': pokemonId},
    );
  }

  /// Toggle favorito
  Future<bool> toggleFavorite(Pokemon pokemon) async {
    final fav = await isFavorite(pokemon.id);
    if (fav) {
      await removeFavorite(pokemon.id);
      return false;
    } else {
      await addFavorite(pokemon);
      return true;
    }
  }

  // ─── ANALYTICS ─────────────────────────────────────────────

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logPokemonViewed(Pokemon pokemon) async {
    await _analytics.logEvent(
      name: 'pokemon_viewed',
      parameters: {
        'pokemon_id': pokemon.id,
        'pokemon_name': pokemon.name,
        'pokemon_type': pokemon.types.first,
      },
    );
  }

  Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }

  // ─── RECENTES ──────────────────────────────────────────────

  Future<void> saveRecentlyViewed(Pokemon pokemon) async {
    await _firestore
        .collection('recently_viewed')
        .doc(_defaultUserId)
        .collection('pokemon')
        .doc(pokemon.id.toString())
        .set({
      ...pokemon.toFirestore(),
      'viewedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Pokemon>> recentlyViewedStream() {
    return _firestore
        .collection('recently_viewed')
        .doc(_defaultUserId)
        .collection('pokemon')
        .orderBy('viewedAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Pokemon.fromFirestore(doc.data()))
              .toList(),
        );
  }
}
