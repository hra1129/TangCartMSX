zma sc0test.asm  SC0TEST.COM
zma sc1test.asm  SC1TEST.COM
zma sc2test.asm  SC2TEST.COM
zma sc3test.asm  SC3TEST.COM
zma soft_vdp_test2.asm VDPTEST2.COM

if exist D:\download\msx\DOS2\MSXDOS2 (
	if exist D:\download\msx\DOS2\MSXDOS2\SC0TEST.COM (
		del D:\download\msx\DOS2\MSXDOS2\SC0TEST.COM
	)
	if exist D:\download\msx\DOS2\MSXDOS2\SC1TEST.COM (
		del D:\download\msx\DOS2\MSXDOS2\SC1TEST.COM
	)
	if exist D:\download\msx\DOS2\MSXDOS2\SC2TEST.COM (
		del D:\download\msx\DOS2\MSXDOS2\SC2TEST.COM
	)
	if exist D:\download\msx\DOS2\MSXDOS2\SC3TEST.COM (
		del D:\download\msx\DOS2\MSXDOS2\SC3TEST.COM
	)
	if exist D:\download\msx\DOS2\MSXDOS2\VDPTEST2.COM (
		del D:\download\msx\DOS2\MSXDOS2\VDPTEST2.COM
	)
	copy SC0TEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy SC1TEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy SC2TEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy SC3TEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy VDPTEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy VDPTEST2.COM D:\download\msx\DOS2\MSXDOS2\
)

pause
