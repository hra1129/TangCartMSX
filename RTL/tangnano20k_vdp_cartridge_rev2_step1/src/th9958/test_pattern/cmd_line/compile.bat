..\zma line001.asm LINE001.COM
@if errorlevel 1 (
	pause "�G���[���������܂����B��~���܂��B"
	exit
)
move zma.log line001.log

..\zma line002.asm line002.COM
@if errorlevel 1 (
	pause "�G���[���������܂����B��~���܂��B"
	exit
)
move zma.log line002.log

pause
