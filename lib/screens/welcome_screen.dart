import 'package:flutter/material.dart';
import '../models/game_types.dart';
import '../utils/audio_engine.dart';

class WelcomeScreen extends StatefulWidget {
  final int highScore;
  final void Function(Difficulty) onStart;
  const WelcomeScreen({super.key, required this.highScore, required this.onStart});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Difficulty _selected = Difficulty.easy;

  static const _descs = {
    Difficulty.easy: '基础算术与简单规律',
    Difficulty.medium: '进阶推理与模运算',
    Difficulty.hard: '质数、数列与方程',
    Difficulty.genius: 'Wolfram 级挑战',
  };

  static const _colors = {
    Difficulty.easy: Color(0xFF059669),
    Difficulty.medium: Color(0xFFD97706),
    Difficulty.hard: Color(0xFFDC2626),
    Difficulty.genius: Color(0xFF7C3AED),
  };

  void _handleStart() {
    playClick();
    Future.delayed(const Duration(milliseconds: 200), () {
      playSequence([0, 2, 4, 7]);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      widget.onStart(_selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          // 标题
          const Text('🎵', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          const Text('数律华章',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFD4A574)),
          ),
          const SizedBox(height: 4),
          Text('MATH & MUSIC',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4), letterSpacing: 4),
          ),
          const SizedBox(height: 8),
          Container(width: 60, height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, const Color(0xFFD4A574).withOpacity(0.5), Colors.transparent]),
            ),
          ),
          const SizedBox(height: 8),
          Text('数字即音符 · 解题如奏乐',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3)),
          ),
          const SizedBox(height: 32),

          // 钢琴预览
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(10, (i) {
              final isWhite = i == 0 || i == 1 || i == 3 || i == 4 || i == 5;
              return GestureDetector(
                onTap: () => playDigit(i),
                child: Container(
                  width: 32, height: isWhite ? 64 : 56,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isWhite ? const Color(0xFFF8F4E6) : const Color(0xFF1A1A2E),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                    border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.2)),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      Text('$i', style: TextStyle(fontSize: 10, color: isWhite ? const Color(0xFF1A1A2E) : const Color(0xFFF8F4E6))),
                      Text(noteMap[i]!.noteName, style: TextStyle(fontSize: 7, color: (isWhite ? const Color(0xFF1A1A2E) : const Color(0xFFF8F4E6)).withOpacity(0.5))),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),

          // 难度选择
          ...Difficulty.values.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selected = d);
                playClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_colors[d]!, _colors[d]!.withOpacity(0.6)],
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: _selected == d
                      ? Border.all(color: const Color(0xFFD4A574), width: 2)
                      : null,
                  boxShadow: _selected == d
                      ? [BoxShadow(color: _colors[d]!.withOpacity(0.3), blurRadius: 12)] : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          Text(_descs[d]!, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                        ],
                      ),
                    ),
                    if (_selected == d)
                      const Icon(Icons.check_circle, color: Color(0xFFD4A574), size: 22),
                  ],
                ),
              ),
            ),
          )),
          const SizedBox(height: 20),

          // 开始按钮
          GestureDetector(
            onTap: _handleStart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A574),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: const Color(0xFFD4A574).withOpacity(0.3), blurRadius: 16)],
              ),
              child: const Center(
                child: Text('开始演奏', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              ),
            ),
          ),
          if (widget.highScore > 0) ...[
            const SizedBox(height: 16),
            Text('最高分: ${widget.highScore}',
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
