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

rem echo G4FONT
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_g4font.c v9968_common.o v9968_mode.o v9968_font.o -o G4FONT.COM
rem 
rem echo G4VSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_g4vscr.c v9968_common.o v9968_mode.o v9968_font.o -o G4VSCR.COM
rem 
rem echo G4HSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_g4hscr.c v9968_common.o v9968_mode.o v9968_font.o -o G4HSCR.COM
rem 
rem echo G4ADJ
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test004_g4adj.c v9968_common.o v9968_mode.o v9968_font.o -o G4ADJ.COM
rem 
rem echo G4SP1
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test005_g4sp1.c v9968_common.o v9968_mode.o v9968_font.o -o G4SP1.COM
rem 
rem echo G4SP2
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test006_g4sp2.c v9968_common.o v9968_mode.o v9968_font.o -o G4SP2.COM
rem 
rem echo G4SP3
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test007_g4sp3.c v9968_common.o v9968_mode.o v9968_font.o -o G4SP3.COM
rem 
rem echo G4SP4
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test008_g4sp4.c v9968_common.o v9968_mode.o v9968_font.o -o G4SP4.COM

echo G4IMG
zcc +msx -subtype=msxdos2 -I../v9968lib/ test009_g4img.c v9968_common.o v9968_mode.o v9968_font.o -o G4IMG.COM

pause
