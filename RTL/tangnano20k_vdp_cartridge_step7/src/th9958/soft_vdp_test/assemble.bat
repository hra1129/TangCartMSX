zma soft_vdp_test.asm VDPTEST.COM

if exist D:\download\msx\DOS2\MSXDOS2 (
	if exist D:\download\msx\DOS2\MSXDOS2\VDPTEST.COM (
		del D:\download\msx\DOS2\MSXDOS2\VDPTEST.COM
	)
	copy VDPTEST.COM D:\download\msx\DOS2\MSXDOS2\
)

pause
