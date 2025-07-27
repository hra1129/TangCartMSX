zma soft_vdp_test.asm  VDPTEST.COM
zma soft_vdp_test2.asm VDPTEST2.COM

if exist D:\download\msx\DOS2\MSXDOS2 (
	if exist D:\download\msx\DOS2\MSXDOS2\VDPTEST.COM (
		del D:\download\msx\DOS2\MSXDOS2\VDPTEST.COM
	)
	if exist D:\download\msx\DOS2\MSXDOS2\VDPTEST2.COM (
		del D:\download\msx\DOS2\MSXDOS2\VDPTEST2.COM
	)
	copy VDPTEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy VDPTEST2.COM D:\download\msx\DOS2\MSXDOS2\
)

pause
