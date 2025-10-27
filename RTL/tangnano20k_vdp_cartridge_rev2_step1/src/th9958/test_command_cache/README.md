# VDP Command Cache Test Bench

このディレクトリには、`vdp_command_cache.v` モジュールのテストベンチが含まれています。

## ファイル構成

- `tb.sv` - SystemVerilog テストベンチ（メインファイル）
- `run.bat` - ModelSim コマンドラインでのビルド・実行バッチファイル
- `run_gui.bat` - ModelSim GUIでのビルド・実行バッチファイル
- `run.do` - ModelSim 自動実行スクリプト
- `wave.do` - 波形設定ファイル（GUI用）

## 実行方法

### コマンドライン実行
```batch
run.bat
```

### GUI実行
```batch
run_gui.bat
```

GUI実行後、ModelSimのコンソールで以下のコマンドを実行すると波形設定が適用されます：
```tcl
do wave.do
run -all
```

## テスト内容

このテストベンチは以下の機能をテストします：

1. **基本操作テスト** (`test_basic_operations`)
   - 単一バイトの読み書き操作
   - 異なるアドレス位置での動作確認

2. **キャッシュヒットテスト** (`test_cache_hit`)
   - 同一32bitワード境界内での連続アクセス
   - キャッシュからの高速読み出し確認

3. **キャッシュ置換テスト** (`test_cache_replacement`)
   - キャッシュフル時の置換動作
   - LRU（Least Recently Used）アルゴリズムの確認

4. **VRAM読み出しテスト** (`test_vram_read`)
   - 初期化済みVRAMからの読み出し
   - VRAMインターフェースの動作確認

5. **キャッシュフラッシュテスト** (`test_cache_flush`)
   - キャッシュフラッシュ機能の動作確認
   - フラッシュ後のVRAMからの読み出し確認

6. **Start信号制御テスト** (`test_start_control`)
   - `start`信号による1クロックパルス制御機能の確認
   - 通常時は0、必要時に1クロックのパルスを生成するテスト

## 信号の特性

- **start信号**: 1クロック幅のパルス信号
  - 通常は0を維持
  - キャッシュ動作開始時に1クロックだけ1になる
  - `generate_start_pulse()`タスクで制御

- **cache_flush_start信号**: 1クロック幅のパルス信号
  - キャッシュフラッシュ開始時に1クロックだけ1になる
  - `flush_cache()`タスクで制御

- **cache_flush_end信号**: フラッシュ完了通知信号
  - フラッシュ処理完了時に1になる
  - この信号を確認してからstart信号を発行する必要がある

## テストシーケンス

1. **初回テスト**: リセット → start パルス → テスト実行
2. **2回目以降のテスト**: フラッシュ → start パルス → テスト実行

各テストケース間では必ず`prepare_new_test()`が実行され、適切なフラッシュシーケンスが行われます。

## VRAMシミュレーション

テストベンチには128KB VRAM（32K×32bit）のシミュレーションが含まれており、実際のVRAMアクセス遅延（2クロック）を模擬します。

## エラー処理

- タイムアウト検出機能
- 期待値との不一致検出
- 詳細なエラーメッセージ出力

## 出力例

テスト成功時の出力例：
```
=== VDP Command Cache Test Start ===
[0] Initializing VRAM with test pattern
[500] VRAM initialization complete
[500] Reset sequence start
[1260] Reset sequence complete

=== Test Case: Basic Operations ===
[1260] Cache write: addr=0x00000, data=0xAA
[1400] Cache write completed
...
=== All Tests PASSED ===
Test completed successfully at time 12500
```

## 注意事項

- ModelSim 10.0以降での動作を想定
- SystemVerilog対応が必要
- テスト実行時間は約10,000クロックサイクル
