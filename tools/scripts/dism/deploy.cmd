:: defaults
SET default_netshare=\\dropzone\anonymous\wim /user:user pass
SET diskscript=%scripts%\diskpart\diskscript.bat
:: diskscript is dynamically created based on
::   a. selected disk
::   b. MBR or GDP

:: #################################################################
:SelectDisk
CLS
Diskpart /s %scripts%\diskpart\list_disk.bat
ECHO.
SET disk=
SET /P disk=select disk number to apply image: 
ECHO.
ECHO using Disk %disk%
SET choice=
SET /P choice=continue? [y/n]: 
IF /I '%choice%'=='Y' GOTO SelectPartition
GOTO SelectDisk
:: find a way to check for valid int

:: #################################################################
:SelectPartition
CLS
ECHO ##############
ECHO #   A. MBR   #
ECHO #   B. GDP   #
ECHO ##############
ECHO.
SET choice=
SET /P choice=select partitioning: 
ECHO.

ECHO select disk %disk% > %diskscript%

IF /I '%choice%'=='A' (
  MORE %scripts%\diskpart\createMBR.bat >> %diskscript%
  GOTO SelectSource
)
IF /I '%choice%'=='B' (
  MORE %scripts%\diskpart\createUEFI.bat >> %diskscript%
  GOTO SelectSource
)

ECHO "%choice%" is not valid. Please try again.
PAUSE
GOTO SelectPartition

:: #################################################################
:SelectSource
CLS
ECHO ########################
ECHO #   L. local usb       #
ECHO #   N. network share   #
ECHO ########################
ECHO.

SET choice=
SET /P choice=select image source: 
IF /I '%choice%'=='L' GOTO SelectLocalImage
IF /I '%choice%'=='N' GOTO StartNetworkService
ECHO "%choice%" is not valid. Please try again.
PAUSE
GOTO SelectSource

:: #################################################################
:SelectLocalImage
REM wpeinit
REM SET imagelocation=?
:: find wim folder on usb
:: list files in directory
ECHO WIP...
ECHO using local usb image
PAUSE
GOTO END

:: #################################################################
:StartNetworkService
CLS
ECHO starting network service...
wpeutil InitializeNetwork
ECHO wpeutil InitializeNetwork

SET choice=
SET /P choice=continue? [y]:
IF /I '%choice%'=='Y' GOTO SelectNetwork
GOTO StartNetworkService

:: #################################################################
:SelectNetwork
CLS
SET netshare=%default_netshare%

:: set netshare
SET choice=
SET /P choice=specify network share [%netshare%]: 
IF NOT '%choice%'=='' SET netshare=%choice%
ECHO.
ECHO using network share "%netshare%"
SET choice=
SET /P choice=continue? [y]: 
IF /I NOT '%choice%'=='Y' GOTO SelectNetwork

:: connect
CLS
ECHO connecting...
ECHO net use n: %netshare%
net use n: %netshare%
SET imgdir=N:
SET choice=
SET /P choice=continue? [y]:
IF /I '%choice%'=='Y' GOTO SelectImage
GOTO SelectNetwork

:: #################################################################
:SelectImage
CLS
DIR %imgdir% /b /a-d
ECHO.
SET imgname=
SET /P imgname=type imagename: 
ECHO.

SET choice=
ECHO using image source: %imgdir%\%imgname%
SET /P choice=continue? [y]:
IF /I '%choice%'=='Y' GOTO ApplyImage
GOTO SelectImage
PAUSE

:: #################################################################
:: Apply Images Using DISM
:: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/apply-images-using-dism
:ApplyImage
CLS

:: change power settings
ECHO changing power settings...
ECHO powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
ECHO.

:: prepare the disk
ECHO preparing disk...
ECHO Diskpart /s %diskscript%
Diskpart /s %diskscript%

:: apply the image
CLS
ECHO applying image...
ECHO "Dism /apply-image /imagefile:%imgdir%\%imgname% /index:1 /ApplyDir:W:\"
Dism /apply-image /imagefile:%imgdir%\%imgname% /index:1 /ApplyDir:W:\

:: write boot configuration data
ECHO.
ECHO writing boot config data...
bcdboot W:\Windows /s S:

PAUSE
Wpeutil shutdown