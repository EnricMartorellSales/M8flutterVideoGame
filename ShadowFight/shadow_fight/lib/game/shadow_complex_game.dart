import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:shadow_fight/game/controllers/game_controller.dart';
import 'package:shadow_fight/game/components/player.dart';
import 'package:shadow_fight/game/components/enemy.dart';
import 'package:shadow_fight/game/components/platform.dart';
import 'package:shadow_fight/game/components/bullet.dart';

class ShadowComplexGame extends FlameGame with HasCollisionDetection {
  late final GameController gameController;
  late Player player;
  late CameraComponent cameraComponent;
  final double groundLevel = 300;
  final double levelWidth = 2000;
  final List<Enemy> enemies = [];
  final List<Bullet> bullets = [];
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    cameraComponent = CameraComponent(world: world);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;
    addAll([cameraComponent, world]);
    
    player = Player(position: Vector2(100, groundLevel), game: this);
    world.add(player);
    cameraComponent.follow(player);

    gameController = GameController(this);
    
    _generatePlatforms();
    _generateEnemies();
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameController.update(dt);
  }

  void _generatePlatforms() {
    for (double i = 0; i < levelWidth; i += 300) {
      world.add(Platform(
        position: Vector2(i + 150, groundLevel - 100),
        size: Vector2(100, 20),
      ));
    }
  }
  
  void _generateEnemies() {
    for (int i = 0; i < 5; i++) {
      final enemy = Enemy(
        position: Vector2(500.0 + i * 300, groundLevel - 70),
        size: Vector2(40, 70),
        game: this,
      );
      enemies.add(enemy);
      world.add(enemy);
    }
  }
}