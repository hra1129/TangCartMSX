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

echo HMMC001
zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_hmmc.c v9968_common.o v9968_mode.o v9968_font.o -o HMMC001.COM

echo HMMC002
zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_hmmc.c v9968_common.o v9968_mode.o v9968_font.o -o HMMC002.COM

echo HMMC003
zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_hmmc.c v9968_common.o v9968_mode.o v9968_font.o -o HMMC003.COM

pause
