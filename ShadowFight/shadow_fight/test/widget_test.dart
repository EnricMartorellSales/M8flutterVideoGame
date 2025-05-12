import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  // Posición y estado del jugador
  double playerX = 100;
  double playerY = 300;
  double playerVelocityY = 0;
  bool isJumping = false;
  bool facingRight = true;
  double playerHealth = 100;
  
  // Enemigos
  List<Map<String, dynamic>> enemies = [];
  final Random random = Random();
  
  // Proyectiles
  List<Map<String, dynamic>> bullets = [];
  final double bulletSpeed = 15;
  final double bulletSize = 8;
  
  // Constantes del juego
  final double playerWidth = 50;
  final double playerHeight = 80;
  final double gravity = 0.8;
  final double jumpForce = -15;
  final double groundLevel = 300;
  final double moveSpeed = 5;
  
  // Scroll del nivel
  double levelOffset = 0;
  final double levelWidth = 2000;
  
  // Control de disparo
  bool canShoot = true;
  final double shootCooldown = 0.3;

  @override
  void initState() {
    super.initState();
    _generateEnemies();
    _gameLoop();
  }

  void _gameLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 16));
      
      if (!mounted) return;
      
      setState(() {
        // Aplicar gravedad al jugador
        if (playerY < groundLevel || playerVelocityY < 0) {
          playerY += playerVelocityY;
          playerVelocityY += gravity;
        }
        
        // Aterrizar en el suelo
        if (playerY >= groundLevel) {
          playerY = groundLevel;
          playerVelocityY = 0;
          isJumping = false;
        }
        
        // Mover balas
        _updateBullets();
        
        // Mover enemigos
        _updateEnemies();
        
        // Scroll del nivel
        _updateLevelScroll();
      });
    }
  }

  void _updateLevelScroll() {
    final screenWidth = MediaQuery.of(context).size.width;
    double targetOffset = screenWidth / 2 - playerX;
    targetOffset = targetOffset.clamp(-levelWidth + screenWidth, 0.0);
    levelOffset = levelOffset * 0.9 + targetOffset * 0.1;
  }

  void _generateEnemies() {
    for (int i = 0; i < 5; i++) {
      enemies.add({
        'x': 500.0 + random.nextDouble() * 1500,
        'y': groundLevel - 70,
        'width': 40.0,
        'height': 70.0,
        'health': 100.0,
        'speed': 1.0 + random.nextDouble() * 2,
        'direction': random.nextBool() ? 1 : -1,
      });
    }
  }

  void _updateEnemies() {
    for (var enemy in enemies.toList()) {
      enemy['x'] += enemy['speed'] * enemy['direction'];
      
      if (enemy['x'] < 0 || enemy['x'] > levelWidth - enemy['width']) {
        enemy['direction'] *= -1;
      }
      
      for (var bullet in bullets.toList()) {
        if (_checkCollision(
          bullet['x'], bullet['y'], bulletSize, bulletSize,
          enemy['x'], enemy['y'], enemy['width'], enemy['height']
        )) {
          enemy['health'] -= 25;
          bullets.remove(bullet);
          if (enemy['health'] <= 0) enemies.remove(enemy);
          break;
        }
      }
    }
  }

  void _updateBullets() {
    for (var bullet in bullets.toList()) {
      bullet['x'] += bullet['speed'] * bullet['direction'];
      
      if (bullet['x'] < 0 || bullet['x'] > levelWidth) {
        bullets.remove(bullet);
      }
    }
  }

  bool _checkCollision(double x1, double y1, double w1, double h1,
                      double x2, double y2, double w2, double h2) {
    return x1 < x2 + w2 && x1 + w1 > x2 &&
           y1 < y2 + h2 && y1 + h1 > y2;
  }

  void _jump() {
    if (!isJumping) {
      playerVelocityY = jumpForce;
      isJumping = true;
    }
  }

  void _shoot() {
    if (!canShoot) return;
    
    setState(() {
      bullets.add({
        'x': playerX + (facingRight ? playerWidth : 0),
        'y': playerY + playerHeight / 2,
        'direction': facingRight ? 1 : -1,
        'speed': bulletSpeed,
      });
      
      canShoot = false;
      Future.delayed(Duration(milliseconds: (shootCooldown * 1000).toInt()), () {
        if (mounted) {
          setState(() {
            canShoot = true;
          });
        }
      });
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      setState(() {
        if (event.logicalKey == LogicalKeyboardKey.keyA) {
          playerX -= moveSpeed;
          facingRight = false;
        } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
          playerX += moveSpeed;
          facingRight = true;
        } else if (event.logicalKey == LogicalKeyboardKey.space) {
          _jump();
        }
        
        playerX = playerX.clamp(0, levelWidth - playerWidth);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _handleKeyEvent,
        child: GestureDetector(
          onTapDown: (_) => _shoot(),
          child: Stack(
            children: [
              // Fondo del nivel
              Transform.translate(
                offset: Offset(levelOffset, 0),
                child: Container(
                  width: levelWidth,
                  height: screenSize.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blueGrey.shade900,
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Plataformas y escenario
              Transform.translate(
                offset: Offset(levelOffset, 0),
                child: Column(
                  children: [
                    // Suelo
                    Positioned(
                      left: 0,
                      top: groundLevel + playerHeight,
                      child: Container(
                        width: levelWidth,
                        height: 20,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    
                    // Plataformas
                    for (double i = 0; i < levelWidth; i += 300)
                      Positioned(
                        left: i + 150,
                        top: groundLevel - 100,
                        child: Container(
                          width: 100,
                          height: 20,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Enemigos
              for (var enemy in enemies)
                Transform.translate(
                  offset: Offset(enemy['x'] + levelOffset, enemy['y']),
                  child: Container(
                    width: enemy['width'],
                    height: enemy['height'],
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              
              // Balas
              for (var bullet in bullets)
                Positioned(
                  left: bullet['x'] + levelOffset,
                  top: bullet['y'],
                  child: Container(
                    width: bulletSize,
                    height: bulletSize,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.8),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Jugador
              Positioned(
                left: playerX + levelOffset,
                top: playerY,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(facingRight ? 1.0 : -1.0, 1.0),
                  child: Container(
                    width: playerWidth,
                    height: playerHeight,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.7),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // HUD
              Positioned(
                top: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HEALTH: ${playerHealth.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ENEMIES: ${enemies.length}',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Controls: A/D to move, SPACE to jump, CLICK to shoot',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}