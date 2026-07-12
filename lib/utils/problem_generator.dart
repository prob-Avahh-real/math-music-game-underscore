/// 数学题库生成器 — Dart 移植
import 'dart:math';
import '../models/game_types.dart';

final _rng = Random();
int _idCounter = 0;

int _randInt(int min, int max) => min + _rng.nextInt(max - min + 1);
String _uid() => 'p_${DateTime.now().millisecondsSinceEpoch}_${++_idCounter}';

List<int> _digitsOf(int n) =>
    n.abs().toString().split('').map(int.parse).toList();

// ── 题型生成 ──

MathProblem _genArithmetic(Difficulty diff) {
  final (lo, hi) = switch (diff) {
    Difficulty.easy   => (1, 30),
    Difficulty.medium => (1, 100),
    Difficulty.hard   => (10, 500),
    Difficulty.genius => (50, 9999),
  };

  final ops = diff == Difficulty.easy
      ? ['+', '-']
      : diff == Difficulty.medium
          ? ['+', '-', '×']
          : ['+', '-', '×', '÷'];
  final op = ops[_randInt(0, ops.length - 1)];

  int a, b, answer;
  String display;

  switch (op) {
    case '+':
      a = _randInt(lo, hi);
      b = _randInt(lo, hi);
      answer = a + b;
      display = '$a + $b = ?';
    case '-':
      a = _randInt(lo, hi);
      b = _randInt(lo, a);
      answer = a - b;
      display = '$a − $b = ?';
    case '×':
      a = _randInt(lo, diff == Difficulty.genius ? 200 : 50);
      b = _randInt(2, diff == Difficulty.genius ? 99 : 12);
      answer = a * b;
      display = '$a × $b = ?';
    case '÷':
      b = _randInt(2, diff == Difficulty.genius ? 50 : 12);
      answer = _randInt(1, diff == Difficulty.genius ? 200 : 30);
      a = b * answer;
      display = '$a ÷ $b = ?';
    default:
      a = _randInt(lo, hi);
      b = _randInt(lo, hi);
      answer = a + b;
      display = '$a + $b = ?';
  }

  return MathProblem(
    id: _uid(), type: ProblemType.arithmetic, difficulty: diff,
    display: display, answer: answer,
    explanation: '直接计算: ${display.replaceAll('?', answer.toString())}',
    digits: [..._digitsOf(a), ..._digitsOf(b)],
  );
}

MathProblem _genSequence(Difficulty diff) {
  final patterns = <Difficulty, List<int>>{
    Difficulty.easy:   [1, 3, 5, 7, 9],
    Difficulty.medium: [2, 7, 12, 17, 22],
    Difficulty.hard:   [3, 9, 27, 81, 243],
    Difficulty.genius: [1, 1, 2, 3, 5, 8],
  };

  final seq = patterns[diff]!;
  final answer = seq.last;
  final display = '${seq.sublist(0, seq.length - 1).join(', ')}, ?';

  return MathProblem(
    id: _uid(), type: ProblemType.sequence, difficulty: diff,
    display: display, answer: answer,
    explanation: '观察规律，下一项是 $answer',
    digits: _digitsOf(answer),
  );
}

MathProblem _genMissingDigit(Difficulty diff) {
  final max = switch (diff) {
    Difficulty.easy => 20, Difficulty.medium => 100,
    Difficulty.hard => 500, Difficulty.genius => 2000,
  };
  final a = _randInt(10, max);
  final b = _randInt(10, max);
  final isAdd = _rng.nextBool();
  final result = isAdd ? a + b : a - b;

  final aStr = a.toString();
  final pos = _randInt(0, aStr.length - 1);
  final answer = int.parse(aStr[pos]);
  final masked = '${aStr.substring(0, pos)}?${aStr.substring(pos + 1)}';

  final display = isAdd ? '$masked + $b = $result' : '$masked − $b = $result';

  return MathProblem(
    id: _uid(), type: ProblemType.missingDigit, difficulty: diff,
    display: display, answer: answer,
    explanation: '${isAdd ? '+' : '−'}反推: ? = $answer',
    digits: [..._digitsOf(a), ..._digitsOf(b), ..._digitsOf(result)],
  );
}

MathProblem _genModular(Difficulty diff) {
  final mod = switch (diff) {
    Difficulty.easy => 7, Difficulty.medium => 12,
    Difficulty.hard => 31, Difficulty.genius => 97,
  };
  final maxVal = switch (diff) {
    Difficulty.easy => 30, Difficulty.medium => 100,
    Difficulty.hard => 200, Difficulty.genius => 1000,
  };
  final a = _randInt(10, maxVal);
  final answer = a % mod;

  return MathProblem(
    id: _uid(), type: ProblemType.modular, difficulty: diff,
    display: '$a mod $mod = ?', answer: answer,
    explanation: '$a ÷ $mod = ${a ~/ mod} 余 $answer',
    digits: [..._digitsOf(a), ..._digitsOf(mod)],
  );
}

MathProblem _genDigitSum(Difficulty diff) {
  final (minLen, maxLen) = switch (diff) {
    Difficulty.easy => (2, 3), Difficulty.medium => (3, 4),
    Difficulty.hard => (4, 5), Difficulty.genius => (5, 8),
  };
  final len = _randInt(minLen, maxLen);
  var numStr = '';
  for (int i = 0; i < len; i++) {
    numStr += _randInt(i == 0 ? 1 : 0, 9).toString();
  }
  final numInt = int.parse(numStr);
  final answer = _digitsOf(numInt).reduce((a, b) => a + b);

  return MathProblem(
    id: _uid(), type: ProblemType.digitSum, difficulty: diff,
    display: '$numStr 的各位数字之和 = ?', answer: answer,
    explanation: '${_digitsOf(numInt).join(" + ")} = $answer',
    digits: _digitsOf(numInt),
  );
}

MathProblem _genPrime(Difficulty diff) {
  final maxCheck = switch (diff) {
    Difficulty.easy => 30, Difficulty.medium => 100,
    Difficulty.hard => 500, Difficulty.genius => 2000,
  };

  final n = _randInt(2, maxCheck);
  final answer = _isPrime(n) ? 1 : 0;

  return MathProblem(
    id: _uid(), type: ProblemType.prime, difficulty: diff,
    display: '$n 是质数吗？(是=1, 否=0)', answer: answer,
    explanation: _isPrime(n) ? '$n 是质数' : '$n = ${_factorizeStr(n)}，不是质数',
    digits: _digitsOf(n),
  );
}

MathProblem _genFactor(Difficulty diff) {
  final maxN = switch (diff) {
    Difficulty.easy => 36, Difficulty.medium => 144,
    Difficulty.hard => 500, Difficulty.genius => 2000,
  };
  final n = _randInt(6, maxN);
  final factors = _getFactors(n);
  final answer = factors.length;

  return MathProblem(
    id: _uid(), type: ProblemType.factor, difficulty: diff,
    display: '$n 有几个正因数？', answer: answer,
    explanation: '因数: ${factors.join(", ")}, 共 $answer 个',
    digits: _digitsOf(n),
  );
}

MathProblem _genEquation(Difficulty diff) {
  final (lo, hi) = switch (diff) {
    Difficulty.easy   => (1, 20),
    Difficulty.medium => (1, 50),
    Difficulty.hard   => (1, 100),
    Difficulty.genius => (1, 500),
  };
  final x = _randInt(lo, hi);
  final variant = _randInt(0, 2);

  String display;
  int answer;

  switch (variant) {
    case 0:
      final a = _randInt(lo, hi);
      final b = 2 * x + a;
      display = '2x + $a = $b，x = ?';
      answer = x;
    case 1:
      final a = _randInt(lo, hi);
      final b = 3 * x - a;
      display = '3x − $a = $b，x = ?';
      answer = x;
    default:
      final n = x * x;
      display = 'x² = $n，x = ?';
      answer = x;
  }

  return MathProblem(
    id: _uid(), type: ProblemType.equation, difficulty: diff,
    display: display, answer: answer,
    explanation: display.replaceAll('?', answer.toString()),
    digits: _digitsOf(answer),
  );
}

MathProblem _genPattern(Difficulty diff) {
  final patterns = [
    ('1+1=2\n2+2=4\n4+4=8\n8+8=?', 16, '每次翻倍'),
    ('1×1=1\n11×11=121\n111×111=12321\n1111×1111=?', 1234321, '回文模式'),
    ('2¹=2\n2²=4\n2³=8\n2⁴=?', 16, '2的幂'),
    ('1³=1\n2³=8\n3³=27\n4³=?', 64, '立方数'),
  ];
  final p = patterns[_randInt(0, min(patterns.length - 1, diff.index + 1))];

  return MathProblem(
    id: _uid(), type: ProblemType.pattern, difficulty: diff,
    display: p.$1, answer: p.$2, explanation: p.$3,
    digits: _digitsOf(p.$2),
  );
}

MathProblem _genLogic(Difficulty diff) {
  final puzzles = [
    ('鸡兔同笼，头10个脚28只。鸡几只？', 6, '设鸡x，兔(10-x)，2x+4(10-x)=28'),
    ('十位是个位2倍，和为9。这个数？', 63, '设个位x，2x+x=9，x=3→63'),
    ('找规律: 1,4,9,16,25,?', 36, '平方: 1²,2²,3²,4²,5²,6²'),
    ('找规律: 2,3,5,7,11,?', 13, '连续质数'),
    ('12年前爷爷年龄是小明7倍，小明12爷爷72。几年前？', 2, '(72-x)=7(12-x), x=2'),
  ];
  final start = diff.index < 2 ? 0 : diff.index;
  final end = min(puzzles.length, start + 3);
  final p = puzzles[_randInt(start, end - 1)];

  return MathProblem(
    id: _uid(), type: ProblemType.logic, difficulty: diff,
    display: p.$1, answer: p.$2, explanation: p.$3,
    digits: _digitsOf(p.$2),
  );
}

// ── 辅助 ──

bool _isPrime(int n) {
  if (n < 2) return false;
  if (n < 4) return true;
  if (n % 2 == 0 || n % 3 == 0) return false;
  for (int i = 5; i * i <= n; i += 6) {
    if (n % i == 0 || n % (i + 2) == 0) return false;
  }
  return true;
}

List<int> _factorize(int n) {
  final f = <int>[];
  var m = n;
  for (int i = 2; i * i <= m; i++) {
    while (m % i == 0) { f.add(i); m ~/= i; }
  }
  if (m > 1) f.add(m);
  return f;
}

String _factorizeStr(int n) => _factorize(n).join(' × ');

List<int> _getFactors(int n) {
  final f = <int>[];
  for (int i = 1; i * i <= n; i++) {
    if (n % i == 0) {
      f.add(i);
      if (i != n ~/ i) f.add(n ~/ i);
    }
  }
  f.sort();
  return f;
}

// ── 公开 API ──

typedef GenFn = MathProblem Function(Difficulty);

const Map<ProblemType, GenFn> generators = {
  ProblemType.arithmetic: _genArithmetic,
  ProblemType.sequence: _genSequence,
  ProblemType.missingDigit: _genMissingDigit,
  ProblemType.modular: _genModular,
  ProblemType.digitSum: _genDigitSum,
  ProblemType.prime: _genPrime,
  ProblemType.factor: _genFactor,
  ProblemType.equation: _genEquation,
  ProblemType.pattern: _genPattern,
  ProblemType.logic: _genLogic,
};

MathProblem generateProblem(Difficulty diff) {
  final pool = switch (diff) {
    Difficulty.easy => [
      ProblemType.arithmetic, ProblemType.arithmetic,
      ProblemType.sequence, ProblemType.missingDigit,
      ProblemType.pattern, ProblemType.logic,
    ],
    Difficulty.medium => [
      ProblemType.arithmetic, ProblemType.sequence,
      ProblemType.missingDigit, ProblemType.modular,
      ProblemType.digitSum, ProblemType.equation,
      ProblemType.pattern, ProblemType.logic, ProblemType.prime,
    ],
    Difficulty.hard => [
      ProblemType.sequence, ProblemType.modular,
      ProblemType.digitSum, ProblemType.prime,
      ProblemType.factor, ProblemType.equation,
      ProblemType.pattern, ProblemType.logic,
    ],
    Difficulty.genius => [
      ProblemType.sequence, ProblemType.modular,
      ProblemType.prime, ProblemType.factor,
      ProblemType.equation, ProblemType.pattern,
      ProblemType.logic, ProblemType.digitSum,
    ],
  };
  final type = pool[_randInt(0, pool.length - 1)];
  return generators[type]!(diff);
}
