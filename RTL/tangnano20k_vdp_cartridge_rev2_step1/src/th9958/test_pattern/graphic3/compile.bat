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

rem echo G3FONT
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_g3font.c v9968_common.o v9968_mode.o v9968_font.o -o G3FONT.COM
rem 
rem echo G3VSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_g3vscr.c v9968_common.o v9968_mode.o v9968_font.o -o G3VSCR.COM
rem 
rem echo G3HSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_g3hscr.c v9968_common.o v9968_mode.o v9968_font.o -o G3HSCR.COM
rem 
rem echo G3ADJ
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test004_g3adj.c v9968_common.o v9968_mode.o v9968_font.o -o G3ADJ.COM
rem 
rem echo G3SP1
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test005_g3sp1.c v9968_common.o v9968_mode.o v9968_font.o -o G3SP1.COM
rem 
rem echo G3SP2
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test006_g3sp2.c v9968_common.o v9968_mode.o v9968_font.o -o G3SP2.COM
rem 
rem echo G3SP3
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test007_g3sp3.c v9968_common.o v9968_mode.o v9968_font.o -o G3SP3.COM
rem 
rem echo G3SP4
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test008_g3sp4.c v9968_common.o v9968_mode.o v9968_font.o -o G3SP4.COM

echo G3IMG
zcc +msx -subtype=msxdos2 -I../v9968lib/ test009_g3img.c v9968_common.o v9968_mode.o v9968_font.o -o G3IMG.COM

pause
