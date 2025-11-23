@echo off
zcc -c +msx -subtype=msxdos2 -I. ./msx_vdp.c -o msx_vdp.o
zcc +msx -subtype=msxdos2 -I. devcon.c msx_vdp.o -o DEVCON.COM

pause
