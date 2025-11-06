..\zma r17bypass.asm R17BYPAS.COM
move zma.log r17bypass.log
@if errorlevel 1 (
	pause "エラーが発生しました。停止します。"
	exit
)

..\zma hvsync.asm HVSYNC.COM
move zma.log hvsync.log
@if errorlevel 1 (
	pause "エラーが発生しました。停止します。"
	exit
)

..\zma palette.asm PALETTE.COM
move zma.log palette.log
@if errorlevel 1 (
	pause "エラーが発生しました。停止します。"
	exit
)

..\zma synccnt.asm SYNCCNT.COM
move zma.log synccnt.log
@if errorlevel 1 (
	pause "エラーが発生しました。停止します。"
	exit
)

..\zma lineintr.asm LINEINTR.COM
move zma.log lineintr.log
@if errorlevel 1 (
	pause "エラーが発生しました。停止します。"
	exit
)

pause
