#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BMPファイルをランレングス圧縮するプログラム
- 使用可能色: 黒(1), グレー(2), 白(3)
- 圧縮形式: 2bit色コード + 6bit長さコード
"""

from PIL import Image
import struct

def rgb_to_color_code(r, g, b):
    """
    RGB値を最も近い色コード（黒=1, グレー=2, 白=3）に変換
    グレーの基準: (128,128,128)
    """
    # グレースケール値を計算（輝度を考慮した標準的な変換）
    gray = int(0.299 * r + 0.587 * g + 0.114 * b)
    
    # 基準色との距離を計算して最も近い色を選択
    black_distance = gray  # 黒(0)との距離
    gray_distance = abs(gray - 128)  # グレー(128)との距離
    white_distance = abs(gray - 255)  # 白(255)との距離
    
    min_distance = min(black_distance, gray_distance, white_distance)
    
    if min_distance == black_distance:
        return 1  # 黒
    elif min_distance == gray_distance:
        return 2  # グレー
    else:
        return 3  # 白

def run_length_encode(pixels):
    """
    ピクセル配列をランレングス圧縮
    各要素は8bit (2bit色コード + 6bit長さコード)
    """
    if not pixels:
        return []
    
    compressed = []
    current_color = pixels[0]
    count = 1
    
    for i in range(1, len(pixels)):
        if pixels[i] == current_color and count < 64:  # 6bitの最大値は63+1=64
            count += 1
        else:
            # 現在のランを出力 (2bit色 + 6bit長さ-1)
            compressed_byte = (current_color << 6) | (count - 1)
            compressed.append(compressed_byte)
            
            current_color = pixels[i]
            count = 1
    
    # 最後のランを出力
    compressed_byte = (current_color << 6) | (count - 1)
    compressed.append(compressed_byte)
    
    return compressed

def convert_bmp_to_compressed(input_file, output_file):
    """
    BMPファイルを読み込んでランレングス圧縮し、バイナリファイルとして保存
    """
    try:
        # BMPファイルを開く
        with Image.open(input_file) as img:
            # RGBモードに変換
            img = img.convert('RGB')
            width, height = img.size
            
            print(f"画像サイズ: {width} x {height}")
            
            # ピクセルデータを取得し、色コードに変換
            pixels = []
            for y in range(height):
                for x in range(width):
                    r, g, b = img.getpixel((x, y))
                    color_code = rgb_to_color_code(r, g, b)
                    pixels.append(color_code)
            
            print(f"総ピクセル数: {len(pixels)}")
            
            # ランレングス圧縮
            compressed = run_length_encode(pixels)
            
            print(f"圧縮後のデータサイズ: {len(compressed)} bytes")
            print(f"圧縮率: {len(compressed) / len(pixels) * 100:.2f}%")
            
            # バイナリファイルとして保存
            with open(output_file, 'wb') as f:
                f.write(bytes(compressed))
            
            print(f"圧縮データを {output_file} に保存しました")
            
            # 圧縮データの最初の数バイトを表示（デバッグ用）
            print("\n圧縮データの最初の10バイト:")
            for i, byte in enumerate(compressed[:10]):
                color = (byte >> 6) & 0x3
                length = (byte & 0x3F) + 1
                print(f"  {i:2d}: 0x{byte:02X} -> 色={color}, 長さ={length}")
                
    except FileNotFoundError:
        print(f"エラー: ファイル '{input_file}' が見つかりません")
    except Exception as e:
        print(f"エラー: {e}")

def main():
    """
    メイン関数
    """
    input_file = "logo.bmp"
    output_file = "logo.bin"
    
    print("BMPファイルランレングス圧縮プログラム")
    print("=" * 40)
    
    convert_bmp_to_compressed(input_file, output_file)

if __name__ == "__main__":
    main()
