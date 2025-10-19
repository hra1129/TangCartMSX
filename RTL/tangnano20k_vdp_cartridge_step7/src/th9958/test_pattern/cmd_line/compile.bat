..\zma line001.asm LINE001.COM
@if errorlevel 1 (
	pause "エラーが発生しました。停止します。"
	exit
)
move zma.log line001.log

pause
