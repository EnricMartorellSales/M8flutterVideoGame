import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const ShadowComplexGame());
}

class ShadowComplexGame extends StatelessWidget {
  const ShadowComplexGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shadow Complex Style',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  // Player state
  double playerX = 100;
  double playerY = 300;
  double playerVelocityY = 0;
  double playerVelocityX = 0;
  bool isJumping = false;
  bool facingRight = true;
  double playerHealth = 100;
  
  // Movement control
  bool moveLeft = false;
  bool moveRight = false;
  
  // Enemies
  List<Map<String, dynamic>> enemies = [];
  final Random random = Random();
  
  // Bullets
  List<Map<String, dynamic>> bullets = [];
  final double bulletSpeed = 15;
  final double bulletSize = 8;
  
  // Game constants
  final double playerWidth = 50;
  final double playerHeight = 80;
  final double gravity = 0.8;
  final double jumpForce = -15;
  final double groundLevel = 300;
  final double moveSpeed = 5;
  final double acceleration = 0.5;
  final double friction = 0.85;
  
  // Level scrolling
  double levelOffset = 0;
  double levelWidth = 2000;
  late double screenWidth;
  late double screenHeight;
  
  // Shooting control
  bool canShoot = true;
  final double shootCooldown = 0.3;

  // Mouse position
  Offset? mousePosition;

  @override
  void initState() {
    super.initState();
    _generateEnemies();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    _gameLoop();
  }

  void _gameLoop() async {
    const duration = Duration(milliseconds: 16);
    while (mounted) {
      final startTime = DateTime.now();
      
      if (!mounted) return;
      
      setState(() {
        // Apply physics
        _updatePlayerPosition();
        _updateBullets();
        _updateEnemies();
        _updateLevelScroll();
      });
      
      final elapsed = DateTime.now().difference(startTime);
      await Future.delayed(duration - elapsed);
    }
  }

  void _updatePlayerPosition() {
    // Apply gravity
    if (playerY < groundLevel || playerVelocityY < 0) {
      playerY += playerVelocityY;
      playerVelocityY += gravity;
    }
    
    // Land on ground
    if (playerY >= groundLevel) {
      playerY = groundLevel;
      playerVelocityY = 0;
      isJumping = false;
    }
    
    // Horizontal movement with acceleration
    if (moveLeft) {
      playerVelocityX -= acceleration;
      facingRight = false;
    }
    if (moveRight) {
      playerVelocityX += acceleration;
      facingRight = true;
    }
    
    // Apply friction
    playerVelocityX *= friction;
    if (playerVelocityX.abs() < 0.1) playerVelocityX = 0;
    
    playerX += playerVelocityX;
    playerX = playerX.clamp(0, levelWidth - playerWidth);
  }

  void _updateLevelScroll() {
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
      bullet['x'] += bullet['directionX'] * bullet['speed'];
      bullet['y'] += bullet['directionY'] * bullet['speed'];
      
      if (bullet['x'] < 0 || bullet['x'] > levelWidth ||
          bullet['y'] < 0 || bullet['y'] > screenHeight) {
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

  void _shoot(Offset targetPosition) {
    if (!canShoot) return;
    
    setState(() {
      // Calculate player center position on screen
      final playerScreenX = playerX + playerWidth/2 + levelOffset;
      final playerScreenY = playerY + playerHeight/2;
      
      // Calculate direction vector
      final deltaX = targetPosition.dx - playerScreenX;
      final deltaY = targetPosition.dy - playerScreenY;
      final distance = sqrt(deltaX * deltaX + deltaY * deltaY);
      
      // Normalize direction
      final directionX = deltaX / distance;
      final directionY = deltaY / distance;
      
      bullets.add({
        'x': playerX + playerWidth/2,  // World position X
        'y': playerY + playerHeight/2, // World position Y
        'directionX': directionX,
        'directionY': directionY,
        'speed': bulletSpeed,
      });
      
      // Update player facing direction
      facingRight = deltaX > 0;
      
      // Cooldown
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
    setState(() {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.keyA) {
          moveLeft = true;
        } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
          moveRight = true;
        } else if (event.logicalKey == LogicalKeyboardKey.space) {
          _jump();
        }
      } else if (event is RawKeyUpEvent) {
        if (event.logicalKey == LogicalKeyboardKey.keyA) {
          moveLeft = false;
        } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
          moveRight = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _handleKeyEvent,
        child: Listener(
          onPointerMove: (PointerMoveEvent event) {
            mousePosition = event.position;
          },
          onPointerDown: (PointerDownEvent event) {
            _shoot(event.position);
          },
          child: SizedBox.expand(
            child: ClipRect(
              child: Stack(
                children: [
                  // Background
                  Positioned(
                    left: levelOffset,
                    child: Container(
                      width: levelWidth,
                      height: screenHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueGrey.shade900,
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Ground
                  Positioned(
                    left: levelOffset,
                    top: groundLevel + playerHeight,
                    child: Container(
                      width: levelWidth,
                      height: 20,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  
                  // Platforms
                  for (double i = 0; i < levelWidth; i += 300)
                    Positioned(
                      left: i + 150 + levelOffset,
                      top: groundLevel - 100,
                      child: Container(
                        width: 100,
                        height: 20,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  
                  // Enemies
                  for (var enemy in enemies)
                    Positioned(
                      left: enemy['x'] + levelOffset,
                      top: enemy['y'],
                      child: Container(
                        width: enemy['width'],
                        height: enemy['height'],
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  
                  // Bullets (free direction)
                  for (var bullet in bullets)
                    Positioned(
                      left: bullet['x'] + levelOffset - bulletSize,
                      top: bullet['y'] - bulletSize,
                      child: Transform.rotate(
                        angle: atan2(bullet['directionY'], bullet['directionX']),
                        child: Container(
                          width: bulletSize * 2,
                          height: bulletSize,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(bulletSize / 2),
                          ),
                        ),
                      ),
                    ),
                  
                  // Player
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
        ),
      ),
    );
  }
}