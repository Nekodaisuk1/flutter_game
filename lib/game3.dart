import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
  static const int cols = 3; // カラム3に変更
  static const List<double> colX = [-0.6, 0.0, 0.6]; // -1～1の間で均等に

  late int basketCol;
  late bool movingRight;
  late int itemCol;
  late double itemY;
  late double itemVy;
  late double gravity;
  late int score;

  late Timer timer;
  final Random rand = Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    basketCol = 1; // 中央カラム（0,1,2 のうち真ん中の1）
    movingRight = true;
    itemCol = rand.nextInt(cols);
    itemY = 0.0;
    itemVy = 0.0;
    gravity = 0.8;
    score = 0;
    timer = Timer.periodic(const Duration(milliseconds: 16), _update);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _update(Timer t) {
    setState(() {
      const dt = 0.016;
      // 重力落下
      itemVy += gravity * dt;
      itemY += itemVy * dt;
      if (itemY >= 1.0) {
        final caught = (itemCol == basketCol);
        _resetItem(caught);
      }
    });
  }

  void _resetItem(bool caught) {
    if (caught) {
      score++;
      gravity = min(gravity + 0.1, 2.0); // 少しずつ重力アップ
    } else {
      // ミスしてもゲームオーバーなしでそのまま続行
    }
    // 次のりんごを一番上から落とす
    itemY = 0.0;
    itemVy = 0.0;
    itemCol = rand.nextInt(cols);
  }

  void _onTap() {
    setState(() {
      basketCol++;
      if (basketCol == cols) {
        basketCol = 0; // 右端を超えたら左端に
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
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🍎 収穫ゲーム 🍎',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('スコア：$score'),
              Text('レベル：$level  g=${gravity.toStringAsFixed(2)}'),
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
                    // 落ちてくるリンゴ（アニメーション）
                    Align(
                      alignment: Alignment(
                        colX[itemCol],      // 左右位置
                        -0.8 + itemY * 1.4, // 上から落下
                      ),
                      child: const Text('🍎', style: TextStyle(fontSize: 32)),
                    ),
                    // カゴ
                    Align(
                      alignment: Alignment(
                        colX[basketCol], // 左右位置
                        0.7, // 下側
                      ),
                      child: const Text('🧺', style: TextStyle(fontSize: 32)),
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
