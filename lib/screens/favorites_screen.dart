import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/firebase_service.dart';
import '../providers/pokemon_provider.dart';
import '../models/pokemon.dart';
import '../widgets/type_chip.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Color(0xFFFFD700), size: 22),
            SizedBox(width: 8),
            Text(
              'Favoritos',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Pokemon>>(
        stream: FirebaseService().favoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off,
                      color: AppTheme.textSecondary, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    'Erro ao carregar favoritos',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.3,
                    child: const Icon(
                      Icons.catching_pokemon,
                      size: 100,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nenhum favorito ainda!',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toque na ⭐ no detalhe de um Pokémon\npara adicioná-lo aqui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        '${favorites.length} Pokémon salvos',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Salvo no Firebase ☁️',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final pokemon = favorites[index];
                    return _FavoriteCard(
                      pokemon: pokemon,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(pokemonId: pokemon.id),
                        ),
                      ),
                      onRemove: () => context
                          .read<PokemonProvider>()
                          .toggleFavorite(pokemon),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.pokemon,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = pokemon.types.isNotEmpty
        ? AppTheme.getTypeColor(pokemon.types.first)
        : AppTheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              typeColor.withOpacity(0.15),
              AppTheme.cardBg,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: typeColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Imagem
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(18)),
              child: Container(
                width: 100,
                height: 100,
                color: typeColor.withOpacity(0.1),
                child: Hero(
                  tag: 'fav_pokemon_${pokemon.id}',
                  child: CachedNetworkImage(
                    imageUrl: pokemon.imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.catching_pokemon,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pokemon.formattedId,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      pokemon.capitalizedName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: pokemon.types
                          .map((t) => TypeChip(type: t))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Remove button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.star, color: Color(0xFFFFD700), size: 22),
              tooltip: 'Remover dos favoritos',
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
