import 'package:flutter/material.dart';
import 'package:shadow_fight/game/shadow_complex_game.dart';

class HudOverlay extends StatelessWidget {
  final ShadowComplexGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: game.playerHealth,
              builder: (context, health, child) {
                return Text(
                  'HEALTH: ${health.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<int>(
              valueListenable: game.enemyCount,
              builder: (context, count, child) {
                return Text(
                  'ENEMIES: $count',
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 16,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Controls: A/D to move, SPACE to jump, CLICK to shoot',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}