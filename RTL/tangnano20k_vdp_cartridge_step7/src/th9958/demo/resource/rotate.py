#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
LRMM の設定値を計算するツール
"""

import os
import sys
import math

def extract_msx_logo():
	"""LRMM の設定値を計算するツール"""
	
	output_file = "rotate.txt"
	
	try:
		# 回転中心
		ox = 104
		oy = 39
		with open(output_file, "w") as f:
			for theta in range( 0, 128 ):
				vx = math.cos( theta * math.pi / 64 )
				vy = math.sin( theta * math.pi / 64 )
				sx = ox - vx * ox * (theta/128) + vy * oy * (theta/128)
				sy = oy - vy * ox * (theta/128) - vx * oy * (theta/128)
				# 整数化
				vx = int( vx * theta )
				vy = int( vy * theta )
				sx = int( sx )
				sy = int( sy + 256 )
				f.writelines( [ f"\tdw\t{vx}\t; {theta}[deg]\n", f"\tdw\t{vy}\n", f"\tdw\t{sx}\n", f"\tdw\t{sy}\n" ] )

			for theta in range( 0, 128 ):
				vx = math.cos( theta * math.pi / 64 )
				vy = math.sin( theta * math.pi / 64 )
				sx = ox - vx * ox + vy * oy
				sy = oy - vy * ox - vx * oy
				# 整数化
				vx = int( vx * 256 )
				vy = int( vy * 256 )
				sx = int( sx )
				sy = int( sy + 256 )
				f.writelines( [ f"\tdw\t{vx}\t; {theta}[deg]\n", f"\tdw\t{vy}\n", f"\tdw\t{sx}\n", f"\tdw\t{sy}\n" ] )
		return True
	except Exception as e:
		print(f"エラーが発生しました: {e}")
		return False

def main():
	"""メイン関数"""
	print("LRMM 設定値計算ツール")
	print("=" * 40)
	
	if extract_msx_logo():
		print("処理が正常に完了しました。")
	else:
		print("処理中にエラーが発生しました。")
		sys.exit(1)

if __name__ == "__main__":
	main()
