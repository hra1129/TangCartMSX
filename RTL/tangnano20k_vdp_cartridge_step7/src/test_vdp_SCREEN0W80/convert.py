#!/usr/bin/env python3
"""
romfont.binファイルをSystemVerilogのwrite_io文に変換するスクリプト
"""

def convert_romfont_to_systemverilog(input_file='romfont.bin', output_file='font.sv'):
    """
    romfont.binの内容をSystemVerilogのwrite_io文形式に変換する
    
    Args:
        input_file (str): 入力バイナリファイル名
        output_file (str): 出力SystemVerilogファイル名
    """
    try:
        # バイナリファイルを読み込み
        with open(input_file, 'rb') as f:
            data = f.read()
        
        print(f"読み込んだファイルサイズ: {len(data)} バイト")
        
        # SystemVerilogファイルに出力
        with open(output_file, 'w') as f:
            f.write("// romfont.binから自動生成されたSystemVerilogコード\n")
            f.write("// 生成日時: " + str(__import__('datetime').datetime.now()) + "\n\n")
            
            # 各バイトをwrite_io文に変換
            for i, byte_value in enumerate(data):
                f.write(f"write_io( vdp_io0, 8'h{byte_value:02X} );\n")
        
        print(f"変換完了: {output_file} に {len(data)} 個のwrite_io文を出力しました")
        
    except FileNotFoundError:
        print(f"エラー: {input_file} が見つかりません")
    except Exception as e:
        print(f"エラーが発生しました: {e}")

if __name__ == "__main__":
    convert_romfont_to_systemverilog()
