import 'package:flutter/material.dart';
import '../utils/audio_engine.dart';

class NumberPad extends StatelessWidget {
  final void Function(int) onDigit;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;
  final bool disabled;
  final bool hasAnswer;

  const NumberPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onSubmit,
    required this.disabled,
    required this.hasAnswer,
  });

  static const _keyStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const _noteStyle = TextStyle(fontSize: 9);
  static const _labelStyle = TextStyle(fontSize: 8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // 7 8 9
          _row([7, 8, 9]),
          const SizedBox(height: 6),
          // 4 5 6
          _row([4, 5, 6]),
          const SizedBox(height: 6),
          // 1 2 3
          _row([1, 2, 3]),
          const SizedBox(height: 6),
          // 0, del, submit
          Row(
            children: [
              _keyButton(0),
              const SizedBox(width: 6),
              Expanded(
                child: _actionButton(
                  '⌫', onDelete, disabled,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _actionButton(
                  '确定', onSubmit, disabled || !hasAnswer,
                  color: hasAnswer && !disabled
                      ? const Color(0xFFD4A574)
                      : const Color(0xFFD4A574).withOpacity(0.2),
                  textColor: hasAnswer && !disabled
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFFD4A574).withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('轻触数字键盘，每个数字都有对应的音符',
            style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.12))),
        ],
      ),
    );
  }

  Widget _row(List<int> digits) {
    return Row(
      children: digits.map((d) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: d != digits.last ? 6 : 0,
          ),
          child: _keyButton(d),
        ),
      )).toList(),
    );
  }

  Widget _keyButton(int digit) {
    final note = noteMap[digit];
    return GestureDetector(
      onTap: disabled ? null : () => onDigit(digit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A2A4A), Color(0xFF1A1A2E)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.25)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$digit', style: _keyStyle.copyWith(color: disabled ? Colors.white24 : const Color(0xFFF8F4E6))),
            if (note != null) ...[
              const SizedBox(height: 1),
              Text(note.noteName, style: _noteStyle.copyWith(color: disabled ? Colors.white10 : Colors.white30)),
              Text(note.label, style: _labelStyle.copyWith(color: disabled ? Colors.white10 : Colors.white24)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onTap, bool disabled, {Color? color, Color? textColor}) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 64,
        decoration: BoxDecoration(
          color: color ?? Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.15)),
        ),
        child: Center(
          child: Text(text,
            style: TextStyle(
              fontSize: text == '确定' ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: textColor ?? (disabled ? Colors.white24 : Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}
