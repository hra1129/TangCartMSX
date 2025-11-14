..\zma hmmv001.asm HMMV001.COM
@if errorlevel 1 (
	pause "エラーが発生しました。停止します。"
	exit
)
move zma.log hmmv001.log

@echo off
echo ***************************************************************************
echo  library
echo ***************************************************************************
zcc -c +msx -subtype=msxdos2 -I../v9968lib/ ../v9968lib/v9968_common.c -o v9968_common.o
zcc -c +msx -subtype=msxdos2 -I../v9968lib/ ../v9968lib/v9968_mode.c -o v9968_mode.o
zcc -c +msx -subtype=msxdos2 -I../v9968lib/ ../v9968lib/v9968_font.c -o v9968_font.o

echo ***************************************************************************
echo  test pattern
echo ***************************************************************************

echo HMMV002
zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_g6.c v9968_common.o v9968_mode.o v9968_font.o -o HMMV002.COM

pause
