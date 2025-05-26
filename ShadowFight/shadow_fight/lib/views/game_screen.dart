import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:shadow_fight/game/shadow_complex_game.dart';

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
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: game.gameController.handleKeyEvent,
        child: Listener(
          onPointerDown: game.gameController.handlePointerDown,
          child: GameWidget(
            game: game,
          ),
        ),
      ),
    );
  }
}