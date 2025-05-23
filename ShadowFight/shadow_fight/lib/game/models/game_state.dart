import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  int _score = 0;
  int _enemiesRemaining = 0;

  int get score => _score;
  int get enemiesRemaining => _enemiesRemaining;

  void updateScore(int points) {
    _score += points;
    notifyListeners();
  }

  void updateEnemies(int count) {
    _enemiesRemaining = count;
    notifyListeners();
  }
}