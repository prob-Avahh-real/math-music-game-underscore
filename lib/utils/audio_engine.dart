/// 音频引擎 — WAV 字节合成 + 数字→音符映射
///
/// C大调基准: 0=C4, 1=D4, 2=E4, 3=F4, 4=G4, 5=A4, 6=B4
///           7=C5(高八度), 8=D5(高一度), 9=E5(高二度)

import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

// ── 频率表 (A4 = 440Hz) ──
const _C4 = 261.63;
const _D4 = 293.66;
const _E4 = 329.63;
const _F4 = 349.23;
const _G4 = 392.00;
const _A4 = 440.00;
const _B4 = 493.88;
const _C5 = 523.25;
const _D5 = 587.33;
const _E5 = 659.25;

/// 音符映射
class NoteInfo {
  final int digit;
  final String noteName;
  final double frequency;
  final int octave;
  final String label;
  const NoteInfo(this.digit, this.noteName, this.frequency, this.octave, this.label);
}

const Map<int, NoteInfo> noteMap = {
  0: NoteInfo(0, 'C4', _C4, 4, 'Do'),
  1: NoteInfo(1, 'D4', _D4, 4, 'Re'),
  2: NoteInfo(2, 'E4', _E4, 4, 'Mi'),
  3: NoteInfo(3, 'F4', _F4, 4, 'Fa'),
  4: NoteInfo(4, 'G4', _G4, 4, 'Sol'),
  5: NoteInfo(5, 'A4', _A4, 4, 'La'),
  6: NoteInfo(6, 'B4', _B4, 4, 'Si'),
  7: NoteInfo(7, 'C5', _C5, 5, 'Do↑'),
  8: NoteInfo(8, 'D5', _D5, 5, 'Re↑'),
  9: NoteInfo(9, 'E5', _E5, 5, 'Mi↑'),
};

// ── WAV 生成 ──
const _sampleRate = 44100;
const _bitsPerSample = 16;
const _numChannels = 1;

/// 生成 WAV 文件字节 (PCM 16-bit mono)
Uint8List _generateWav(List<double> samples) {
  final dataLen = samples.length * (_bitsPerSample ~/ 8);
  final fileLen = 44 + dataLen;
  final buf = ByteData(fileLen);

  // RIFF header
  buf.setUint8(0, 0x52); buf.setUint8(1, 0x49); buf.setUint8(2, 0x46); buf.setUint8(3, 0x46); // "RIFF"
  buf.setUint32(4, fileLen - 8, Endian.little);
  buf.setUint8(8, 0x57); buf.setUint8(9, 0x41); buf.setUint8(10, 0x56); buf.setUint8(11, 0x45); // "WAVE"

  // fmt chunk
  buf.setUint8(12, 0x66); buf.setUint8(13, 0x6D); buf.setUint8(14, 0x74); buf.setUint8(15, 0x20); // "fmt "
  buf.setUint32(16, 16, Endian.little);       // chunk size
  buf.setUint16(20, 1, Endian.little);        // PCM
  buf.setUint16(22, _numChannels, Endian.little);
  buf.setUint32(24, _sampleRate, Endian.little);
  buf.setUint32(28, _sampleRate * _numChannels * (_bitsPerSample ~/ 8), Endian.little); // byte rate
  buf.setUint16(32, _numChannels * (_bitsPerSample ~/ 8), Endian.little);               // block align
  buf.setUint16(34, _bitsPerSample, Endian.little);

  // data chunk
  buf.setUint8(36, 0x64); buf.setUint8(37, 0x61); buf.setUint8(38, 0x74); buf.setUint8(39, 0x61); // "data"
  buf.setUint32(40, dataLen, Endian.little);

  for (int i = 0; i < samples.length; i++) {
    final s = (samples[i] * 32767).clamp(-32768, 32767).toInt();
    buf.setInt16(44 + i * 2, s, Endian.little);
  }

  return buf.buffer.asUint8List();
}

/// 生成正弦波 + ADSR 包络
List<double> _genToneSamples(double freq, double durationSec, double gain,
    {OscillatorType oscType = OscillatorType.sine}) {
  final nSamples = (durationSec * _sampleRate).ceil();
  final samples = List<double>.filled(nSamples, 0.0);
  final attackSamples = (0.02 * _sampleRate).ceil();
  final decayStart = (durationSec * 0.6 * _sampleRate).ceil();

  for (int i = 0; i < nSamples; i++) {
    final t = i / _sampleRate;
    double env;
    if (i < attackSamples) {
      env = i / attackSamples; // attack
    } else if (i < decayStart) {
      env = 0.7 + 0.3 * (1 - (i - attackSamples) / (decayStart - attackSamples)); // decay
    } else {
      env = 0.7 * (1 - (i - decayStart) / (nSamples - decayStart)); // release
    }

    double wave;
    final phase = 2 * pi * freq * t;
    switch (oscType) {
      case OscillatorType.sine:
        wave = sin(phase);
        break;
      case OscillatorType.triangle:
        wave = (2 / pi) * asin(sin(phase));
        break;
      case OscillatorType.sawtooth:
        wave = 2 * (t * freq - (t * freq).floor()) - 1;
        break;
    }

    samples[i] = wave * env * gain;
  }

  return samples;
}

enum OscillatorType { sine, triangle, sawtooth }

// ── 音符缓存 ──
final Map<int, Uint8List> _noteCache = {};
bool _cacheBuilt = false;

void _buildCache() {
  if (_cacheBuilt) return;
  for (final entry in noteMap.entries) {
    final samples = _genToneSamples(entry.value.frequency, 0.35, 0.28, oscType: OscillatorType.sine);
    // 泛音
    final harmSamples = _genToneSamples(entry.value.frequency * 2, 0.25, 0.07, oscType: OscillatorType.sine);
    final combined = List<double>.generate(
      max(samples.length, harmSamples.length),
      (i) => (i < samples.length ? samples[i] : 0) + (i < harmSamples.length ? harmSamples[i] : 0),
    );
    _noteCache[entry.key] = _generateWav(combined);
  }
  _cacheBuilt = true;
}

// ── 播放器池 ──
final List<AudioPlayer> _playerPool = [];
int _poolIdx = 0;

AudioPlayer _getPlayer() {
  if (_playerPool.isEmpty) {
    for (int i = 0; i < 4; i++) {
      _playerPool.add(AudioPlayer());
    }
  }
  final p = _playerPool[_poolIdx % _playerPool.length];
  _poolIdx++;
  return p;
}

// ── 公开 API ──

/// 播放单个数字音符
Future<void> playDigit(int digit) async {
  _buildCache();
  final bytes = _noteCache[digit];
  if (bytes == null) return;
  final player = _getPlayer();
  await player.stop();
  await player.play(BytesSource(bytes));
}

/// 播放一串数字旋律
Future<void> playSequence(List<int> digits, {double tempo = 0.18}) async {
  for (int i = 0; i < digits.length; i++) {
    await playDigit(digits[i]);
    await Future.delayed(Duration(milliseconds: (tempo * 1000).round()));
  }
}

/// 正确音效
Future<void> playCorrect() async {
  _buildCache();
  final corr = [_C4, _E4, _G4, _C5];
  for (int i = 0; i < corr.length; i++) {
    final samples = _genToneSamples(corr[i], 0.4, 0.25, oscType: OscillatorType.sine);
    final harm = _genToneSamples(corr[i] * 2, 0.3, 0.06, oscType: OscillatorType.sine);
    final combined = List<double>.generate(
      max(samples.length, harm.length),
      (j) => (j < samples.length ? samples[j] : 0) + (j < harm.length ? harm[j] : 0),
    );
    final wav = _generateWav(combined);
    final player = _getPlayer();
    await player.stop();
    await player.play(BytesSource(wav));
    await Future.delayed(const Duration(milliseconds: 120));
  }
  // 尾音和弦
  await Future.delayed(const Duration(milliseconds: 80));
  final chordSamples = <double>[];
  final chordLen = (0.6 * _sampleRate).ceil();
  for (final f in corr) {
    final s = _genToneSamples(f, 0.6, 0.15, oscType: OscillatorType.triangle);
    for (int j = 0; j < chordLen; j++) {
      if (chordSamples.length <= j) chordSamples.add(0);
      chordSamples[j] += j < s.length ? s[j] : 0;
    }
  }
  final player = _getPlayer();
  await player.stop();
  await player.play(BytesSource(_generateWav(chordSamples)));
}

/// 错误音效
Future<void> playWrong() async {
  _buildCache();
  final notes = [_E4, _D4, _C4];
  for (int i = 0; i < notes.length; i++) {
    final samples = _genToneSamples(notes[i], 0.3, 0.2, oscType: OscillatorType.sawtooth);
    final wav = _generateWav(samples);
    final player = _getPlayer();
    await player.stop();
    await player.play(BytesSource(wav));
    await Future.delayed(const Duration(milliseconds: 180));
  }
}

/// 升级音效
Future<void> playLevelUp() async {
  _buildCache();
  final scale = [_C4, _D4, _E4, _F4, _G4, _A4, _B4, _C5];
  for (int i = 0; i < scale.length; i++) {
    final samples = _genToneSamples(scale[i], 0.2, 0.18, oscType: OscillatorType.sine);
    final wav = _generateWav(samples);
    final player = _getPlayer();
    await player.stop();
    await player.play(BytesSource(wav));
    await Future.delayed(const Duration(milliseconds: 80));
  }
}

/// 游戏结束音效
Future<void> playGameOver() async {
  _buildCache();
  final descend = [_C5, _B4, _A4, _G4, _F4, _E4, _D4, _C4];
  for (int i = 0; i < descend.length; i++) {
    final samples = _genToneSamples(descend[i], 0.5, 0.12, oscType: OscillatorType.triangle);
    final wav = _generateWav(samples);
    final player = _getPlayer();
    await player.stop();
    await player.play(BytesSource(wav));
    await Future.delayed(const Duration(milliseconds: 150));
  }
}

/// 点击音效
Future<void> playClick() async {
  _buildCache();
  final samples = _genToneSamples(880, 0.05, 0.1, oscType: OscillatorType.sine);
  final wav = _generateWav(samples);
  final player = _getPlayer();
  await player.stop();
  await player.play(BytesSource(wav));
}

/// 释放资源
Future<void> disposeAudio() async {
  for (final p in _playerPool) {
    await p.dispose();
  }
  _playerPool.clear();
  _noteCache.clear();
  _cacheBuilt = false;
}
