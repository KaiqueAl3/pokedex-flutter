import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/type_chip.dart';
import '../widgets/stat_bar.dart';
import '../theme/app_theme.dart';

class DetailScreen extends StatefulWidget {
  final int pokemonId;

  const DetailScreen({super.key, required this.pokemonId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showShiny = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokemonProvider>().loadPokemonDetail(widget.pokemonId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PokemonProvider>(
      builder: (context, provider, _) {
        final pokemon = provider.selectedPokemon;
        final isLoading = provider.detailState == LoadingState.loading;

        if (isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        if (pokemon == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Pokémon não encontrado')),
          );
        }

        final primaryType = pokemon.types.isNotEmpty ? pokemon.types.first : 'normal';
        final typeColor = AppTheme.getTypeColor(primaryType);
        final isFav = provider.isFavorite(pokemon.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: typeColor.withOpacity(0.3),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              typeColor.withOpacity(0.4),
                              AppTheme.background,
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showShiny = !_showShiny),
                              child: Hero(
                                tag: 'pokemon_image_${pokemon.id}',
                                child: CachedNetworkImage(
                                  imageUrl: _showShiny
                                      ? pokemon.shinyImageUrl
                                      : pokemon.imageUrl,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.catching_pokemon,
                                    size: 120,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            if (_showShiny)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  '✨ Shiny',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => provider.toggleFavorite(pokemon),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isFav ? Icons.star : Icons.star_border,
                        key: ValueKey(isFav),
                        color: isFav ? const Color(0xFFFFD700) : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome e ID
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pokemon.formattedId,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  pokemon.capitalizedName,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tipos
                      Wrap(
                        spacing: 8,
                        children: pokemon.types
                            .map((t) => TypeChip(type: t, large: true))
                            .toList(),
                      ),

                      const SizedBox(height: 20),

                      // Info cards
                      Row(
                        children: [
                          Expanded(
                              child: _InfoCard(
                                  label: 'Altura',
                                  value: pokemon.formattedHeight,
                                  icon: Icons.height)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _InfoCard(
                                  label: 'Peso',
                                  value: pokemon.formattedWeight,
                                  icon: Icons.monitor_weight_outlined)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _InfoCard(
                                  label: 'Exp. Base',
                                  value: '${pokemon.baseExperience}',
                                  icon: Icons.bolt)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Toque para shiny
                      GestureDetector(
                        onTap: () => setState(() => _showShiny = !_showShiny),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showShiny
                                    ? Icons.auto_awesome
                                    : Icons.auto_awesome_outlined,
                                color: const Color(0xFFFFD700),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _showShiny
                                    ? 'Ver versão normal'
                                    : 'Ver versão Shiny ✨',
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tabs
                      TabBar(
                        controller: _tabController,
                        indicatorColor: typeColor,
                        labelColor: typeColor,
                        unselectedLabelColor: AppTheme.textSecondary,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                        tabs: const [
                          Tab(text: 'Sobre'),
                          Tab(text: 'Stats'),
                          Tab(text: 'Habilidades'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        height: 280,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAboutTab(pokemon),
                            _buildStatsTab(pokemon, typeColor),
                            _buildAbilitiesTab(pokemon),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutTab(pokemon) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pokemon.description.isNotEmpty) ...[
            const Text(
              'Descrição',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pokemon.description,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'Tipos',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pokemon.types.map<Widget>((t) => TypeChip(type: t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(pokemon, Color color) {
    return SingleChildScrollView(
      child: Column(
        children: pokemon.stats
            .map<Widget>((s) => StatBar(stat: s, color: color))
            .toList(),
      ),
    );
  }

  Widget _buildAbilitiesTab(pokemon) {
    return ListView.separated(
      itemCount: pokemon.abilities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final ability = pokemon.abilities[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: ability.isHidden
                    ? const Color(0xFFFFD700)
                    : AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ability.capitalizedName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (ability.isHidden)
                      const Text(
                        'Habilidade Oculta',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
