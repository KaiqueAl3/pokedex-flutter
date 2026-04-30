import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showTypeFilter = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokemonProvider>().init();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        context.read<PokemonProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          _buildSearchBar(),
          if (_showTypeFilter) _buildTypeFilter(),
          _buildGrid(),
          _buildLoadingIndicator(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.star, color: Colors.white),
        label: const Text(
          'Favoritos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.background,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.catching_pokemon, color: AppTheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Pokédex',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFFFF6B6B)],
                  ).createShader(
                    const Rect.fromLTWH(0, 0, 120, 40),
                  ),
              ),
            ),
          ],
        ),
        background: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryDark, AppTheme.background],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -10,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.catching_pokemon,
                  size: 200,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 20,
              child: Consumer<PokemonProvider>(
                builder: (_, p, __) => Text(
                  '${p.pokemonList.length} Pokémon carregados',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  if (val.isEmpty) {
                    context.read<PokemonProvider>().refresh();
                  }
                },
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    context.read<PokemonProvider>().search(val);
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar por nome ou número...',
                  prefixIcon: Icon(Icons.search),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                setState(() => _showTypeFilter = !_showTypeFilter);
              },
              icon: Icon(
                Icons.filter_list,
                color: _showTypeFilter ? AppTheme.primary : AppTheme.textSecondary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildTypeFilter() {
    final provider = context.watch<PokemonProvider>();
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _typeChip(null, 'Todos', provider),
            ...provider.types.map((t) => _typeChip(t, t, provider)),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String? type, String label, PokemonProvider provider) {
    final selected = provider.selectedType == type;
    final color = type != null ? AppTheme.getTypeColor(type) : AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label[0].toUpperCase() + label.substring(1),
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        selected: selected,
        selectedColor: color,
        backgroundColor: AppTheme.surfaceLight,
        onSelected: (_) => provider.filterByType(type),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
    );
  }

  SliverPadding _buildGrid() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      sliver: Consumer<PokemonProvider>(
        builder: (context, provider, _) {
          if (provider.listState == LoadingState.error) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.primary, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Erro ao carregar Pokémon',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: provider.refresh,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.listState == LoadingState.loading &&
              provider.pokemonList.isEmpty) {
            return SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, __) => _ShimmerCard(),
                childCount: 8,
              ),
            );
          }

          if (provider.pokemonList.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off,
                        color: AppTheme.textSecondary, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum Pokémon encontrado',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          }

          return AnimationLimiter(
            child: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = provider.pokemonList[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    columnCount: 2,
                    duration: const Duration(milliseconds: 375),
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: PokemonCard(
                          item: item,
                          isFavorite: provider.isFavorite(item.id),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailScreen(pokemonId: item.id),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: provider.pokemonList.length,
              ),
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildLoadingIndicator() {
    return SliverToBoxAdapter(
      child: Consumer<PokemonProvider>(
        builder: (_, p, __) {
          if (p.listState == LoadingState.loading && p.pokemonList.isNotEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }
          return const SizedBox(height: 80);
        },
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
