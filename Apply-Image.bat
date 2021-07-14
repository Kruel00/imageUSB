@echo off
if not exist X:\Windows\System32 echo ERROR: This script is built to run in Windows PE.
if not exist X:\Windows\System32 goto END
if %1.==. echo ERROR: No se definio la imagen
if %1.==. echo Ejemplo: ApplyImage D:\WindowsWithFrench.wim
if %1.==. goto END

call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
echo *********************************************************************
echo Checking to see the type of image being deployed
if "%~x1" == ".wim" (GOTO WIM)
if "%~x1" == ".ffu" (GOTO FFU)
echo *********************************************************************
if not "%~x1" == ".ffu". if not "%~x1" == ".wim" echo Please use this script with a WIM or FFU image.
if not "%~x1" == ".ffu". if not "%~x1" == ".wim" GOTO END

:WIM
wpeutil UpdateBootInfo

for /f "tokens=2* delims=	 " %%A in ('reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType') DO SET Firmware=%%B

if x%Firmware%==x echo ERROR: Can't figure out which firmware we're on.
if x%Firmware%==x echo        Common fix: In the command above:
if x%Firmware%==x echo	       for /f "tokens=2* delims=    "
if x%Firmware%==x echo        ...replace the spaces with a TAB character followed by a space.
if x%Firmware%==x goto END

rem if %Firmware%==0x1 GOTO BIOS
if %Firmware%==0x2 echo --OK-- Equipo configurado para UEFI. 

cls 
call menu.bat
echo Borrando el disco principal...
if %Firmware%==0x1 echo    ...using BIOS (MBR) format and partitions.
if %Firmware%==0x2 echo    ...using UEFI (GPT) format and partitions. 

if %EA%.==y. set EA=N

dism /Apply-Image /ImageFile:%1 /Index:1 /ApplyDir:W:\ /Compact /EA
W:\Windows\System32\bcdboot W:\Windows /s S:


:END
echo.
Echo Presione una tecla para reiniciar..
pause
exit

:BIOS
cls
echo.
echo Error! Boot configurado para BIOS.
echo Cambie la configuracion para UEFI.
pause
