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

echo HMMM001
zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_hmmm.c v9968_common.o v9968_mode.o v9968_font.o -o HMMM001.COM

echo HMMM002
zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_g6.c v9968_common.o v9968_mode.o v9968_font.o -o HMMM002.COM

echo HMMM1
..\zma test001_hmmm.asm HMMM1.COM

pause
