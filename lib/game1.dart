import 'dart:async'; // ← Timer を使うため
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
  double itemY = 0.0; // アイテム落下位置
  late Timer timer; // タイマー

  @override
  void initState() {
    super.initState();
    _resetItem();
    timer = Timer.periodic(const Duration(milliseconds: 16), _update);
  }

  void _update(Timer t) {
    setState(() {
      itemY += 0.01; // 一定速度で落下
      if (itemY >= 1.0) {
        _resetItem();
      }
    });
  }

  void _resetItem() {
    itemY = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                        0.0,                // 中央（固定）
                        -0.8 + itemY * 1.4, // 上から下へ
                      ),
                      child: const Text('🍎', style: TextStyle(fontSize: 32)),
                    ),
                    // カゴ（固定）
                    const Align(
                      alignment: Alignment(
                        0.0, // 中央
                        0.7, // 下側
                      ),
                      child: Text('🧺', style: TextStyle(fontSize: 32)),
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
