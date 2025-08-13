zma sc0test.asm  SC0TEST.COM
zma sc1test.asm  SC1TEST.COM
zma sc2test.asm  SC2TEST.COM
zma sc3test.asm  SC3TEST.COM
zma sc4test.asm  SC4TEST.COM
zma sc5test.asm  SC5TEST.COM
zma test.asm  TEST.COM

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
	if exist D:\download\msx\DOS2\MSXDOS2\SC4TEST.COM (
		del D:\download\msx\DOS2\MSXDOS2\SC4TEST.COM
	)
	if exist D:\download\msx\DOS2\MSXDOS2\SC5TEST.COM (
		del D:\download\msx\DOS2\MSXDOS2\SC5TEST.COM
	)
	if exist D:\download\msx\DOS2\MSXDOS2\TEST.COM (
		del D:\download\msx\DOS2\MSXDOS2\TEST.COM
	)
	copy SC0TEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy SC1TEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy SC2TEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy SC3TEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy SC4TEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy SC5TEST.COM  D:\download\msx\DOS2\MSXDOS2\
	copy TEST.COM  D:\download\msx\DOS2\MSXDOS2\
)

pause
