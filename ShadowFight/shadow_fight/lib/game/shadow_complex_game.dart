import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'player.dart';
import 'enemy.dart';
import 'platform.dart';
import 'bullet.dart';

class ShadowComplexGame extends FlameGame with HasCollisionDetection {
  final ValueNotifier<int> enemyCount = ValueNotifier(0);
  final ValueNotifier<double> playerHealth = ValueNotifier(100);
  late Player player;
  final double groundLevel = 300;
  final double levelWidth = 2000;
  final List<Bullet> bullets = [];

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
    enemyCount.value = children.whereType<Enemy>().length;
    playerHealth.value = player.health;
  }

  @override
  void onRemove() {
    enemyCount.dispose();
    playerHealth.dispose();
    super.onRemove();
  }
}