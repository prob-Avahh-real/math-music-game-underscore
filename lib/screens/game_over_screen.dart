import 'package:flutter/material.dart';
import '../models/game_types.dart';
import '../utils/audio_engine.dart';

class GameOverScreen extends StatelessWidget {
  final GameStats stats;
  final Difficulty difficulty;
  final int problemCount;
  final int maxProblems;
  final void Function(Difficulty) onRestart;
  final VoidCallback onHome;
  const GameOverScreen({
    super.key,
    required this.stats,
    required this.difficulty,
    required this.problemCount,
    required this.maxProblems,
    required this.onRestart,
    required this.onHome,
  });

  int get accuracy => problemCount > 0
      ? ((stats.correct / (stats.totalPlayed - (maxProblems - problemCount)).clamp(1, 999)) * 100).round()
      : 0;

  bool get isWin => problemCount >= maxProblems;
  bool get isHighScore => stats.score >= stats.highScore && stats.score > 0;

  void _handleRestart(Difficulty diff) {
    playClick();
    Future.delayed(const Duration(milliseconds: 200), () {
      playSequence([0, 2, 4, 5, 7]);
    });
    Future.delayed(const Duration(milliseconds: 600), () => onRestart(diff));
  }

  void _handleHome() {
    playClick();
    onHome();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 56),
          Text(isWin ? '🏆' : accuracy >= 70 ? '🎹' : '💫', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(isWin ? '演奏完成！' : '游戏结束',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD4A574))),
          const SizedBox(height: 8),
          Text(
            isWin ? '你完成了一首数学的乐章' : accuracy >= 70 ? '不错的表现，继续加油' : '再接再厉，数学之美在等待',
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4)),
          ),
          const SizedBox(height: 32),

          // 统计面板
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('得分', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    Row(
                      children: [
                        Text('${stats.score}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD4A574))),
                        if (isHighScore) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('新纪录！', style: TextStyle(fontSize: 11, color: Colors.amber)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.white.withOpacity(0.05)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statCell('正确率', '$accuracy%'),
                    _statCell('最佳连击', '${stats.bestStreak}x'),
                    _statCell('答对', '${stats.correct}'),
                    _statCell('难度', difficulty.label),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          _bigButton('再来一局 (${difficulty.label})', () => _handleRestart(difficulty)),
          const SizedBox(height: 10),

          Row(
            children: Difficulty.values
                .where((d) => d != difficulty)
                .map((d) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => _handleRestart(d),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3460).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.1)),
                            ),
                            child: Text(d.label, textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _handleHome,
            child: Text('返回首页', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.3))),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _bigButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4A574),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFFD4A574).withOpacity(0.2), blurRadius: 16)],
        ),
        child: Text(text, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
      ),
    );
  }
}
