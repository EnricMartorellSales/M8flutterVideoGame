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

  void onKeyEvent(RawKeyEvent event) {
    final isDown = event is RawKeyDownEvent;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        player.moveLeft = isDown;
        break;
      case LogicalKeyboardKey.keyD:
        player.moveRight = isDown;
        break;
      case LogicalKeyboardKey.space:
        if (isDown) player.jump();
        break;
    }
  }

  void onPointerDown(PointerDownEvent event) {
    final worldPos = game.cameraComponent.viewfinder.localToGlobal(
      Vector2(event.localPosition.dx, event.localPosition.dy),
    );
    player.shoot(worldPos);
  }

  void update(double dt) {}
}