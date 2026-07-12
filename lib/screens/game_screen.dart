import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_types.dart';
import '../utils/problem_generator.dart';
import '../utils/audio_engine.dart';
import '../utils/storage.dart';
import '../widgets/score_bar.dart';
import '../widgets/problem_card.dart';
import '../widgets/number_pad.dart';
import 'welcome_screen.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GamePhase _phase = GamePhase.welcome;
  Difficulty _difficulty = Difficulty.easy;
  GameStats _stats = GameStats.empty();
  MathProblem? _problem;
  String _answer = '';
  int _problemCount = 0;
  static const _maxProblems = 15;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final s = await loadStats();
    setState(() => _stats = s);
  }

  void _startGame(Difficulty diff) {
    setState(() {
      _difficulty = diff;
      _phase = GamePhase.playing;
      _problemCount = 0;
      _stats = _stats.copyWith(streak: 0);
    });
    _nextProblem();
  }

  void _nextProblem() {
    final p = generateProblem(_difficulty);
    setState(() {
      _problem = p;
      _answer = '';
      _phase = GamePhase.playing;
    });
    // 演奏题目数字
    Future.delayed(const Duration(milliseconds: 300), () {
      playSequence(p.digits);
    });
  }

  void _onDigit(int digit) {
    if (_phase != GamePhase.playing) return;
    playDigit(digit);
    setState(() {
      if (_answer.length < 8) {
        _answer += digit.toString();
      }
    });
  }

  void _onDelete() {
    if (_phase != GamePhase.playing) return;
    playClick();
    setState(() {
      if (_answer.isNotEmpty) {
        _answer = _answer.substring(0, _answer.length - 1);
      }
    });
  }

  Future<void> _onSubmit() async {
    if (_phase != GamePhase.playing || _problem == null || _answer.isEmpty) return;

    final isCorrect = int.tryParse(_answer) == _problem!.answer;

    if (isCorrect) {
      setState(() => _phase = GamePhase.correct);
      await playCorrect();

      final updated = await recordAnswer(_stats, _difficulty, true, _difficulty.points);
      final nextCount = _problemCount + 1;

      if (!mounted) return;
      setState(() {
        _stats = updated;
        _phase = GamePhase.correct;
      });

      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      if (nextCount >= _maxProblems) {
        await playGameOver();
        setState(() {
          _problemCount = nextCount;
          _phase = GamePhase.gameOver;
        });
      } else {
        // 连击升级
        var newDiff = _difficulty;
        if (updated.streak >= 5 && updated.streak % 5 == 0) {
          final next = _difficulty.next;
          if (next != null) {
            newDiff = next;
            await playLevelUp();
          }
        }
        setState(() {
          _problemCount = nextCount;
          _difficulty = newDiff;
        });
        _nextProblem();
      }
    } else {
      setState(() => _phase = GamePhase.wrong);
      await playWrong();

      final updated = await recordAnswer(_stats, _difficulty, false, 0);
      if (!mounted) return;
      setState(() {
        _stats = updated;
        _phase = GamePhase.wrong;
      });

      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      await playGameOver();
      setState(() => _phase = GamePhase.gameOver);
    }
  }

  void _goHome() {
    setState(() => _phase = GamePhase.welcome);
  }

  @override
  void dispose() {
    disposeAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case GamePhase.welcome:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          highScore: _stats.highScore,
          onStart: _startGame,
        );

      case GamePhase.playing:
      case GamePhase.correct:
      case GamePhase.wrong:
        return _buildGameBody();

      case GamePhase.gameOver:
        return GameOverScreen(
          key: const ValueKey('gameover'),
          stats: _stats,
          difficulty: _difficulty,
          problemCount: _problemCount,
          maxProblems: _maxProblems,
          onRestart: _startGame,
          onHome: _goHome,
        );
    }
  }

  Widget _buildGameBody() {
    if (_problem == null) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // 顶部统计栏
        ScoreBar(
          stats: _stats,
          difficulty: _difficulty,
          problemCount: _problemCount,
          maxProblems: _maxProblems,
          streak: _stats.streak,
        ),

        // 题目区
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ProblemCard(
                  problem: _problem!,
                  answer: _answer,
                  feedback: _phase == GamePhase.correct
                      ? FeedbackType.correct
                      : _phase == GamePhase.wrong
                          ? FeedbackType.wrong
                          : FeedbackType.none,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // 数字键盘
        NumberPad(
          onDigit: _onDigit,
          onDelete: _onDelete,
          onSubmit: _onSubmit,
          disabled: _phase != GamePhase.playing,
          hasAnswer: _answer.isNotEmpty,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
