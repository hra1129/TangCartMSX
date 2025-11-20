zma chkvdp.asm  CHKVDP.COM
@if errorlevel 1 pause ==========================

if exist D:\download\msx\DOS2\MSXDOS2 (
	if exist D:\download\msx\DOS2\MSXDOS2\CHKVDP.COM (
		del D:\download\msx\DOS2\MSXDOS2\CHKVDP.COM
	)
	copy CHKVDP.COM  D:\download\msx\DOS2\MSXDOS2\
)
pause
