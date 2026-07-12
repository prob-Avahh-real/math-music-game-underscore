/// SharedPreferences 封装 — 游戏数据持久化
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_types.dart';

const _key = 'math_music_stats';
const _highKey = 'math_music_high';

Future<GameStats> loadStats() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_key);
  if (raw == null) return GameStats.empty();

  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final byDiff = <Difficulty, _DiffStats>{};
    if (map['byDifficulty'] != null) {
      final bd = map['byDifficulty'] as Map<String, dynamic>;
      for (final e in bd.entries) {
        final d = Difficulty.values.firstWhere((d) => d.name == e.key);
        final v = e.value as Map<String, dynamic>;
        byDiff[d] = _DiffStats(played: v['played'] ?? 0, correct: v['correct'] ?? 0);
      }
    }
    // Fill missing
    for (final d in Difficulty.values) {
      byDiff.putIfAbsent(d, () => const _DiffStats(played: 0, correct: 0));
    }

    return GameStats(
      totalPlayed: map['totalPlayed'] ?? 0,
      correct: map['correct'] ?? 0,
      streak: map['streak'] ?? 0,
      bestStreak: map['bestStreak'] ?? 0,
      score: map['score'] ?? 0,
      highScore: map['highScore'] ?? 0,
      byDifficulty: byDiff,
    );
  } catch (_) {
    return GameStats.empty();
  }
}

Future<void> saveStats(GameStats stats) async {
  final prefs = await SharedPreferences.getInstance();
  final map = {
    'totalPlayed': stats.totalPlayed,
    'correct': stats.correct,
    'streak': stats.streak,
    'bestStreak': stats.bestStreak,
    'score': stats.score,
    'highScore': stats.highScore,
    'byDifficulty': {
      for (final e in stats.byDifficulty.entries)
        e.key.name: {'played': e.value.played, 'correct': e.value.correct},
    },
  };
  await prefs.setString(_key, jsonEncode(map));
}

Future<void> saveHighScore(int score) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_highKey, score);
}

/// 记录答题，返回更新后的统计
Future<GameStats> recordAnswer(GameStats stats, Difficulty diff, bool correct, int points) async {
  final diffStats = stats.byDifficulty[diff]!;
  final newStreak = correct ? stats.streak + 1 : 0;
  final newBestStreak = correct ? max(stats.bestStreak, newStreak) : stats.bestStreak;
  final newScore = stats.score + (correct ? points + (stats.streak ~/ 3) * 5 : 0);

  final updated = stats.copyWith(
    totalPlayed: stats.totalPlayed + 1,
    correct: stats.correct + (correct ? 1 : 0),
    streak: newStreak,
    bestStreak: newBestStreak,
    score: newScore,
    highScore: max(stats.highScore, newScore),
    byDifficulty: {
      ...stats.byDifficulty,
      diff: _DiffStats(played: diffStats.played + 1, correct: diffStats.correct + (correct ? 1 : 0)),
    },
  );

  await saveStats(updated);
  return updated;
}

class _DiffStats {
  final int played;
  final int correct;
  const _DiffStats({required this.played, required this.correct});
}
