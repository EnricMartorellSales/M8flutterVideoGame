import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/geometry.dart';
import 'package:shadow_fight/game/components/bullet.dart';
import 'package:shadow_fight/game/shadow_complex_game.dart';

class Player extends PositionComponent with HasGameRef<ShadowComplexGame>, CollisionCallbacks {
  double velocityY = 0;
  double velocityX = 0;
  bool isJumping = false;
  bool facingRight = true;
  bool moveLeft = false;
  bool moveRight = false;
  
  final double gravity = 0.8;
  final double jumpForce = -15;
  final double acceleration = 0.5;
  final double friction = 0.85;
  bool canShoot = true;
  final double shootCooldown = 0.3;

  Player({required super.position}) {
    size = Vector2(50, 80);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Movimiento horizontal
    if (moveLeft) velocityX -= acceleration;
    if (moveRight) velocityX += acceleration;
    
    // Física
    velocityX *= friction;
    velocityY += gravity;
    position += Vector2(velocityX, velocityY);
    
    // Límites del nivel
    position.x = position.x.clamp(0, game.levelWidth - size.x);
    
    // Suelo
    if (position.y >= game.groundLevel) {
      position.y = game.groundLevel;
      velocityY = 0;
      isJumping = false;
    }
  }

  void jump() {
    if (!isJumping) {
      velocityY = -jumpForce;
      isJumping = true;
    }
  }

  void shoot(Vector2 target) {
    if (!canShoot) return;
    
    final bullet = Bullet(
      position: position.clone(),
      direction: (target - position).normalized(),
    );
    game.world.add(bullet);
    
    canShoot = false;
    Future.delayed(Duration(seconds: shootCooldown), () => canShoot = true);
  }
}