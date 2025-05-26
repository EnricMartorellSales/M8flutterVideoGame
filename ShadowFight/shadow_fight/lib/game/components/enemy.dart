import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import 'package:shadow_fight/game/shadow_complex_game.dart';
import 'dart:math';

class Enemy extends PositionComponent with CollisionCallbacks {
  final ShadowComplexGame game;
  double health = 100;
  double speed = 1.0;
  int direction = 1;
  final Random _random = Random();
  
  Enemy({required super.position, required this.game, super.size}) {
    anchor = Anchor.bottomCenter;
  }
  
  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    speed = 1.0 + _random.nextDouble() * 2;
    direction = _random.nextBool() ? 1 : -1;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    position.x += speed * direction;
    
    if (position.x < 0 || position.x > game.levelWidth - size.x) {
      direction *= -1;
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(5),
      ),
      paint,
    );
  }
}