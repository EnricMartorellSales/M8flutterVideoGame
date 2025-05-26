import 'package:flutter/material.dart';
import 'package:shadow_fight/game/shadow_complex_game.dart';

class HudOverlay extends StatelessWidget {
  final ShadowComplexGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.enemyCount,
      builder: (context, count, child) {
        return Column(
          children: [
            Text('HEALTH: ${game.player.health.toInt()}%'),
            Text('ENEMIES: $count'),
          ],
        );
      },
    );
  }
}