@ECHO OFF
COLOR F9

:: #############################################################
:LOOP
CLS
ECHO ###########################
ECHO #   A. Deploy an Image    #
ECHO #   B. Password Editor    #
ECHO #   Q. Command Promt      #
ECHO #   R. Restart            #
ECHO #   S. Shutdown           #
ECHO ###########################
ECHO.

SET choice=
SET /P choice=select option: 
CLS

:: /I makes the IF comparison case-insensitive
IF /I '%choice%'=='A' GOTO DEPLOY
IF /I '%choice%'=='B' GOTO PWedit
IF /I '%choice%'=='Q' GOTO END
IF /I '%choice%'=='R' GOTO REBOOT
IF /I '%choice%'=='S' GOTO SHUTDOWN
ECHO "%choice%" is not valid. Please try again.
PAUSE
GOTO Loop

:: #############################################################
:DEPLOY
CLS
CALL %scripts%\dism\deploy.cmd
GOTO LOOP

:: #############################################################
:PWedit
CLS
ECHO Windows was in drive:
FOR %%i in (C D E F G H I J K) do IF EXIST %%i:\Windows\System32\config\SAM ECHO %%i
CALL %tools%\ntpwedit64\ntpwedit64
PAUSE
GOTO LOOP

:: #############################################################
:REBOOT
CLS
ECHO rebooting...
Wpeutil reboot

:: #############################################################
:SHUTDOWN
CLS
ECHO shutting down...
Wpeutil shutdown

:: #############################################################
:END
CLS
CMD