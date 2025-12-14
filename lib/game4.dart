import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'gameover.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CatchGamePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CatchGamePage extends StatefulWidget {
  const CatchGamePage({super.key});
  @override
  State<CatchGamePage> createState() => _CatchGamePageState();
}

class _CatchGamePageState extends State<CatchGamePage> {
  static const int cols = 4;
  static const int maxMiss = 5;
  static const List<double> colX = [-0.75, -0.25, 0.25, 0.75];

  late int basketCol;
  late bool movingRight;
  late int itemCol;
  late double itemX; // ボールの横位置（-1.0 ~ 1.0）
  late double itemY;
  late double itemVx; // 横方向の速度
  late double itemVy;
  late double gravity;
  late int score;
  late int miss;
  late bool isGameOver;
  late bool isCurveBall; // 変化球かどうか
  late double curveDirection; // 変化の方向（-1 or 1）

  late Timer timer;
  final Random rand = Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    basketCol = 1; // 中央カラム（少し左寄り）
    movingRight = true;
    itemCol = rand.nextInt(cols);
    itemX = colX[itemCol]; // 初期位置
    itemY = 0.0;
    itemVx = 0.0;
    itemVy = 0.0;
    gravity = 0.8;
    score = 0;
    miss = 0; // ミスの回数
    isGameOver = false; // ゲームオーバーかどうか
    isCurveBall = rand.nextDouble() < 0.3; // 30%の確率で変化球
    curveDirection = rand.nextBool() ? 1.0 : -1.0; // 左右どちらに曲がるか
    timer = Timer.periodic(const Duration(milliseconds: 16), _update);
  }

  void _restartGame() {
    timer.cancel();
    _startNewGame();
    setState(() {});
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _update(Timer t) {
    if (isGameOver) return;

    setState(() {
      const dt = 0.016;
      // 重力落下
      itemVy += gravity * dt;
      itemY += itemVy * dt;
      
      // 変化球の場合、横方向に動く
      if (isCurveBall && itemY > 0.3) {
        itemVx += curveDirection * 0.8 * dt; // 横方向の加速度
        itemX += itemVx * dt;
        // 画面外に出ないように制限
        itemX = itemX.clamp(-0.9, 0.9);
      }
      
      if (itemY >= 1.0) {
        // 位置ベースで判定（変化球があるため）
        final ballPos = itemX;
        final basketPos = colX[basketCol];
        final caught = (ballPos - basketPos).abs() < 0.3; // 範囲内ならキャッチ
        _resetItem(caught);
      }
    });
  }

  void _resetItem(bool caught) {
    if (caught) {
      score++;
      gravity = min(gravity + 0.1, 2.0); // 少しずつ重力アップ
    } else {
      miss++;
      if (miss >= maxMiss) {
        _gameOver();
        return;
      }
    }
    // 次のボールを一番上から落とす
    itemY = 0.0;
    itemVy = 0.0;
    itemVx = 0.0;
    itemCol = rand.nextInt(cols);
    itemX = colX[itemCol]; // 初期位置をレーンに合わせる
    isCurveBall = rand.nextDouble() < 0.3; // 30%の確率で変化球
    curveDirection = rand.nextBool() ? 1.0 : -1.0; // 左右どちらに曲がるか
  }

  void _gameOver() {
    isGameOver = true;
    timer.cancel();
  }

  void _onTap() {
    if (isGameOver) return;

    setState(() {
      // 0 ↔ 3 を往復
      if (movingRight) {
        if (basketCol < cols - 1) {
          basketCol++;
        } else {
          movingRight = false;
          basketCol--;
        }
      } else {
        if (basketCol > 0) {
          basketCol--;
        } else {
          movingRight = true;
          basketCol++;
        }
      }
    });
  }

  // レベル1からスタートして5点ごとにレベルアップ
  int get level {
    return 1 + (score ~/ 5);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '⚾ 野球キャッチゲーム ⚾',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text('スコア：$score  ミス：$miss / $maxMiss'),
                  Text('レベル：$level  重力：${gravity.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),
                  Container(
                    width: 220,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // 落ちてくるボール（アニメーション）
                        Align(
                          alignment: Alignment(
                            itemX,              // 左右位置（変化球対応）
                            -0.8 + itemY * 1.4, // 上から落下
                          ),
                          child: Text(
                            isCurveBall ? '⚾💨' : '⚾', 
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        // グローブ
                        Align(
                          alignment: Alignment(
                            colX[basketCol], // 左右位置
                            0.7, // 下側
                          ),
                          child: const Text('🧤', style: TextStyle(fontSize: 32)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isGameOver)
              Positioned.fill(
                child: GameOverOverlay(
                  score: score,
                  onRestart: _restartGame,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
