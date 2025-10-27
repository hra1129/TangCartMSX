zma V9968DM.ASM  V9968DM.COM
@if errorlevel 1 pause ==========================

if exist D:\download\msx\DOS2\MSXDOS2 (
	if exist D:\download\msx\DOS2\MSXDOS2\V9968DM.COM (
		del D:\download\msx\DOS2\MSXDOS2\V9968DM.COM
	)
	copy V9968DM.COM  D:\download\msx\DOS2\MSXDOS2\

	if exist D:\download\msx\DOS2\MSXDOS2\LOGO.BIN (
		del D:\download\msx\DOS2\MSXDOS2\LOGO.BIN
	)
	copy LOGO.BIN  D:\download\msx\DOS2\MSXDOS2\
)
pause
