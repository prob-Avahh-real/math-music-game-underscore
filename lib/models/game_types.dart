/// 数律华章 — 核心类型定义

enum ProblemType {
  arithmetic,    // 算数
  sequence,      // 数列
  missingDigit,  // 缺位
  modular,       // 模运算
  digitSum,      // 数位和
  prime,         // 质数
  factor,        // 因数
  equation,      // 方程
  pattern,       // 模式
  logic,         // 逻辑
}

extension ProblemTypeExt on ProblemType {
  String get label {
    switch (this) {
      case ProblemType.arithmetic: return '算数';
      case ProblemType.sequence:   return '数列';
      case ProblemType.missingDigit: return '缺位';
      case ProblemType.modular:    return '模运算';
      case ProblemType.digitSum:   return '数位和';
      case ProblemType.prime:      return '质数';
      case ProblemType.factor:     return '因数';
      case ProblemType.equation:   return '方程';
      case ProblemType.pattern:    return '模式';
      case ProblemType.logic:      return '逻辑';
    }
  }
}

enum Difficulty {
  easy,    // 入门
  medium,  // 进阶
  hard,    // 困难
  genius,  // 天才
}

extension DifficultyExt on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:   return '入门';
      case Difficulty.medium: return '进阶';
      case Difficulty.hard:   return '困难';
      case Difficulty.genius: return '天才';
    }
  }

  int get points {
    switch (this) {
      case Difficulty.easy:   return 10;
      case Difficulty.medium: return 25;
      case Difficulty.hard:   return 50;
      case Difficulty.genius: return 100;
    }
  }

  Difficulty? get next {
    switch (this) {
      case Difficulty.easy:   return Difficulty.medium;
      case Difficulty.medium: return Difficulty.hard;
      case Difficulty.hard:   return Difficulty.genius;
      case Difficulty.genius: return null;
    }
  }
}

class MathProblem {
  final String id;
  final ProblemType type;
  final Difficulty difficulty;
  final String display;
  final int answer;
  final String? hint;
  final String explanation;
  final List<int> digits; // 用于旋律演奏

  const MathProblem({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.display,
    required this.answer,
    this.hint,
    required this.explanation,
    required this.digits,
  });
}

enum GamePhase { welcome, playing, correct, wrong, gameOver }

class GameStats {
  final int totalPlayed;
  final int correct;
  final int streak;
  final int bestStreak;
  final int score;
  final int highScore;
  final Map<Difficulty, _DiffStats> byDifficulty;

  const GameStats({
    required this.totalPlayed,
    required this.correct,
    required this.streak,
    required this.bestStreak,
    required this.score,
    required this.highScore,
    required this.byDifficulty,
  });

  static GameStats empty() => GameStats(
    totalPlayed: 0,
    correct: 0,
    streak: 0,
    bestStreak: 0,
    score: 0,
    highScore: 0,
    byDifficulty: {
      for (var d in Difficulty.values) d: const _DiffStats(played: 0, correct: 0),
    },
  );

  GameStats copyWith({
    int? totalPlayed,
    int? correct,
    int? streak,
    int? bestStreak,
    int? score,
    int? highScore,
    Map<Difficulty, _DiffStats>? byDifficulty,
  }) {
    return GameStats(
      totalPlayed: totalPlayed ?? this.totalPlayed,
      correct: correct ?? this.correct,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      byDifficulty: byDifficulty ?? this.byDifficulty,
    );
  }
}

class _DiffStats {
  final int played;
  final int correct;
  const _DiffStats({required this.played, required this.correct});
}
