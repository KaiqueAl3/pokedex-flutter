import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TypeChip extends StatelessWidget {
  final String type;
  final bool large;

  const TypeChip({super.key, required this.type, this.large = false});

  static const Map<String, String> _typeEmojis = {
    'normal': '⚪',
    'fire': '🔥',
    'water': '💧',
    'electric': '⚡',
    'grass': '🌿',
    'ice': '❄️',
    'fighting': '🥊',
    'poison': '☠️',
    'ground': '🌍',
    'flying': '🌬️',
    'psychic': '🔮',
    'bug': '🐛',
    'rock': '🪨',
    'ghost': '👻',
    'dragon': '🐉',
    'dark': '🌑',
    'steel': '⚙️',
    'fairy': '✨',
  };

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getTypeColor(type);
    final emoji = _typeEmojis[type] ?? '❓';
    final label = type[0].toUpperCase() + type.substring(1);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: large ? 16 : 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: large ? 14 : 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
