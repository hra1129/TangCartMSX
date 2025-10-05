#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MSX SCREEN5 画像ファイルから指定領域を切り出すツール

MSX_LOGO_208x78.SC5 から左上の 208x78 画素領域を切り出して
MSX_LOGO_208x78.BIN を作成します。

SCREEN5 フォーマット:
- 先頭 7byte: ファイルヘッダ
- 画像データ: 2pixel = 1byte (上位4bit=左画素, 下位4bit=右画素)
- 画像サイズ: 幅256画素(128byte) x 高さ212ライン
- その後にパレットデータが続く
"""

import os
import sys

def extract_msx_logo():
    """MSX SCREEN5ファイルから208x78領域を切り出す"""
    
    input_file = "MSX_LOGO_.208x78.SC5"
    output_file = "MSX_LOGO_208x78.BIN"
    
    # 入力ファイルの存在確認
    if not os.path.exists(input_file):
        print(f"エラー: 入力ファイル '{input_file}' が見つかりません。")
        return False
    
    try:
        with open(input_file, "rb") as f:
            # ファイル全体を読み込み
            data = f.read()
            
        print(f"入力ファイルサイズ: {len(data)} bytes")
        
        # ヘッダーをスキップ（7bytes）
        if len(data) < 7:
            print("エラー: ファイルが小さすぎます（ヘッダーが不完全）")
            return False
            
        # 画像データの開始位置
        image_start = 7
        
        # SCREEN5の画像データサイズを計算
        # 幅256画素 = 128byte, 高さ212ライン
        screen5_width_bytes = 256 // 2  # 128 bytes
        screen5_height = 212
        expected_image_size = screen5_width_bytes * screen5_height
        
        print(f"期待される画像データサイズ: {expected_image_size} bytes")
        
        if len(data) < image_start + expected_image_size:
            print("警告: ファイルサイズが期待値より小さいです")
        
        # 切り出したい領域のサイズ
        target_width = 208  # 画素
        target_height = 78  # ライン
        target_width_bytes = target_width // 2  # 104 bytes (208画素 = 104byte)
        
        print(f"切り出し領域: {target_width}x{target_height} 画素 ({target_width_bytes} bytes/line)")
        
        # 出力データを格納するリスト
        output_data = bytearray()
        
        # 各ラインを処理
        for line in range(target_height):
            # 現在のラインの開始位置を計算
            line_start = image_start + (line * screen5_width_bytes)
            
            # ラインの範囲チェック
            if line_start + target_width_bytes > len(data):
                print(f"警告: ライン {line} のデータが不足しています")
                break
            
            # 左上から208画素分（104bytes）を切り出し
            line_data = data[line_start:line_start + target_width_bytes]
            output_data.extend(line_data)
        
        # 出力ファイルに書き込み
        with open(output_file, "wb") as f:
            f.write(output_data)
        
        print(f"切り出し完了:")
        print(f"  出力ファイル: {output_file}")
        print(f"  出力サイズ: {len(output_data)} bytes")
        print(f"  画像サイズ: {target_width}x{target_height} 画素")
        print(f"  期待サイズ: {target_width_bytes * target_height} bytes")
        
        return True
        
    except Exception as e:
        print(f"エラーが発生しました: {e}")
        return False

def main():
    """メイン関数"""
    print("MSX SCREEN5 画像切り出しツール")
    print("=" * 40)
    
    if extract_msx_logo():
        print("処理が正常に完了しました。")
    else:
        print("処理中にエラーが発生しました。")
        sys.exit(1)

if __name__ == "__main__":
    main()
