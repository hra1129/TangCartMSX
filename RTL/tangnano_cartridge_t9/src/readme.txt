TangNano9K用 OPLL/SCCカートリッジ。
-------------------------------------------------------------------------------

このディレクトリ階層に
	ikaopll
	ikascc
	dcsg
の3つのディレクトリを作成する。

その中に、
	dcsg
		sn76489_audio.vhd
	dcsg_wrap
	gowin_pll
	ikaopll
		IKAOPLL.v
		IKAOPLL_tb.sv
		IKAOPLL_modules
			+------ IKAOPLL_*.v
	ikaopll_wrap
	ikascc
		IKASCC.v
		IKASCC_modules
			+------ IKASCC_*.v
	ikascc_wrap
	pwm
		:
のような配置になるように、下記リポジトリの src の内容をコピーして使う。
	https://github.com/dnotq/sn76489_audio
	https://github.com/ika-musume/IKAOPLL
	https://github.com/ika-musume/IKASCC


音量が小さい問題がある。
R1 22kΩ を、0Ωにしてみても、まだ小さい。

TangcartMSX.gprj が GOWIN EDA によるビルド用のプロジェクトファイル。

-------------------------------------------------------------------------------
実験用に作成した未使用のサブモジュールがいくつか含まれている。
TangNano9K に内蔵の PSRAM が遅すぎて、ボツになった。

2024/11/13 HRA!
