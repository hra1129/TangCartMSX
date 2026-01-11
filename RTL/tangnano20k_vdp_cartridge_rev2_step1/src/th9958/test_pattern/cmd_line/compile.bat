..\zma line001.asm LINE001.COM
@if errorlevel 1 (
	pause "エラーが発生しました。停止します。"
	exit
)
move zma.log line001.log

..\zma line002.asm line002.COM
@if errorlevel 1 (
	pause "エラーが発生しました。停止します。"
	exit
)
move zma.log line002.log

..\zma line003.asm line003.COM
@if errorlevel 1 (
	pause "エラーが発生しました。停止します。"
	exit
)
move zma.log line003.log

pause
