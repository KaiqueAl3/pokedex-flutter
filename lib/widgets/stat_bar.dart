import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../theme/app_theme.dart';

class StatBar extends StatefulWidget {
  final PokemonStat stat;
  final Color color;

  const StatBar({super.key, required this.stat, required this.color});

  @override
  State<StatBar> createState() => _StatBarState();
}

class _StatBarState extends State<StatBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _barColor {
    if (widget.stat.value >= 100) return const Color(0xFF4CAF50);
    if (widget.stat.value >= 60) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              widget.stat.displayName,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              widget.stat.value.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return LinearProgressIndicator(
                    value: (widget.stat.value / 255) * _animation.value,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                    minHeight: 8,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
