import 'package:flutter/material.dart';
import '../models/game_types.dart';

class ScoreBar extends StatelessWidget {
  final GameStats stats;
  final Difficulty difficulty;
  final int problemCount;
  final int maxProblems;
  final int streak;
  const ScoreBar({
    super.key,
    required this.stats,
    required this.difficulty,
    required this.problemCount,
    required this.maxProblems,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: problemCount / maxProblems,
              minHeight: 4,
              backgroundColor: const Color(0xFF0F3460).withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
            ),
          ),
          const SizedBox(height: 8),
          // 信息行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('★', style: TextStyle(fontSize: 16, color: Color(0xFFD4A574))),
                  const SizedBox(width: 4),
                  Text('${stats.score}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFD4A574))),
                  if (streak > 1) ...[
                    const SizedBox(width: 12),
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 2),
                    Text('${streak}x',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFB923C))),
                  ],
                ],
              ),
              Row(
                children: [
                  Text('$problemCount/$maxProblems',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3460).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.1)),
                    ),
                    child: Text(difficulty.label,
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
