import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flame/input.dart';
import 'package:flame/geometry.dart';
import 'package:shadow_fight/game/components/player.dart';
import 'package:shadow_fight/game/shadow_complex_game.dart';

class GameController {
  final ShadowComplexGame game;
  late Player player;

  GameController(this.game) {
    player = game.player;
  }

  void handleKeyEvent(RawKeyEvent event) {
    final isKeyDown = event is RawKeyDownEvent;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        player.moveLeft = isKeyDown;
        if (isKeyDown) player.facingRight = false;
        break;
      case LogicalKeyboardKey.keyD:
        player.moveRight = isKeyDown;
        if (isKeyDown) player.facingRight = true;
        break;
      case LogicalKeyboardKey.space:
        if (isKeyDown) player.jump();
        break;
      default:
        break;
    }
  }

  void handlePointerDown(PointerDownEvent event) {
    final localPosition = Vector2(
      event.localPosition.dx,
      event.localPosition.dy,
    );
    
    final worldPosition = game.cameraComponent.viewfinder.localToGlobal(localPosition);
    player.shoot(worldPosition);
  }

  void update(double dt) {
    _checkBulletEnemyCollisions();
  }

  void _checkBulletEnemyCollisions() {
    for (final bullet in game.bullets.toList()) {
      for (final enemy in game.enemies.toList()) {
        if (bullet.isRemoved) continue;
        
        if (bullet.toRect().overlaps(enemy.toRect())) {
          enemy.health -= 25;
          bullet.removeFromParent();
          game.bullets.remove(bullet);
          
          if (enemy.health <= 0) {
            enemy.removeFromParent();
            game.enemies.remove(enemy);
          }
          break;
        }
      }
    }
  }
}