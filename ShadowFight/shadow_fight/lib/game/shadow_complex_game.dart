import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:shadow_fight/game/player.dart';
import 'package:shadow_fight/game/enemy.dart';
import 'package:shadow_fight/game/platform.dart';
import 'package:shadow_fight/game/bullet.dart';

class ShadowComplexGame extends FlameGame with HasCollisionDetection {
  final ValueNotifier<int> enemyCount = ValueNotifier(0);
  final ValueNotifier<double> playerHealth = ValueNotifier(100);
  late Player player;
  final double groundLevel = 300;
  final double levelWidth = 2000;
  final List<Bullet> bullets = [];
  final List<Enemy> enemies = [];

  @override
  Future<void> onLoad() async {
    player = Player(game: this);
    add(player);
    addAll(_generatePlatforms());
    addAll(_generateEnemies());
  }

  List<Platform> _generatePlatforms() {
    final platforms = <Platform>[];
    for (double i = 0; i < levelWidth; i += 300) {
      platforms.add(Platform(
        position: Vector2(i + 150, groundLevel - 100),
      ));
    }
    return platforms;
  }

  List<Enemy> _generateEnemies() {
    final enemies = <Enemy>[];
    for (int i = 0; i < 5; i++) {
      enemies.add(Enemy(
        position: Vector2(500.0 + i * 300, groundLevel - 70),
        game: this,
      ));
    }
    enemyCount.value = enemies.length;
    return enemies;
  }

  @override
  void update(double dt) {
    super.update(dt);
    enemyCount.value = enemies.where((e) => !e.isRemoved).length;
    playerHealth.value = player.health;

    // Check bullet-enemy collisions
    for (final bullet in bullets.toList()) {
      for (final enemy in enemies.toList()) {
        if (bullet.isRemoved || enemy.isRemoved) continue;
        
        if (bullet.toRect().overlaps(enemy.toRect())) {
          enemy.health -= 25;
          bullet.removeFromParent();
          bullets.remove(bullet);
          
          if (enemy.health <= 0) {
            enemy.removeFromParent();
            enemies.remove(enemy);
          }
          break;
        }
      }
    }
  }

  @override
  void onRemove() {
    enemyCount.dispose();
    playerHealth.dispose();
    super.onRemove();
  }
}