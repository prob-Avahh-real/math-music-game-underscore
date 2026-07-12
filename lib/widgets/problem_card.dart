import 'package:flutter/material.dart';
import '../models/game_types.dart';

enum FeedbackType { none, correct, wrong }

class ProblemCard extends StatelessWidget {
  final MathProblem problem;
  final String answer;
  final FeedbackType feedback;
  const ProblemCard({
    super.key,
    required this.problem,
    required this.answer,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = feedback == FeedbackType.correct
        ? Colors.greenAccent.withOpacity(0.3)
        : feedback == FeedbackType.wrong
            ? Colors.redAccent.withOpacity(0.3)
            : const Color(0xFFD4A574).withOpacity(0.2);

    final bgColor = feedback == FeedbackType.correct
        ? Colors.green.withOpacity(0.05)
        : feedback == FeedbackType.wrong
            ? Colors.red.withOpacity(0.05)
            : Colors.white.withOpacity(0.02);

    return Column(
      children: [
        const SizedBox(height: 8),
        // 标签行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3460).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.2)),
              ),
              child: Text(problem.type.label, style: const TextStyle(fontSize: 11, color: Color(0xFFE8C170))),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A574).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(problem.difficulty.label,
                style: TextStyle(fontSize: 11, color: const Color(0xFFD4A574).withOpacity(0.7))),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 题目卡片
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.08)),
          ),
          child: Text(problem.display,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, height: 1.6, color: Color(0xFFF8F4E6))),
        ),
        const SizedBox(height: 16),

        // 答案显示区
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: feedback == FeedbackType.none ? 1 : 1.5),
            boxShadow: feedback != FeedbackType.none
                ? [BoxShadow(color: feedback == FeedbackType.correct ? Colors.greenAccent.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15), blurRadius: 16)]
                : null,
          ),
          child: answer.isNotEmpty
              ? Text(answer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A574), letterSpacing: 6))
              : Text(
                  feedback == FeedbackType.none ? '输入答案...' : '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.15)),
                ),
        ),

        // 反馈信息
        if (feedback == FeedbackType.correct) ...[
          const SizedBox(height: 12),
          Text('✓ 正确！+${problem.difficulty.points} 分',
            style: const TextStyle(fontSize: 15, color: Colors.greenAccent, fontWeight: FontWeight.w500)),
        ],
        if (feedback == FeedbackType.wrong) ...[
          const SizedBox(height: 12),
          Text('✗ 答案是 ${problem.answer}',
            style: const TextStyle(fontSize: 15, color: Colors.redAccent)),
          const SizedBox(height: 4),
          Text(problem.explanation,
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3)),
            textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
