このディレクトリ階層に
	ikaopll
	ikascc
の2つのディレクトリを作成する。

その中に、
		:
	gpio_mem
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
	kanjirom
		:
のような配置になるように、下記リポジトリの src の内容をコピーして使う。
	https://github.com/ika-musume/IKAOPLL
	https://github.com/ika-musume/IKASCC
