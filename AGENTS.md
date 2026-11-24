# 数律华章 (math_music_game)

数学音律益智游戏。Flutter 为正式交付；Web 调试稿在 `experiments/math-music-game-web`。

## 用途与 Target 判定

| 平台 | 需要? | 方式 |
|------|-------|------|
| 移动端 | 需要 | Flutter Android / iOS |
| 智能硬件 | 可选 | 未做；不纳入强制 Done |

## 命令

```bash
flutter test
flutter build apk
```

## Harness / Loop（助手）

- Guide = 本文件；Sensor = `flutter test`
- 同类失误第二次 → 规则或测试（棘轮）

## 验证环 / Done

```bash
flutter test
```

**Done**：`flutter test` 绿。不要把 experiments 里的 Web 稿当成正式 Target。
