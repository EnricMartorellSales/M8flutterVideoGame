import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadow_fight/game/shadow_complex_game.dart';
import 'package:shadow_fight/game/bullet.dart';

class Player extends PositionComponent with KeyboardHandler, CollisionCallbacks, HasGameRef<ShadowComplexGame> {
  double velocityY = 0;
  double velocityX = 0;
  bool isJumping = false;
  bool facingRight = true;
  bool moveLeft = false;
  bool moveRight = false;
  double _health = 100;
  
  double get health => _health;
  set health(double value) {
    _health = value.clamp(0, 100);
    game.playerHealth.value = _health;
  }

  final double gravity = 0.8;
  final double jumpForce = -15;
  final double acceleration = 0.5;
  final double friction = 0.85;
  bool canShoot = true;
  final double shootCooldown = 0.3;

  Player({required ShadowComplexGame game}) {
    this.game = game;
    size = Vector2(50, 80);
    position = Vector2(100, game.groundLevel);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (moveLeft) {
      velocityX -= acceleration;
      facingRight = false;
    }
    if (moveRight) {
      velocityX += acceleration;
      facingRight = true;
    }
    
    velocityX *= friction;
    position.x += velocityX;
    
    velocityY += gravity;
    position.y += velocityY;
    
    position.x = position.x.clamp(0, game.levelWidth - size.x);
    
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

  void shoot(Vector2 targetPosition) {
    if (!canShoot) return;
    
    final bullet = Bullet(
      position: position.clone(),
      direction: (targetPosition - position).normalized(),
      game: game,
    );
    game.add(bullet);
    game.bullets.add(bullet);
    
    canShoot = false;
    Future.delayed(Duration(milliseconds: (shootCooldown * 1000).toInt()), () {
      canShoot = true;
    });
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isDown = event is KeyDownEvent;
    
    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        moveLeft = isDown;
        return true;
      case LogicalKeyboardKey.keyD:
        moveRight = isDown;
        return true;
      case LogicalKeyboardKey.space:
        if (isDown) jump();
        return true;
      default:
        return false;
    }
  }
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;
    
    canvas.save();
    if (!facingRight) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(5),
      ),
      paint,
    );
    
    canvas.restore();
  }
}