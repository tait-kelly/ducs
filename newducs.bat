@echo off


REM $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$VARIABLES$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
set wakeupfailed=0 REM this will be a boolean set to 1 if a wakeup failed and a 0 if it worked.
set "IP=NUL" REM this will be the machines DNS name or the IP address
REM set "NM=NUL" REM Name of device used in health for a dns lookup
set "PW=NUL" REM This is the password
set "PHY=NUL" REM This is the physical address of the machine AKA MAC address
set "pingcount=0" REM this is for testing a machine after a wake packet is sent to see if it is up values 0-10
set "action=NUL" REM this is a function for deperminint the action to be taken based on the parameter passed in paramater 3 expected values are AUDIT UPDATE INSTALL
set "installs=NUL" REM this will specify the software packages to install options include 
REM $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$VARIABLES$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


REM =================================NOTES============================================================
REM 2022-04-07 Menus and parameters are now working now need merge into this script the old actions
REM 2022-04-06 New version to roll up ducs and macducs but also improve functionality and ease of use
REM 2016-03-30 -instead of going to help with no paramater could go to a prompt for questions of what you want to run get group or individual then action and software if install and then do a start same script with a wait and a pause and go to end.
REM 2016-03-30 - Could perform a backup of this script to a backup folder to provide versioning in the future as well
REM =================================NOTES============================================================

REM =====================KNOWN ISSUES - AS OF 2022-04-07=============================================================
REM All Actions are not working
REM Printers function is not working correct from old script
REM Report is not always working as it gets duplicate enties at times
REM Missing Error reports in script
REM Wakeup wol call is using an assumed static IP and should be changed to dynamic based on machine it is run on
REM Script update call is not working: need to determine a online location for the required files and credentials to be used to download when needed
REM dependancies need to be downloaded from an online location if not existing and win.csv file needs to be removed from depenancies

REM =====================KNOWN ISSUES - AS OF 2022-04-07=============================================================



set VERSION=2.1
set COMPILED=April 7th, 2022
set TITLE=Welcome to the new DUCS script version %VERSION% compiled on %COMPILED%


if "%1"=="" goto MENU
if "%1"=="?" goto HELP
if "%1"=="/?" goto HELP
if "%1"=="-?" goto HELP




for /f "delims=." %%a in ('wmic OS Get localdatetime ^| find "."') do set dt=%%a
set today=%dt:~0,8%
REM echo todays date is:%today%
GOTO PARAMETERS


:MENU
echo This is now the new menu system for new DUCS
echo This menu will need to get the following pieces of information:
echo 1. If they want to check and download a newer version of the script - Will need to determine how if a new version is availible how it will be run.
echo 2. If this will be running on a Mac or on a Windows machine
echo 3. If the pre-requisits have been run on the target - Will need to provide instructions on what to do for the setup
echo 4. What actions are desired: Deployment, Updates, Audit, or install specific software
echo 5. What Software to install if install is selected (Provide a listing - May be conditionally different for Windows vs Mac
echo 6. What the target IP or dns name is of the machine
echo 7. The username after other selections are made
echo 8. The password after other selections are made
echo now let start the actual menu.
echo.
echo.
echo.
cls
echo %TITLE%
echo -----------------------------------------------------------------------------------------
set /p UPDATE="Do you want to check online if there is a newer version of this script (y/n or Yes/No)?"
if /I "%UPDATE%"=="y" call:SCRIPTUPDATE
if /I "%UPDATE%"=="yes" call:SCRIPTUPDATE
set /p OSTYPE="What operating system type is the target running (Windows/Mac or W/M)?"
if /I "%OSTYPE%"=="m" echo you selected MacOS
if /I "%OSTYPE%"=="Mac" echo you selected MacOS
if /I "%OSTYPE%"=="w" echo you selected Windows
if /I "%OSTYPE%"=="windows" echo you selected Windows
set /p PREREQ="Have you run the prerequisits on the target machine (y/n or Yes/No)?"
if /I "%PREREQ%"=="n" call:PREREQUISITES
if /I "%PREREQ%"=="no" call:PREREQUISITES
echo next up is the selection for which action is desired
echo What type of action would you like to perform on the target machine
echo -------------------------------------------------------------------
echo 1. Deployment
echo 2. Updates
echo 3. Audit
echo 4. Install specific software
set /p ACTION="Enter the desired number for the action you would like to run (1-4):
if /I "%ACTION%"=="4" call:SPECIFICSOFTWARE
echo Now I will need either an IP or DNS name of the target machine
set /p TARGET="Enter the target machines IP or DNS name (DNS Names may need to be fully domain qualified):"
set /p USERNAME="Enter the username of the admin user to use:"
echo so it looks like we are all set to go you have provided information of: OStype: %OSTYPE%, Prequisites completed: %PREREQ%, Action of:%ACTION%, Target of:%TARGET%, and a username:%USERNAME%
echo.
echo.
echo Next up will be running the actions but a password prompt will get the password from you for the specified username first.

goto EOF

:PARAMETERS
if /I "%1"=="-d" set ACTION=1
if /I "%1"=="-u" set ACTION=2
if /I "%1"=="-a" set ACTION=3
if /I "%1"=="-i" set ACTION=4
if /I "%2"=="-w" set OSTYPE=Windows
if /I "%2"=="-m" set OSTYPE=MacOSX
if %ACTION%==4 (
	set SOFTWARE=%3
	set TARGET=%4
	set USERNAME=%6
	set PASSWORD=%8
)
if NOT %ACTION%==4 (
	set TARGET=%3
	set USERNAME=%5
	set PW=%7
)
echo time to output everything that I have got from the parameters:
echo Action:%ACTION%
echo OS Type:%OSTYPE%
echo Software:%SOFTWARE%
echo Target:%TARGET%
echo Username:%USERNAME%
echo Password:%PW%
echo next I should go to the appropritate action
PAUSE
goto EOF

:SPECIFICSOFTWARE
REM echo I am in the software install selection section
EXIT /b


:SCRIPTUPDATE
REM echo I am in the script update section
REM I can grab the current version listing from github via curl -LJO  https://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@github.com/tait-kelly/ducs/raw/main/Version.txt
echo I am in the script update section
del Version.txt
curl -LJO  https://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@github.com/tait-kelly/ducs/raw/main/Version.txt
for /f "tokens=1-2 delims=:" %%a in ('FINDSTR /C:"Version:" Version.txt') do set CURRVER=%%b
echo I got a version of:%CURRVER%
if %CURRVER%==%VERSION% echo well looks like we have the newest version
if %CURRVER% GTR %VERSION% echo looks like there is a newer version
curl -LJO  https://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@github.com/tait-kelly/ducs/raw/main/NewDucs%CURRVER%.bat
PAUSE
EXIT /b

:PREREQUISITES
REM echo I am in the prereqisits section and have a OS Type of %OSTYPE%
REM echo This section is going to need to provide instructions for running the prerequisites and potentially download the required files for running on the machine.
EXIT /b

:DECISIONS



:DEPENDANCIES




:HELP
echo Deploy, Audit, Update or Install software on a machine
echo.
echo DUCS [ACTION] [OSTYPE] [PACKAGE - IF ACTION IS INSTALL] [TARGET] -u [USERNAME]  -p [PASSWORD]
echo.
echo    Action 
echo    	-d Deployment of a machine - This will perform several actions and install multiple pieces of software
echo    	-u Update - This will update as many pieces of software on the machine as possible
echo    	-a Audit - This will audit the machine and collect information about the machine and provide a report
echo 		-i Install a specific piece of software on the target machine
echo	OS TYPE
echo 		-w Windows Machine
echo 		-m MacOSX machine
echo    Package
echo		-c Chrome
echo		-f firefox
echo		-r WinRAR
echo		-n Notepad++
echo		-a Adobe Reader
echo		-j Java
echo		-v VLC
echo		-browsers Chrome & firefox
echo		-all Chrome, Firefox, Adobe Reader, Java, WinRAR and VLC
echo    TARGET	DNS name or IP address
echo    -u [USERNAME] The username to use for the target machine
echo    -p [PASSWORD] the password for the specified user
echo.
echo Examples:
echo	DEPLOYMENT:
echo 		DUCS -d -w xxx.xxx.xxx.xxx -u sysadmin -p PASSWORDHERE
echo 	UPDATES
echo		DUCS -u -m xxx.xxx.xxx.xxx -u sysadmin -p PASSWORDHERE
echo	AUDIT
echo		DUCS -a -w xxx.xxx.xxx.xxx -u sysadmin -p PASSWORDHERE
echo	INSTALL A SPECIFIC SOFTWARE PACKAGE
echo		DUCS -i -w -all xxx.xxx.xxx.xxx -u sysadmin -p PASSWORDHERE
echo.
echo. 
goto EOF


:pwd var title color -- shows a password dialog box
::                   -- var   [in]     - return variable
::                   -- title [in,opt] - dialog title, default is "Password:"
::                   -- color [in,opt] - color default is AB (Light Green on Light Aqua)
:$created 20060101 :$changed 20080226 :$categories Input,Password
:$source http://www.dostips.com
SETLOCAL
set "tit=%~2"
set "col=%~3"
set "pwd="
if not defined col set "col=EF"
if not defined tit set "tit=Password:"
set "f=%temp%\%~nx0.tmp~0.tmp"
start "%tit%" /wait cmd /c "mode con cols=24 lines=1&color %col%&set /p "in="&call echo.%%in%%>"%f%""
for /f "usebackq tokens=*" %%a in ("%f%") do set "pwd=%%a"
del /q "%f%"
ENDLOCAL&if "%~1" NEQ "" (SET %~1=%pwd%) ELSE ECHO.%txt%
EXIT /b

:EOF
