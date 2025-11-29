#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BMPファイルをフォントバイナリに変換するツール

text{番号}.bmp ファイルを順番に読み込み、
黒いドット=0、白いドット=1 としてビットパターンを形成し、
font.bin に書き出します。

1byteの中では、MSB側に左画素、LSB側に右画素が来るように配置します。
"""

import os
import glob
from PIL import Image


def convert_bmp_to_bits(bmp_path):
    """
    BMPファイルを読み込み、ビットパターンに変換
    
    Args:
        bmp_path: BMPファイルのパス
    
    Returns:
        bytes: 変換されたバイトデータ
    """
    # 画像を読み込み、グレースケールに変換
    img = Image.open(bmp_path).convert('L')
    width, height = img.size
    
    print(f"Processing: {os.path.basename(bmp_path)} ({width}x{height})")
    
    # ビットデータを格納するリスト
    byte_data = []
    
    # スキャンライン順に走査
    for y in range(height):
        bit_buffer = 0
        bit_count = 0
        
        for x in range(width):
            # ピクセル値を取得 (0=黒, 255=白)
            pixel = img.getpixel((x, y))
            
            # 黒いドット=0、白いドット=1
            # 128を閾値として2値化
            bit = 1 if pixel >= 128 else 0
            
            # MSB側に左画素、LSB側に右画素
            bit_buffer = (bit_buffer << 1) | bit
            bit_count += 1
            
            # 8ビット溜まったら1バイトとして出力
            if bit_count == 8:
                byte_data.append(bit_buffer)
                bit_buffer = 0
                bit_count = 0
        
        # 1行の最後に端数があれば、左詰めして出力
        if bit_count > 0:
            bit_buffer <<= (8 - bit_count)
            byte_data.append(bit_buffer)
    
    return bytes(byte_data)


def main():
    """メイン処理"""
    # カレントディレクトリのtext{番号}.bmpファイルを検索
    pattern = "text*.bmp"
    bmp_files = glob.glob(pattern)
    
    if not bmp_files:
        print(f"エラー: {pattern} に一致するファイルが見つかりません")
        return
    
    # ファイル名をソート (番号順に処理)
    bmp_files.sort()
    
    print(f"見つかったファイル: {len(bmp_files)}個")
    print("-" * 50)
    
    # 全てのBMPファイルを変換して連結
    output_data = bytearray()
    
    for bmp_file in bmp_files:
        try:
            converted_data = convert_bmp_to_bits(bmp_file)
            output_data.extend(converted_data)
            print(f"  -> {len(converted_data)} bytes 追加")
        except Exception as e:
            print(f"エラー: {bmp_file} の処理中にエラーが発生しました: {e}")
            continue
    
    # font.binに書き出し
    output_file = "font.bin"
    with open(output_file, "wb") as f:
        f.write(output_data)
    
    print("-" * 50)
    print(f"完了: {output_file} に {len(output_data)} bytes 書き込みました")


if __name__ == "__main__":
    main()
