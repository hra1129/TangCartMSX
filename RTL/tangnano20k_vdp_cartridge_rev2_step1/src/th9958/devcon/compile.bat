zcc -c +msx --opt-code-speed -subtype=msxdos2 -I. ./msx_vdp.c -o msx_vdp.o
zcc +msx --opt-code-speed -subtype=msxdos2 -I. devcon.c msx_vdp.o -o DEVCON.COM
pause
