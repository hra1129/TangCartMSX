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

echo G4SP1
zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_sp1.c v9968_common.o v9968_mode.o v9968_font.o -o G4SP1.COM

echo G4SP2
zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_sp2.c v9968_common.o v9968_mode.o v9968_font.o -o G4SP2.COM

echo G4IMG
zcc +msx -subtype=msxdos2 -I../v9968lib/ test009_g4img.c v9968_common.o v9968_mode.o v9968_font.o -o G4IMG.COM

echo G4CACHE
zcc +msx -subtype=msxdos2 -I../v9968lib/ test010_hmmv.c v9968_common.o v9968_mode.o v9968_font.o -o G4CACHE.COM

pause
