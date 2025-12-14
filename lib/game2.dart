import 'dart:async';
import 'dart:math'; // ← 乱数を使えるように
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
  static const int cols = 2; // 横移動カラム数
  static const List<double> colX = [-0.5, 0.5]; // -1～1の間で均等に

  int basketCol = 0;
  int itemCol = 0;
  double itemY = 0.0;
  int score = 0;

  late Timer timer;
  final Random rand = Random();

  @override
  void initState() {
    super.initState();
    itemCol = rand.nextInt(cols);
    timer = Timer.periodic(const Duration(milliseconds: 16), _update);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _update(Timer t) {
    setState(() {
      itemY += 0.01;
      if (itemY >= 1.0) {
        if (itemCol == basketCol) {
          score++;
        }
        _resetItem();
      }
    });
  }

  void _resetItem() {
    itemY = 0.0;
    itemCol = rand.nextInt(cols);
  }

  void _onTap() {
    setState(() {
      basketCol = 1 - basketCol; // 0 ↔ 1
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap, // タップしたときの処理
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
                        -0.8 + itemY * 1.4, // 上から下へ
                      ),
                      child: const Text(
                        '🍎',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                    // カゴ（左右に移動）
                    Align(
                      alignment: Alignment(
                        colX[basketCol], // 左右位置
                        0.7, // 下側
                      ),
                      child: const Text(
                        '🧺',
                        style: TextStyle(fontSize: 32),
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
