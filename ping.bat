:: By Floris de Haan
:: Created 12-12-2012

@echo off
::Application VARS
color 02
set _runui=1

::Temp File VARS
set _tempfolder=%temp%\161651760311938227
set _tempfile=ivf.vbs

::Ping VARS
set _target=google.nl
set _size=32
set _count=2
set _visible=0

:start
if "%1" NEQ "" ( call :execinptoken %1 %2 )
if "%3" NEQ "" ( call :execinptoken %3 %4 )
if "%5" NEQ "" ( call :execinptoken %5 %6 )
if "%7" NEQ "" ( call :execinptoken %7 %8 )
if "%_runui%" EQU "0" (
	call :ping
	goto :EOF
) else (
	call :main
	goto :EOF
)

:stop
cls
taskkill /f /im ping.exe || Echo No ping running.
if exist %_tempfolder% (
	rd %_tempfolder% /s /q
)
goto :EOF

:execinptoken
:: execinptoken [command] [value]
if "%1" EQU "/syntax" (
	set /a _count=0
	set /a _runui=0
	goto :syntax 1
	pause>nul
	goto :EOF
) else (
	if "%1" EQU "/w" (
		if "%2" NEQ "" (
			if "%2" EQU "0" (
				set /a _runui=0
			) else (
				set /a _runui=1
			)
		) else (
			msg * Value not declared for %1
			goto :EOF
		)
	) else (
		if "%1" EQU "/t" (
			if "%2" NEQ "" (
				set _target=%2
			) else (
				msg * Value not declared for %1
				goto :EOF
			)
		) else (
			if "%1" EQU "/s" (
				if "%2" NEQ "" (
					set rval=%2
					set /a val=%2
					if "%val%" EQU "%rval%" (
						set /a _size=%2
					) else (
						msg * Int expected at input command %1 .
						goto :EOF
					)
				) else (
					msg * Value not declared for %1
					goto :EOF
				)
			) else (
				if "%1" EQU "/n" (
					if "%2" NEQ "" (
						set rval=%2
						set /a val=%2
						if "%val%" EQU "%rval%" (
							set /a _count=%2
						) else (
							msg * Int expected at input command %1
							goto :EOF
						)
					) else (
						msg * Value not declared for %1
						goto :EOF
					)
				) else (
					if "%1" EQU "/v" (
						if "%2" NEQ "" (
							set rval=%2
							set /a val=%2
							if "%val%" EQU "%rval%" (
								if "%2" EQU "0" (
									set /a _visible=0
								) else (
									set /a _visible=1
								)
							) else (
								msg * Int expected at input command %1
								goto :EOF
							)
						) else (
							msg * Value not declared for %1
							goto :EOF
						)
					) else (
						if "%1" EQU "/m" (
							if "%2" EQU "stop" (
								call :stop
								goto :EOF
							)
						else (
							msg * Unknown input command: %1
						)
					)					
				)
			)
		)
	)
)
goto :EOF

:main
call :topborder 1
echo Select a function to continue.
echo.
echo 1: Start ping with current settings
echo 2: Stop ping and remove temp files
echo 3: Prompt ping settings
echo 4: Display current setting
echo 5: Info and Credits
echo 6: Exit
echo.
set usrinp=99
set /p usrinp=Select: 
if "%usrinp%" EQU "1" (
	call :ping
	goto :main
) else (
	if "%usrinp%" EQU "2" (
		call :stop
		goto :main
	) else (
		if "%usrinp%" EQU "3" (
			call :prompt
			goto :main
		) else (
			if "%usrinp%" EQU "4" (
				call :result
				goto :main
			) else (
				if "%usrinp%" EQU "5" (
					call :info
					goto :main
				) else (
					if "%usrinp%" EQU "6" (
						call :preEOF
						goto :EOF
					) else (
						goto :main
					)
				)
			)
		)
	)
)
goto :EOF

:prompt
call :topborder 1
call :prompttarget Target: _target
call :promptint Size: 0 65500 _size
call :promptint Count: 0 65500 _count
call :promptint Visible: 0 1 _visible
goto :result

:ping
if "%_count%" LEQ "0" goto :EOF
if "%_visible%" EQU "0" (
	call :ececivcmd
) else (
	for /l %%i in (1,1,%_count%) do (
		start ping %_target% /l %_size% /t
	)
)
goto :EOF

:ececivcmd
if not exist %_tempfolder% ( md %_tempfolder% )
echo set oshell=CreateObject("Wscript.Shell") >%_tempfolder%\%_tempfile%
echo for i=1 to %_count% >>%_tempfolder%\%_tempfile%
echo oshell.Run "ping %_target% /l %_size% /t", 0, False >>%_tempfolder%\%_tempfile%
echo next >>%_tempfolder%\%_tempfile%
cscript %_tempfolder%\%_tempfile% >nul
goto :EOF

:info
call :topborder 1
echo --------------------------------------------------
echo INFO:
echo --------------------------------------------------
echo.
echo Envisioned By:  	Floris de Haan
echo Planned By: 		Floris de Haan
echo Developed By: 		Floris de Haan
echo Tested By: 		Floris de Haan, Olivier Beg
echo Deployed By: 		Floris de Haan
echo Thanks To: 		Google
echo.
echo --------------------------------------------------
echo Syntax
echo --------------------------------------------------
echo.
call :syntax 0
pause>nul
goto :EOF

:syntax
:: syntax [clear(1/0)]
if "%1" EQU "1" cls
echo Syntaxis: pingg [/w] [/t] [/s] [/n] [/v] [/m] [/syntax]
echo.
echo Options:
echo 	/w Bit			Show window.
echo 	/t String		Target for ping.
echo 	/s Int32		Size for ping sendbuffer.
echo 	/n Int32		The number of forms to open.
echo 	/v Bit			Set ping visibility.
echo 	/m mode			Set the application mode (start/stop).
echo.
goto :EOF

:result
call :topborder 1
echo 	Current Settings
echo.
set state=Online
set ic=Online
ping google.com /n 1 /l 0 /w 100>nul || ( set ic=Offline & set "state=Not Available")
if "%ic%" EQU "Online" (
	ping %_target% /n 1 /l 0 /w 100 >nul || ( set state=Offline )
)
echo IC: 		%ic%
echo Target: 	%_target% ( Status: %state% )
echo Size: 		%_size% byte(s)
echo Count:		%_count%
echo Visible:	%_visible%
echo.
echo Select a function to continue.
echo.
echo 1: Launch
echo 2: Prompt again
echo 3: Go Back
echo.
set /a usrinp=99
set /p usrinp=Select: 
if "%usrinp%" EQU "1" (
	call :ping
	goto :result
) else (
	if "%usrinp%" EQU "2" (
		goto :prompt
	) else (
		if "%usrinp%" EQU "3" (
			goto :EOF
		) else (
			goto :result
		)
	)
)

goto :EOF

:prompttarget
:: prompttarget [promptstring] [rv]
set /p inpval=%1
ping %inpval% /n 1 /l 0 /w 1000 >nul || ( echo -- Target is not reachable, please enter an online target & goto :prompttarget %1 %2 )
set %2=%inpval%
goto :EOF

:promptint
:: promptint [promptstring] [minvalue] [maxvalue] [rv]
set /p usrinp=%1
set /a rv=%usrinp%
if "%rv%" EQU "%usrinp%" (
	if "%rv%" GEQ "%2" (
		if "%rv%" LEQ "%3" (
			set %4=%rv%
		) else (
			echo -- Invalid input height, input must be less than or equal %3
			call :promptint %1 %2 %3 %4
		)
	) else (
		echo -- Invalid input height, input must be above or equal %2
		call :promptint %1 %2 %3 %4
	)
) else (
	echo -- Invalid input type, please enter an integer
	call :promptint %1 %2 %3 %4
)
goto :EOF

:preEOF
call :topborder 1
echo Greets from Floris!
pause > nul
cls
goto :EOF

:topborder
:: topborder [clear(1/0)]
if "%1" EQU "1" cls
echo -----------------------------------
echo.
echo By Floris de Haan - florisdehaan.nl
echo.
echo -----------------------------------
echo.
goto :EOF