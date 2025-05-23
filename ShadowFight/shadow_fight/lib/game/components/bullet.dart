import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:shadow_fight/game/shadow_complex_game.dart';

class Bullet extends PositionComponent with HasGameRef<ShadowComplexGame> {
  final Vector2 direction;
  final double speed = 15;
  
  Bullet({required super.position, required this.direction}) {
    size = Vector2(16, 8);
    anchor = Anchor.center;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    position += direction * speed;
    
    if (position.x < 0 || position.x > game.levelWidth ||
        position.y < 0 || position.y > game.size.y) {
      removeFromParent();
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.fill;
    
    canvas.save();
    canvas.rotate(direction.angleTo(Vector2(1, 0)));
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.x/2, -size.y/2, size.x, size.y),
        Radius.circular(size.y/2),
      ),
      paint,
    );
    
    canvas.restore();
  }
}