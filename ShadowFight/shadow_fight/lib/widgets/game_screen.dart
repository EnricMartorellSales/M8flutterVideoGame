import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:shadow_fight/game/shadow_complex_game.dart';
import 'package:shadow_fight/widgets/hud.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ShadowComplexGame game;

  @override
  void initState() {
    super.initState();
    game = ShadowComplexGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event, keys) {
          if (event is RawKeyEvent) {
            game.player.onKeyEvent(event, keys);
          }
          return KeyEventResult.ignored;
        },
        child: Listener(
          onPointerDown: (event) {
            final offset = game.camera?.viewfinder.localToGlobal(event.localPosition) ?? event.localPosition;
            final worldPos = Vector2(offset.dx, offset.dy);
            game.player.shoot(worldPos);
          },
          child: GameWidget(
            game: game,
            overlayBuilderMap: {
              'hud': (context, game) => HudOverlay(game: game as ShadowComplexGame),
            },
          ),
        ),
      ),
    );
  }
}