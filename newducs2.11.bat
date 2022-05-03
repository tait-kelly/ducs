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

REM ============================CURRENT STATUS===================================================
REM 2022-05-02 All Windows Functions should now be working as desired - Tested a full (-all) install flag and everything installed as desired.
REM 2022-05-02 Programmed the parameters function for all windows functionality but need to test
REM 2022-05-02 Changed Specific software to accomidate passing of parameters in the call instead by adding a function wspecifiselect and change the calls after each install to be an exit back instead 
REM 2022-05-02 Update and Audit tested and working now.
REM 2022-04-29 Specific software has all been tested and working. Update and Audit are the last ones to be tested for Windows and the flags handaling for the script needs to be tested and improved.
REM 2022-04-28 Added code for windows specific software but need to test next.
REM ============================CURRENT STATUS===================================================

REM =================================NOTES============================================================
REM 2022-04-28 Added a current status section this may be removed at a later time.
REM 2022-04-28 Windows Specific software selection and code has been added but still needs to be tested.
REM 2022-04-28 Resolved issue of error for can't set default printer by adding registry key before office install so a restart is performed and that resolved the issue.
REM 2022-04-27 Moved Windows batch creations to separate procedure calls ******This has not been tested yet.
REM 2022-04-27 Added a registry key to use Windows Legacy default printer which eliminates the prompt on all but the first install of printers
REM 2022-04-26 Printer and system info should now be fixed on Windows deployments but needs to be tested.
REM 2022-04-25 Several fixes and deployment is completed except for the printer installs
REM 2022-04-22 Fixing lots of output to simplify the output for easier reading
REM 2022-04-19 Invalid reference on Office 365 to configuration file (needs to be full path) fixed so Office 365 is now installing
REM 2022-04-19 Ninite agent and spiceworks agent shell are not installing correctly need to fix.
REM 2022-04-13 replace sysadmin usage with %SERNAME%
REM 2022-04-13 Commented out a few lines of output to cleanup the interface
REM 2022-04-13 Currently have a problem with the office 365 install need to fix
REM 2022-04-13 IP references have been changed to TARGET and sysadmin has been changed to %USERNAME%
REM 2022-04-11 Completed to specific software but selection is the only part completed need to do the coding for the installs.
REM 2022-04-11 Merge process in progress for Windows calls
REM 2022-04-11 Added Software & install working on Audit with some improvements to audit
REM 2022-04-08 Merge process in progress - Completed to specific software but selection is the only part completed need to do the coding for the installs.
REM 2022-04-08 sysadmin and %TARGET% variables need to be changed to %USERNAME% and %TARGET%
REM 2022-04-08 Still have references to MAC address with the variable %PHY% need to find a solution to this.
REM 2022-04-08 Windows has been the focus so far but the mac systems also need be rolled into this script.
REM 2022-04-08 Last worked on Windows Install function need to fix issues in which the wakeup is done via MAC address and also need to 
REM 2022-04-07 Menus and parameters are now working now need merge into this script the old actions
REM 2022-04-06 New version to roll up ducs and macducs but also improve functionality and ease of use
REM 2016-03-30 instead of going to help with no paramater could go to a prompt for questions of what you want to run get group or individual then action and software if install and then do a start same script with a wait and a pause and go to end.
REM 2016-03-30 Could perform a backup of this script to a backup folder to provide versioning in the future as well
REM =================================NOTES============================================================

REM ==============================Pending Changes / Improvements======================================
REM MAC OS functions
REM		*Deployment
REM		*Updates
REM		*Specific Software
REM		*Audit
REM Windows functions
REM
REM Better Error reporting
REM ==============================Pending Changes / Improvements======================================


REM =====================KNOWN ISSUES / BUGS=============================================================
REM 2022-05-02 SPECIFIC SOFTWARE INSTALLS VIA COMMAND FLAGS HAVE NOT BEEN TESTED INDIVIDUALLY FOR ALL
REM =====================KNOWN ISSUES=============================================================



set VERSION=2.11
set COMPILED=May 2nd, 2022
for /f "delims=." %%a in ('wmic OS Get localdatetime ^| find "."') do set dt=%%a
set today=%dt:~0,8%
REM echo todays date is:%today%
set GITHUBKEY=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
set TITLE=Welcome to the new DUCS script version %VERSION% compiled on %COMPILED%
REM echo I am creating the logs folder now
if NOT EXIST "%CD%\logs\" mkdir %CD%\logs
if NOT EXIST "%CD%\logs\%TODAY%" mkdir %CD%\logs\%TODAY%

set UPDATE=
set OSTYPE=
set PREREQ=
set VALIDOS=
if "%1"=="" goto MENU
if "%1"=="?" goto HELP
if "%1"=="/?" goto HELP
if "%1"=="-?" goto HELP
if "%1"=="s" goto MENU





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
if NOT "%1"=="s" (
	set /p UPDATE="Do you want to check online if there is a newer version of this script (y/n or Yes/No)?"
)
if /I "%UPDATE%"=="y" call:SCRIPTUPDATE
if /I "%UPDATE%"=="yes" call:SCRIPTUPDATE
set /p OSTYPE="What operating system type is the target running (Windows/Mac or W/M)?"
if /I "%OSTYPE%"=="m" (
	set VALIDOS=TRUE
	set OS=MAC
)
if /I "%OSTYPE%"=="Mac" ( 
	set VALIDOS=TRUE
	set OS=MAC
)
if /I "%OSTYPE%"=="w" (
	set VALIDOS=TRUE
	set OS=WINDOWS
)
if /I "%OSTYPE%"=="windows" (
	set VALIDOS=TRUE
	set OS=WINDOWS
)
if /I NOT "%VALIDOS%"=="TRUE" (
	echo You did not enter a valid selection. Please rerun this script and enter a valid selection
	goto EOF
)
REM echo next up is the selection for which action is desired
echo What type of action would you like to perform on the target machine
echo -------------------------------------------------------------------
echo 1. Deployment
echo 2. Updates
echo 3. Audit
echo 4. Install specific software or configure items
set /p ACTION="Enter the desired number for the action you would like to run (1-4):
REM echo Now I will need either an IP or DNS name of the target machine
if /I "%ACTION%"=="1" (
	set /p PREREQ="Have you run the prerequisites on the target machine (y/n or Yes/No)?"
	if /I "%PREREQ%"=="n" call:PREREQUISITES
	if /I "%PREREQ%"=="no" call:PREREQUISITES
)
set /p TARGET="Enter the target machines IP or DNS name (DNS Names may need to be fully domain qualified):"
call:GETMACANDSENDINGIP
set /p USERNAME="Enter the username of the admin user to use:"
echo Next up will be running the actions but a password prompt will get the password from you for the specified username first.
call:pwd pw
REM echo.
REM echo.
REM echo now to determine if the action is 4
if /I "%ACTION%"=="4" (
	echo looks like the action is 4
	if /I "%OS%"=="WINDOWS" call:WSPECIFICSOFTWARE
	if /I "%OS%"=="MAC" call:MSPECIFICSOFTWARE
)
REM echo calling decisions.
call:DECISIONS

goto EOF

:PARAMETERS
if /I "%1"=="-d" set ACTION=1
if /I "%1"=="-u" set ACTION=2
if /I "%1"=="-a" set ACTION=3
if /I "%1"=="-i" set ACTION=4
REM Add something to catch if parameters are something not expected
if /I "%2"=="-w" set OSTYPE=Windows
if /I "%2"=="-m" set OSTYPE=MacOSX
REM Add something to catch if parameters are something not expected
if "%OSTYPE%" == "Windows" set OS=WINDOWS
if "%OSTYPE%" == "MacOSX" set OS=MAC
REM Add something in here to set the username target and then confirm if the password is provided or not
set TARGET=%3
set USERNAME=%5

REM If the password is being bypassed then parameter 6 will not be -p
REM Parameters 1-5 will always be fixed 6 could be flag for a password or could be a software pakage
REM Parameter 6 will be the determining factor for if to prompt for a password or not all other parameters should be good.
if /I "%6"=="-p" (
	REM echo looks like you have specified you will be providing a password
	set PW=%7
	set SOFTWARE=%8
) else (
	REM echo I am in the no password provided section.
	set SOFTWARE=%6
	call:pwd pw
)
REM echo time to output everything that I have got from the parameters:
REM echo Action:%ACTION%
REM echo OS Type:%OSTYPE%
REM echo Software:%SOFTWARE%
REM echo Target:%TARGET%
REM echo Username:%USERNAME%
REM echo Password:%PW%
REM echo next I should go to the appropritate action
if /I "%ACTION%"=="1" call:DECISIONS
if /I "%ACTION%"=="2" call:DECISIONS
if /I "%ACTION%"=="3" call:DECISIONS
if /I "%ACTION%"=="4" (
	REM The install of specific software was selected now I need to call the SpecificSoftware for either Windows or Mac
	if /I "%OS%"=="WINDOWS" (
		if /I "%SOFTWARE%"=="-7" (
			echo Installing 7-zip now.
			set SPECIFIC=1
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-au" (
			echo Installing Audacity now.
			set SPECIFIC=2
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-c" (
			echo Installing Chrome now.
			set SPECIFIC=3
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-e" (
			echo Installing Evernote now.
			set SPECIFIC=4
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-ftp" (
			echo Installing FileZilla now.
			set SPECIFIC=5
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-f" (
			echo Installing Firefox now.
			set SPECIFIC=6
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-g" (
			echo Installing GIMP now.
			set SPECIFIC=7
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-n" (
			echo Installing Notepad++ now.
			set SPECIFIC=8
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-tty" (
			echo Installing PuTTY now.
			set SPECIFIC=9
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-s" (
			echo Installing Skype now.
			set SPECIFIC=10
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-t" (
			echo Installing TeamViewer now.
			set SPECIFIC=11
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-v" (
			echo Installing VLC now.
			set SPECIFIC=12
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-j" (
			echo Installing Java now.
			set SPECIFIC=13
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-w" (
			echo Installing WebEx now.
			set SPECIFIC=14
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-r" (
			echo Installing WinRAR now.
			set SPECIFIC=15
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-z" (
			echo Installing Zoom now.
			set SPECIFIC=16
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-o" (
			echo Installing Microsoft Office now.
			set SPECIFIC=17
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-a" (
			echo Installing Adobe Reader now.
			set SPECIFIC=18
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-prn" (
			echo Installing Printers now.
			set SPECIFIC=19
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-sw" (
			echo Installing Spiceworks Agent Shell now.
			set SPECIFIC=20
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-nn" (
			echo Installing Ninite agent now.
			set SPECIFIC=21
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-any" (
			echo Installing Cisco AnyConnect now.
			set SPECIFIC=22
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-pdf" (
			echo Installing PDF Architect now.
			set SPECIFIC=23
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-browsers" (
			REM Need to set the specific software multiple times and then call wspecific multiple times
			echo Installing Chrome now.
			set SPECIFIC=3
			call:WSPECIFICSOFTWARE
			echo Installing FireFox now.
			set SPECIFIC=6
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-standard" (
			REM Need to set the specific software multiple times and then call wspecific multiple times
			echo Installing Chrome now.
			set SPECIFIC=3
			call:WSPECIFICSOFTWARE
			echo Installing FireFox now.
			set SPECIFIC=6
			call:WSPECIFICSOFTWARE
			echo Installing TeamViewer now.
			set SPECIFIC=11
			call:WSPECIFICSOFTWARE
			echo Installing VLC now.
			set SPECIFIC=12
			call:WSPECIFICSOFTWARE
			echo Installing Java now.
			set SPECIFIC=13
			call:WSPECIFICSOFTWARE
			echo Installing WinRAR now.
			set SPECIFIC=15
			call:WSPECIFICSOFTWARE
			echo Installing Adobe Reader now.
			set SPECIFIC=18
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-full" (
			REM Need to set the specific software multiple times and then call wspecific multiple times
			echo Installing Chrome now.
			set SPECIFIC=3
			call:WSPECIFICSOFTWARE
			echo Installing FireFox now.
			set SPECIFIC=6
			call:WSPECIFICSOFTWARE
			echo Installing TeamViewer now.
			set SPECIFIC=11
			call:WSPECIFICSOFTWARE
			echo Installing VLC now.
			set SPECIFIC=12
			call:WSPECIFICSOFTWARE
			echo Installing Java now.
			set SPECIFIC=13
			call:WSPECIFICSOFTWARE
			echo Installing WinRAR now.
			set SPECIFIC=15
			call:WSPECIFICSOFTWARE
			echo Installing Microsoft Office now.
			set SPECIFIC=17
			call:WSPECIFICSOFTWARE
			echo Installing Adobe Reader now.
			set SPECIFIC=18
			call:WSPECIFICSOFTWARE
			echo Installing Printers now.
			set SPECIFIC=19
			call:WSPECIFICSOFTWARE
			echo Installing Spiceworks Collection Agent now.
			set SPECIFIC=20
			call:WSPECIFICSOFTWARE
			echo Installing Ninite agent now.
			set SPECIFIC=21
			call:WSPECIFICSOFTWARE
			echo Installing Cisco AnyConnect now.
			set SPECIFIC=22
			call:WSPECIFICSOFTWARE
			echo Installing PDF Architect now.
			set SPECIFIC=23
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-all" (
			REM Need to set the specific software multiple times and then call wspecific multiple times
			for /L %%a in (1,1,23) do (
				if "%%a"=="1" echo Installing 7Zip now.
				if "%%a"=="2" echo Installing Audacity now.
				if "%%a"=="3" echo Installing Chrome now.
				if "%%a"=="4" echo Installing Evernote now.
				if "%%a"=="5" echo Installing FileZilla now.
				if "%%a"=="6" echo Installing FireFox now.
				if "%%a"=="7" echo Installing GIMP now.
				if "%%a"=="8" echo Installing Notepad++ now.
				if "%%a"=="9" echo Installing PuTTY now.
				if "%%a"=="10" echo Installing Skype now.
				if "%%a"=="11" echo Installing TeamViewer now.
				if "%%a"=="12" echo Installing VLC now.
				if "%%a"=="13" echo Installing Java now.
				if "%%a"=="14" echo Installing WebEx now.
				if "%%a"=="15" echo Installing WinRAR now.
				if "%%a"=="16" echo Installing Zoom now.
				if "%%a"=="17" echo Installing Microsoft Office now.
				if "%%a"=="18" echo Installing Adobe Reader now.
				if "%%a"=="19" echo Installing Printers now.
				if "%%a"=="20" echo Installing Spiceworks Collection Agent now.
				if "%%a"=="21" echo Installing Ninite agent now.
				if "%%a"=="22" echo Installing Cisco AnyConnect now.
				if "%%a"=="23" echo Installing PDF Architect now.
				set SPECIFIC=%%a
				call:WSPECIFICSOFTWARE
			)
		)
	)
	if /I "%OS%"=="MAC" (
		
		REM There is code below but needs to be works on before it will work.Also the calls are to WSPECIFICSOFTWARE instead of MSPECIFICSOFTWARE
		
		if /I "%SOFTWARE%"=="-7" (
			set SPECIFIC=1
		call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-au" (
			set SPECIFIC=2
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-c" (
			set SPECIFIC=3
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-e" (
			set SPECIFIC=4
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-ftp" (
			set SPECIFIC=5
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-f" (
			set SPECIFIC=6
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-g" (
			set SPECIFIC=7
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-n" (
			set SPECIFIC=8
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-tty" (
			set SPECIFIC=9
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-s" (
			set SPECIFIC=10
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-t" (
			set SPECIFIC=11
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-v" (
			set SPECIFIC=12
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-j" (
			set SPECIFIC=13
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-w" (
			set SPECIFIC=14
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-r" (
			set SPECIFIC=15
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-z" (
			set SPECIFIC=16
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-o" (
			set SPECIFIC=17
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-a" (
			set SPECIFIC=18
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-prn" (
			set SPECIFIC=19
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-sw" (
			set SPECIFIC=20
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-nn" (
			set SPECIFIC=21
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-any" (
			set SPECIFIC=22
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-pdf" (
			set SPECIFIC=23
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-browsers" (
			REM Need to set the specific software multiple times and then call wspecific multiple times
			set SPECIFIC=3
			call:WSPECIFICSOFTWARE
			set SPECIFIC=6
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-standard" (
			REM Need to set the specific software multiple times and then call wspecific multiple times
			set SPECIFIC=3
			call:WSPECIFICSOFTWARE
			set SPECIFIC=6
			call:WSPECIFICSOFTWARE
			set SPECIFIC=11
			call:WSPECIFICSOFTWARE
			set SPECIFIC=12
			call:WSPECIFICSOFTWARE
			set SPECIFIC=13
			call:WSPECIFICSOFTWARE
			set SPECIFIC=15
			call:WSPECIFICSOFTWARE
			set SPECIFIC=18
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-full" (
			REM Need to set the specific software multiple times and then call wspecific multiple times
			set SPECIFIC=3
			call:WSPECIFICSOFTWARE
			set SPECIFIC=6
			call:WSPECIFICSOFTWARE
			set SPECIFIC=11
			call:WSPECIFICSOFTWARE
			set SPECIFIC=12
			call:WSPECIFICSOFTWARE
			set SPECIFIC=13
			call:WSPECIFICSOFTWARE
			set SPECIFIC=15
			call:WSPECIFICSOFTWARE
			set SPECIFIC=17
			call:WSPECIFICSOFTWARE
			set SPECIFIC=18
			call:WSPECIFICSOFTWARE
			set SPECIFIC=19
			call:WSPECIFICSOFTWARE
			set SPECIFIC=20
			call:WSPECIFICSOFTWARE
			set SPECIFIC=21
			call:WSPECIFICSOFTWARE
			set SPECIFIC=22
			call:WSPECIFICSOFTWARE
			set SPECIFIC=23
			call:WSPECIFICSOFTWARE
		)
		if /I "%SOFTWARE%"=="-all" (
			REM Need to set the specific software multiple times and then call wspecific multiple times
			for /L %%a in (1,1,23) do (
				set SPECIFIC=%%a
				call:WSPECIFICSOFTWARE
			)
		)

	)
)
goto EOF

:SCRIPTUPDATE
REM echo I am in the script update section
REM I can grab the current version listing from github via curl -LJO  https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/Version.txt
REM echo I am in the script update section
if EXIST %CD%\Versions.txt del %CD%\Version.txt
curl -LJOs  https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/Version.txt > NUL
for /f "tokens=1-2 delims=:" %%a in ('FINDSTR /C:"Version:" Version.txt') do set CURRVER=%%b
if %CURRVER% LEQ %VERSION% echo well looks like we have the current version lets resume the script.
if "%CURRVER%" GTR "%VERSION%" (
	echo looks like there is a newer version
	curl -LJo newducs%CURRVER%.bat  https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/newducs.bat
	set /p RUNNEW="I have the new script version do you want to run it now (y/n or yes/no)?"
	if "%RUNNEW%"=="y" start newducs%CURRVER%.bat s
	if "%RUNNEW%"=="yes" start newducs%CURRVER%.bat s
	copy newducs.bat newducs%VERSION%.bat
	GOTO EOF
)
del Version.txt
EXIT /b

:PREREQUISITES
REM echo I am in the prereqisits section and have a OS Type of %OSTYPE%
REM echo This section is going to need to provide instructions for running the prerequisites and potentially download the required files for running on the machine.
echo Hey looks like you specified that you have not run the initial setup. There are things that will need to be run on the target machine first
if /I "%OSTYPE%"=="m" call:PREREQMAC
if /I "%OSTYPE%"=="Mac" call:PREREQMAC
if /I "%OSTYPE%"=="w" call:PREREQWIN
if /I "%OSTYPE%"=="windows" call:PREREQWIN
EXIT /b

:PREREQWIN
echo Looks like you are at the prerequisites for a Windows machine.
set /p GETPREREQS="Do you want to download the Prequisite files that you need to run on the target machine(y/n)?
if /I "%GETPREREQS%"=="y" (
	md %CD%\PREREQ
	curl -LJo -s %CD%\PREREQ\initialsetup.bat https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/initialsetup.bat
	curl -LJo -s %CD%\PREREQ\EnableRemote.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/EnableRemote.exe
	curl -LJo -s %CD%\PREREQ\SpiceworksAgentShell_Collection_Agent.msi https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/SpiceworksAgentShell_Collection_Agent.msi
	curl -LJo -s %CD%\PREREQ\spiceworkssitekey.txt https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/spiceworkssitekey.txt
	curl -LJo -s %CD%\PREREQ\systemupdate5.07.0070.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/systemupdate5.07.0070.exe
	echo All files have been downloaded into a folder called %CD%\PREREQ please transfer these files to the target machine and then run them.
)
set /p GTEINSTRUCTIONS="Do you want to have instructions for running the prerequisites(y/n)?
if /I "%GETINSTRUCTIONS%"=="y" (
	echo Please run the programs on the target machine in the below order.
	echo 1. Run EnableRemote.exe as administrator and press OK on all the prompts.
	echo 2. Run initialsetup.bat as administrator and close the window when done.
	echo 3. Open spiceworkssitekey.txt and copy the site key in the document to clipboard
	echo 4. Run SpiceworksAgentShell_Collection_Agent.msi as administrator and follow the prompts providing the site key when required
	echo 5. If this is a lenovo machine run systemupdate5.07.0070.exe on the machine to install Lenovo's system update
	echo.
	echo.
	echo Now that you have run the prerequisites if you do not already have the machines IP or DNS name record it now to continue on this script
)
EXIT /b

:PREREQMAC
echo Looks like you are at the prerequisites for a MacOSX machine
set /p GTEINSTRUCTIONS="Do you want to have instructions for running the prerequisites(y/n)?
if /I "%GETINSTRUCTIONS%"=="y" (
	echo For MacOSX machines you will need to make a few settings changes in system preferences steps are below.
	echo 1. Open the system preferences by clicking on the apple symbol them system preferences or via finder for system preferences.
	echo 2. Next go to Sharing
	echo 3. Check the Remote Login option and then remove administrators and press the plus and add sysadmin or whichever admin user is setup
	echo 4. At the top of that window change the Computer Name to an appropriate one for the machine 
	echo 		(typically in the format of first initial then last name then the year of purchase and if it is a PD laptop -PD at the end
	echo 		example JSMITH2022 or JDOE2022-PD).
	echo 5. Click on Edit to ensure that the computer name is set on the DNS Local host name as well.
	echo 6. If you will be running this script on a machine that is not plugged in you may need to change the power setting so it doesn't fall asleep during the process
	echo.
	echo.
	echo Now that you have run the prerequisites if you do not already have the machines IP or DNS name record it now to continue on this script
)
EXIT /b

:DECISIONS
REM echo OK Lets review you selection before we get started. You selected Action:%ACTION% on a OS Type:%OS% with username:%USERNAME%. Let go.
PAUSE
cls
if /I "%OS%"=="WINDOWS" (
	if %ACTION%==1 call:WDEPLOY
	if %ACTION%==2 call:WUPDATE
	if %ACTION%==3 call:WAUDIT
)
if /I "%OS%"=="MAC" (
	if %ACTION%==1 call:MDEPLOY
	if %ACTION%==2 call:MUPDATE
	if %ACTION%==3 call:MAUDIT
)
GOTO EOF



:WDEPLOY
echo The Process is staring now. This process can take over 10 minutes please wait.
echo ------------------------------------------------------------------------------------------------------------------
echo %today%%time%: Starting the Deployment process first need to get and generate the required files.
echo %today%%time%: deploying on machine %TARGET% >>%CD%\logs\report%TARGET%%today%.txt
echo %today%%time%:Deleting existing batch files if they exist >>%CD%\logs\report%TARGET%%today%.txt
if exist %CD%\Deploy\inst2016ato.bat del %CD%\Deploy\inst2016ato.bat
if exist %CD%\Deploy\hideupdates.bat del %CD%\Deploy\hideupdates.bat
if exist %CD%\Deploy\MSUpdates.bat del %CD%\Deploy\MSUpdates.bat
if exist %CD%\Deploy\satslinstall.bat del %CD%\Deploy\satslinstall.bat
if exist %CD%\Deploy\addprinters.bat del %CD%\Deploy\addprinters.bat
echo %today%%time%:Generating new batch files >>%CD%\logs\report%TARGET%%today%.txt
if NOT EXIST %CD%\Deploy\ md %CD%\DEPLOY
call:WOFFICEINSTALL
call:WHIDEUPDATES
call:WMSUPDATES
call:WSPICEANDNINITE
call:WPRINTERS
call:WSYSTEMINFO
echo %today%%time%: deployment scripts have been created >> %CD%\logs\report%TARGET%%today%.txt
echo now I am just going download the additional required files >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\Hideupdates.vbs https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/Hideupdates.vbs >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\wsusupdate.vbs https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/wsusupdate.vbs >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\SpiceworksAgentShell_Collection_Agent.msi https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/SpiceworksAgentShell_Collection_Agent.msi >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\NinitePro.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/NinitePro.exe >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\NiniteAgent.msi https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/NiniteAgent.msi >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\SHColor.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/SHColor.exe >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\SHBW.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/SHBW.exe >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\LibBW.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/LibBW.exe >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\LibColor.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/LibColor.exe >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\7za.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/7za.exe >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\7za.dll https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/7za.dll >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\7zxa.dll https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/7zxa.dll >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\PsExec.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/PsExec.exe >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\setup.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/setup.exe >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\configuration-Office365-x64.xml https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/configuration-Office365-x64.xml >> %CD%\logs\report%TARGET%%today%.txt

echo %today%%time%: Time to copy the required files to the system >> %CD%\logs\report%TARGET%%today%.txt
REM 1. map to the admin share for copying files
echo %today%%time%: Mapping admin share for connection >> %CD%\logs\report%TARGET%%today%.txt
if exist x: net use x: /delete > NUL
net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME% > NUL
REM 1. make a directory for the files
if not exist x:\sju md x:\sju > NUL
REM 1. copy all the deployment files to the machine
echo %today%%time%: Copying files to the share >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Copying files to the system...PLEASE WAIT...
xcopy %CD%\Deploy\*.* x:\sju /E/Y/Q > NUL
echo %today%%time%: Copy of files is complete - now for the installations
echo %today%%time%: Files copied to the share ended with error level:%errorlevel% >> %CD%\logs\report%TARGET%%today%.txt
REM 2. Install .net - prerequisit for office 2013 and spiceworks agent
echo %today%%time%: Installing Dot net >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Installing Dot net
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select  ".NET 4.5"	".NET 3.5" /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%dotnetINSTALL.csv
echo %today%%time%: Installed Dot net
echo %today%%time%: Dot net installed with errorlevel:%errorlevel% >> %CD%\logs\report%TARGET%%today%.txt
REM 3. run the install of Windows 7 SP1 this will install then restart need to perform a ping check after this task is done
REM LEGACY echo %today%%time%: Install Windows 7 SP1 if applicable >> %CD%\logs\report%TARGET%%today%.txt
REM LEGACY start "Install SP1 if this is a windows 7 machine"  /wait psexec -s \\%TARGET% -u sysadmin -p %pw% c:\Windows\SJU\W7SP1install.bat >> %CD%\logs\report%TARGET%%today%.txt
REM LEGACY echo SP1 checked/installed >> %CD%\logs\report%TARGET%%today%.txt
REM 3. PING test waiting for machine to come back up by calling health
echo %today%%time%: Call health to see if the machine is back online >> %CD%\logs\report%TARGET%%today%.txt
REM echo %today%%time%:waiting for 30 seconds for the restart of the machine
REM timeout /T 30 /NOBREAK
call:HEALTH
REM 3. check to make sure that the machine did come back online and if it didn't error and exit
if "%wakeupfailed%"=="1" (
echo %today%%time%:The machine has not come back online after installing SP1 there could be a problem >> %CD%\logs\report%today%.txt
EXIT /b
)
REM 4. NEXT is the install of office which will also activate windows and Office 365
echo %today%%time%: Installing Office 365 x64 >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Installing Office 365 x64...This can take several minutes please wait.
start "Install Office 365 x64"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% c:\Windows\SJU\inst365ato.bat >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%:Office365 install and activate >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Office365 install and activation completed. The machine should be restating now Please Wait.....

echo %today%%time%: Call health to see if the machine is back online >> %CD%\logs\report%TARGET%%today%.txt
REM echo %today%%time%: Waiting for 30 seconds for the restart of the machine
timeout /T 10 /NOBREAK > NUL
call:HEALTH
echo %today%%time%: Lets install the spiceworks agent now. >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Lets install the spiceworks and Ninite agents now.
start "Install Spiceworks  and Ninite Agents" /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% c:\Windows\SJU\satslinstall.bat >> %CD%\logs\report%TARGET%%today%.txt

REM 8. Install of Standard Software
echo %today%%time%: Install all other software >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Install all other software
call:WINSTALL
echo %today%%time%: Installed all software >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Installed all software


REM 9. install Printers
echo %today%%time%: Install the printers >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Install the printers *Please note this sometime will cause an error on the target machine that it can not set the default printer so you will need to click OK for this to finish.
start "ADD SJU Printer"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% -i c:\Windows\SJU\addprinters.bat >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Installed the printers >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Installed the printers


rem 10. Remove batch files from machine and current directory
echo %today%%time%: Cleanup time >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Get the system Information >> %CD%\logs\report%TARGET%%today%.txt
start "Get System Info"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% -i c:\Windows\SJU\systeminfo.bat
copy x:\sju\%TARGET%sysinfo.txt %cd%\logs\%TARGET%sysinfo.txt
echo %today%%time%:I should have a proper sysinfo now.
PAUSE

del x:\SJU\*.* /S /Q > NUL
rmdir /S /Q x:\sju > NUL
del %CD%\Deploy\inst365ato.bat > NUL
del %CD%\Deploy\hideupdates.bat > NUL
del %CD%\Deploy\MSUpdates.bat > NUL
del %CD%\Deploy\satslinstall.bat > NUL
del %CD%\Deploy\addprinters.bat > NUL
del %CD%\Deploy\systeminfo.bat > NUL
net use x: /delete  > NUL
goto END

:WINSTALL
if "%TARGET:~0,3%"=="172" (
echo %today%%time%:I have a 172 address maybe I can get the dns name and then get the MAC to attempt a wakeup but skipping for now >> %CD%\logs\report%today%.txt
)
if "%TARGET:~0,3%"=="129" (
echo %today%%time%:I have a 129 address maybe I can get the dns name and then get the MAC to attempt a wakeup but skipping for now >> %CD%\logs\report%today%.txt
)
echo %today%%time%:Performing audit on:%TARGET% with MAC:%PHY% >> %CD%\logs\report%today%.txt
REM echo %today%%time%: Waking up %TARGET%...Please Wait
call:HEALTH REM THis will check for the machines health do an NSLOOKUP if required and try to wakeup the machine
if "%wakeupfailed%"=="1" (
echo %today%%time%: Wakeup of machine:%TARGET% unsuccessful skipping this machine >> %CD%\logs\report%today%.txt
EXIT /b
)
echo The machine is awake time for it's INSTALL. >> %CD%\logs\report%today%.txt
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Reader "Java (Oracle) x64 8" VLC Firefox WinRAR ".NET 4.8" "TeamViewer 15" /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%INSTALL1.csv
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Chrome /allusers /disableshortcuts /silent %CD%\logs\%today%\%TARGET%INSTALL2.csv
set status=0
for /F "delims=" %%b in ('find /c "Partial" %CD%\logs\%today%\%TARGET%INSTALL1.csv') do set status=%%b
if %status:~-1% GEQ 1 echo System:%TARGET% is only Partially up-to-date >> %CD%\logs\report%today%.txt
for /F "delims=" %%b in ('find /c "Failed" %CD%\logs\%today%\%TARGET%INSTALL1.csv') do set status=%%b
if %status:~-1% GEQ 1 echo System:%TARGET% Something Failed during the INSTALL >> %CD%\logs\report%today%.txt
for /F "delims=" %%b in ('find /c "OK" %CD%\logs\%today%\%TARGET%INSTALL1.csv') do set status=%%b
if %status:~-1% GEQ 1 echo System:%TARGET% OK - All software is up-to-date >> %CD%\logs\report%today%.txt
REM LEGACY cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u sysadmin -p %pw% "c:\Program Files (x86)\Symantec\Symantec Endpoint Protection\SepLiveUpdate.exe"
REM cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% net stop spiceworksagent
REM cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% net start spiceworksagent
EXIT /b

:WUPDATE
echo The update process is staring now. This process can take a few minutes please wait.
echo ------------------------------------------------------------------------------------------------------------------
rem Check the health of the machine and determine if IP or dns name then wakeup if able then audit
REM echo %today%%time%:time to set my variables
REM if "%TARGET:~0,3%"=="172" (
REM echo %today%%time%:I have a 172 address maybe I can get the dns name and then get the MAC to attempt a wakeup but skipping for now
REM )
REM if "%TARGET:~0,3%"=="129" (
REM echo %today%%time%:I have a 129 address maybe I can get the dns name and then get the MAC to attempt a wakeup but skipping for now
REM )
echo %today%%time%:Starting an update on:%TARGET% with MAC:%PHY%
REM echo %today%%time%: Waking up %TARGET%...Please Wait
call:HEALTH REM THis will check for the machines health do an NSLOOKUP if required and try to wakeup the machine
if "%wakeupfailed%"=="1" (
echo Wakeup of machine:%TARGET% unsuccessful skipping this machine >> %CD%\logs\report%today%.txt
EXIT /b
)
echo %today%%time%:Updating system:%TARGET% Please wait.
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /updateonly /silent %CD%\logs\%today%\%TARGET%UPDATE.csv
set status=0
for /F "delims=" %%b in ('findstr /B /C:"Partial" %CD%\logs\%today%\%TARGET%UPDATE.csv') do set status=%%b
if "%STATUS%"=="Partial" (
	echo %today%%time%:System:%TARGET% is only Partially up-to-date >> %CD%\logs\report%today%.txt
	echo %today%%time%:System:%TARGET% is only Partially up-to-date
)
for /F "delims=" %%b in ('findstr /B /C:"Failed" %CD%\logs\%today%\%TARGET%UPDATE.csv') do set status=%%b
if "%STATUS%"=="FAILED" (
	echo %today%%time%:System:%TARGET% Something Failed during the UPDATE >> %CD%\logs\report%today%.txt
	echo %today%%time%:System:%TARGET% Something Failed during the UPDATE
)
for /F "delims=" %%b in ('findstr /B /C:"OK" %CD%\logs\%today%\%TARGET%UPDATE.csv') do set status=%%b
if "%STATUS%"=="OK" (
	echo %today%%time%:System:%TARGET% OK - All software is up-to-date >> %CD%\logs\report%today%.txt
	echo %today%%time%:System:%TARGET% OK - All software is up-to-date
)
REM echo so I ended with a status of:%STATUS%
REM if exist x: net use x: /delete
REM net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME%
REM 1. make a directory for the files
REM if not exist x:\sju md x:\sju > NUL 
REM xcopy %CD%\Deploy\satsl.* x:\sju /E/Y/Q > NUL
REM net use x: /delete > NUL
EXIT /b


:WAUDIT
echo The audit process is staring now. This process can take a few minutes please wait.
echo ------------------------------------------------------------------------------------------------------------------
curl -s -LJo %CD%\PsExec.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/PsExec.exe >> %CD%\logs\report%TARGET%%today%.txt
call:WSYSTEMINFO
if exist x: net use x: /delete > NUL
net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME% > NUL
REM 1. make a directory for the files
if not exist x:\sju md x:\sju > NUL
xcopy %CD%\Deploy\systeminfo.bat x:\sju /E/Y/Q > NUL
rem Check the health of the machine and determine if IP or dns name then wakeup if able then audit
echo %today%%time%:Waking up %TARGET%...Please Wait
call:HEALTH REM THis will check for the machines health do an NSLOOKUP if required and try to wakeup the machine
if "%wakeupfailed%"=="1" (
echo Wakeup of machine:%TARGET% unsuccessful skipping this machine >> %CD%\logs\report%today%.txt
EXIT /b
)
call:GETMACANDSENDINGIP
echo %today%%time%:looks like the machine is awake time for it's audit.
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /audit /silent %CD%\logs\%today%\%TARGET%AUDIT.csv >> %CD%\logs\report%today%.txt
set status=0
for /F "delims=" %%b in ('findstr /B /C:"Partial" %CD%\logs\%today%\%TARGET%UPDATE.csv') do set status=%%b
if "%STATUS%"=="Partial" (
	echo %today%%time%:System:%TARGET% is only Partially up-to-date >> %CD%\logs\report%today%.txt
	echo %today%%time%:System:%TARGET% is only Partially up-to-date
)
for /F "delims=" %%b in ('findstr /B /C:"Failed" %CD%\logs\%today%\%TARGET%UPDATE.csv') do set status=%%b
if "%STATUS%"=="FAILED" (
	echo %today%%time%:System:%TARGET% Something Failed during the UPDATE >> %CD%\logs\report%today%.txt
	echo %today%%time%:System:%TARGET% Something Failed during the UPDATE
)
for /F "delims=" %%b in ('findstr /B /C:"OK" %CD%\logs\%today%\%TARGET%UPDATE.csv') do set status=%%b
if "%STATUS%"=="OK" (
	echo %today%%time%:System:%TARGET% OK - All software is up-to-date >> %CD%\logs\report%today%.txt
	echo %today%%time%:System:%TARGET% OK - All software is up-to-date
)

start "Get System Info"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% -i c:\Windows\SJU\systeminfo.bat
copy x:\sju\%TARGET%sysinfo.txt %cd%\logs\%TARGET%sysinfo.txt
del x:\SJU\*.* /S /Q > NUL
rmdir /S /Q x:\sju > NUL
del %CD%\Deploy\systeminfo.bat > NUL
net use x: /delete  > NUL
REM cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% systeminfo >> %CD%\logs\report%today%.txt
REM cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% wmic product get name,version >> %CD%\logs\report%today%.txt
REM cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% net stop spiceworksagent >> %CD%\logs\report%today%.txt
REM cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% net start spiceworksagent >> %CD%\logs\report%today%.txt
EXIT /b

:WOFFICEINSTALL
(
echo @echo off
echo echo time to install office 365
echo if exist  "C:\Program Files ^(x86^)\Microsoft Office" ^(
echo echo Looks like a 32 bit version of office is already installed and the install can not continue 
echo exit
echo ^)
echo reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v LegacyDefaultPrinterMode /t REG_DWORD /d 00000001 /f
echo echo Now is the time to run the setup.exe with the configuration file
echo c:\windows\SJU\setup.exe /configure %systemroot%\sju\configuration-Office365-x64.xml  
echo echo Just got past the install Office 365 step
echo if "%%errorlevel%%"=="0" echo office 365x64 installed successfully
echo echo time to register Windows and Office
echo echo now time to activate windows
echo cscript c:\windows\system32\slmgr.vbs /skms licsrv5.uwaterloo.ca:1688
echo cscript c:\windows\system32\slmgr.vbs /ipk 33PXH-7Y6KF-2VJC9-XBBR8-HVTHH
echo cscript c:\windows\system32\slmgr.vbs /ato
echo echo and time to activate office
echo cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /inpkey:VYBBJ-TRJPB-QFQRF-QFT4D-H3GVB
echo cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /sethst:licsrv5.uwaterloo.ca
echo cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /setprt:1688
echo cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act  
echo cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /dstatus
echo echo time to restart following the installs
echo shutdown -r -t 10
echo timeout /T 20 /NOBREAK
)>%CD%\Deploy\inst365ato.bat
curl -s -LJo %CD%\DEPLOY\setup.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/setup.exe >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\DEPLOY\configuration-Office365-x64.xml https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/configuration-Office365-x64.xml >> %CD%\logs\report%TARGET%%today%.txt
REM start "Install Office 365 x64"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% c:\Windows\SJU\inst365ato.bat >> %CD%\logs\report%TARGET%%today%.txt
exit /b


:WHIDEUPDATES
(
echo @echo off
echo echo Lets hide the language updates
echo cscript c:\windows\SJU\Hideupdates.vbs
)>%CD%\Deploy\hideupdates.bat
exit /b


:WMSUPDATES
(
echo @echo off
echo lets install windows updates
echo cscript c:\windows\SJU\wsusupdate.vbs
echo shutdown -r -t 10
)>%CD%\Deploy\MSUpdates.bat
exit /b

:WSPICEANDNINITE
(
echo @echo off
echo echo installing spiceworks and Ninite
echo msiexec /i c:\Windows\sju\SpiceworksAgentShell_Collection_Agent.msi site_key="bwjRlmFTlQ4vQRSW5hL6" /q /norestart
REM echo msiexec /i c:\Windows\sju\satsl.msi spiceworks_server=172.25.122.43 spiceworks_auth_key="7sqCCaA+y6mkqOwGZszgMEz0CEg=" spiceworks_port=4001 /q /norestart
echo msiexec -i c:\Windows\sju\NiniteAgent.msi /q /norestart
)>%CD%\Deploy\satslinstall.bat
exit /b

:WPRINTERS
REM echo Creating the Printer batch
(
echo @echo off
REM echo reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v LegacyDefaultPrinterMode /t REG_DWORD /d 00000001 /f
echo REM SH MAILROOM Colour Copier /Printer
echo echo Installing the SHColour Printer
echo cmd /c start /wait c:\Windows\SJU\SHColor.exe /Quiet
echo REM SH MAILROOM Copier /Printer
echo echo Installing the SHBW Printer
echo cmd /c start /wait c:\Windows\SJU\SHBW.exe /Quiet
echo REM Library Copier /Printer
echo echo Installing the LIBBW Printer
echo cmd /c start /wait c:\Windows\SJU\LibBW.exe /Quiet
echo REM Library Colour Copier /Printer
echo echo Installing the LIBCOLOUR Printer
echo cmd /c start /wait c:\Windows\SJU\LibColor.exe /Quiet
)>%CD%\Deploy\addprinters.bat
exit /b

:WSYSTEMINFO
(
echo @echo off
echo msinfo32 /report c:\windows\sju\%TARGET%sysinfo.txt
)>%CD%\Deploy\systeminfo.bat
exit /b

:HEALTH
set wakeupfailed=0
REM check to see if an IP was provided then bypass this because I cannot wakeup if no name is given
if "%TARGET:~0,3%"=="172" (
echo %today%%time%:I have a 172 address maybe I can get the dns name and then get the MAC to attempt a wakeup >> %CD%\logs\report%today%.txt
)
if "%TARGET:~0,3%"=="129" (
echo %today%%time%:I have a 129 address maybe I can get the dns name and then get the MAC to attempt a wakeup >> %CD%\logs\report%today%.txt
)
echo %today%%time%:I am past the IP Check >> %CD%\logs\report%today%.txt
set piping=0
ping -n 1 %TARGET% -4|find "TTL="  > NUL
if NOT "%errorlevel%"=="0" (
	REM the machine is not responding to ping lets do an nslookup to see if it is in the dns server
	echo %today%%time%: machine did not respond to a ping >> %CD%\logs\report%today%.txt
	set piping=1
) 
if "%piping%"=="0" (
rem This means the machine responded on the first ping attempt

rem should not get here unless the machine responded on first ping attempt and was a DNS name
EXIT /b
)
set wakeupfailed=0
call:WAKEUP
timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL="  > NUL
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%: machine did not respond to a ping #2 >> %CD%\logs\report%today%.txt

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL=" > NUL
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #3 >> %CD%\logs\report%today%.txt

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL=" > NUL
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #4 >> %CD%\logs\report%today%.txt

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL=" > NUL
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #5 >> %CD%\logs\report%today%.txt

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL=" > NUL
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #6 >> %CD%\logs\report%today%.txt

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL=" > NUL
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #7 >> %CD%\logs\report%today%.txt

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL=" > NUL
if "%errorlevel%"=="0" EXIT /b 
echo %today%%time%:machine did not respond to a ping #8 >> %CD%\logs\report%today%.txt

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL=" > NUL
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #9 >> %CD%\logs\report%today%.txt

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL=" > NUL
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #10 >> %CD%\logs\report%today%.txt

set wakeupfailed=1
echo Failed to get a connection to %TARGET% after a WOL and 10 ping attempts >> %CD%\logs\report%today%.txt
EXIT /b

:WAKEUP
REM This will not be working now and will dependant on getting the MAC address and the local IP that it will be sent from.
if %PHY%==NUL (
	echo Looks like I can't get the MAC address not going to be able to wake the target
	EXIT /b
)
echo %today%%time%: Waking Up %PHY%
curl -LJo -s %CD%\wol.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/wol.exe
wol %PHY% %HOSTIP%
set pingcount=0
echo %today%%time%: Trying to wake up:%TARGET%
rem call:PINGSTART REM aftre a return return back and a check for wakeup failed will need to be performed and then the device is skipped if it failed.
EXIT /b

:WSPECIFICSELECT
REM Need to create a list of availible software for Windows which can be installed to the taregt machine
cls
echo                       Welcome to the Software selection options. 
echo Below is a list of availible software products please select the desired software to install on the target. 
echo You will be returned to this selection after your previous selection is completed.
echo.
echo.
echo 1.  7Zip - Compression Utility (7-Zip)
echo 2.  Audacity - Audio editing software (Audacity)
echo 3.  Chrome - Internet Browser (Chrome)
echo 4.  Evernote - Note management system (Evernote)
echo 5.  Filezilla - FTP and SFTP protocol application (FileZilla)
echo 6.  Firefox - Internet Broswer (Firefox)
echo 7.  GIMP - Photo editing software (GIMP)
echo 8.  Notepad ++ - Text editing program (Notepad++)
echo 9.  Putty - Remote console connection program (SSH, Telenet and others)(PuTTY)
echo 10. Skype - Standard Skype not skype for business (Skype)
echo 11. TeamViewer 15 - Remote connection and support program (TeamViewer)
echo 12. VLC - Media Player (VLC)
echo 13. Java - Web protocol and application system (Java x64)
echo 14. WebEx - Video conferencing software (WebEx)
echo 15. WinRar - Compression Utility (WinRAR)
echo 16. Zoom - Video conferencing software (Zoom)
echo 17. Microsoft Office - Office Suite *Restart required
echo 18. Adobe Reader - PDF Reader (Reader)
echo 19. Add mailroom and Library printers *Restart required
echo 20. Spiceworks Collection Agent
echo 21. Ninite agent
echo 22. Cisco AnyConnect
echo 23. PDF Architect for editing PDFs
echo 0.  Exit
set /p SPECIFIC="Enter the number for the software you would like to install:"
call:WSPECIFICSOFTWARE
PAUSE
call:WSPECIFICSELECT


:WSPECIFICSOFTWARE
REM Need to create a list of availible software for Windows which can be installed to the taregt machine
curl -s -LJo %CD%\NinitePro.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/NinitePro.exe >> %CD%\logs\report%TARGET%%today%.txt
curl -s -LJo %CD%\PsExec.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/PsExec.exe >> %CD%\logs\report%TARGET%%today%.txt
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select  ".NET 4.5"	".NET 3.5" /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%dotnetINSTALL.csv
if "%SPECIFIC%"=="0" (
	REM Exit
	REM echo I got to the exit
	del x:\SJU\*.* /S /Q > NUL
	rmdir /S /Q x:\sju > NUL
	net use x: /delete
	GOTO EOF
)
if %SPECIFIC%==1 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select "7-Zip" /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==2 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Audacity /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==3 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Chrome /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==4 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Evernote /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==5 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select FileZilla /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==6 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Firefox /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==7 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select GIMP /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==8 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select "Notepad++" /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==9 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select PuTTY /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==10 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Skype /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==11 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select TeamViewer /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==12 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select VLC /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==13 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select "Java (Oracle) x64 8" /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==14 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select WebEx /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==15 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select WinRAR /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==16 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Zoom /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==18 (
	cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Reader /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%specific.csv
	echo Operation completed. Please confirm on the local machine.
	exit /b
)
if %SPECIFIC%==17 (
	REM This is the Office 365 install and licensing conditions Need to build the install batch file download the install files tranfer to the machine and then install
	REM curl -s -LJo %CD%\DEPLOY\setup.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/setup.exe >> %CD%\logs\report%TARGET%%today%.txt	
	REM curl -s -LJo %CD%\DEPLOY\configuration-Office365-x64.xml https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/configuration-Office365-x64.xml >> %CD%\logs\report%TARGET%%today%.txt
	call:WOFFICEINSTALL
	net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME% > NUL
	REM 1. make a directory for the files
	if not exist x:\sju md x:\sju > NUL
	REM 1. copy all the deployment files to the machine
	xcopy %CD%\Deploy\setup.exe x:\sju /E/Y/Q > NUL
	xcopy %CD%\Deploy\configuration-Office365-x64.xml x:\sju /E/Y/Q > NUL
	xcopy %CD%\Deploy\inst365ato.bat x:\sju /E/Y/Q > NUL
	start "Install Office 365 x64"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% c:\Windows\SJU\inst365ato.bat >> %CD%\logs\report%TARGET%%today%.txt
	echo Office 365 should now be installed and licensed please confirm.
	echo Operation completed. Please confirm on the local machine.
	del %CD%\Deploy\setup.exe /S /Q > NUL
	del %CD%\Deploy\configuration-Office365-x64.xml /S /Q > NUL
	del %CD%\Deploy\inst365ato.bat /S /Q > NUL
	del x:\SJU\*.* /S /Q > NUL
	rmdir /S /Q x:\sju > NUL
	net use x: /delete
	exit /b
)
if %SPECIFIC%==19 (
	REM Add printers
	call:WPRINTERS
	echo @echo off > %CD%\Printersetup.bat
	echo reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v LegacyDefaultPrinterMode /t REG_DWORD /d 00000001 /f >> %CD%\Printersetup.bat
	echo echo shutdown -r -t 10 >> %CD%\Printersetup.bat
	curl -s -LJo %CD%\DEPLOY\SHColor.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/SHColor.exe >> %CD%\logs\report%TARGET%%today%.txt
	curl -s -LJo %CD%\DEPLOY\SHBW.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/SHBW.exe >> %CD%\logs\report%TARGET%%today%.txt
	curl -s -LJo %CD%\DEPLOY\LibBW.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/LibBW.exe >> %CD%\logs\report%TARGET%%today%.txt
	curl -s -LJo %CD%\DEPLOY\LibColor.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/LibColor.exe >> %CD%\logs\report%TARGET%%today%.txt
	net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME% > NUL
	if not exist x:\sju md x:\sju > NUL
	xcopy %CD%\Printersetup.bat x:\sju /E/Y/Q > NUL
	xcopy %CD%\Deploy\addprinters.bat x:\sju /E/Y/Q > NUL
	xcopy %CD%\Deploy\SHColor.exe x:\sju /E/Y/Q > NUL
	xcopy %CD%\Deploy\SHBW.exe x:\sju /E/Y/Q > NUL
	xcopy %CD%\Deploy\LibBW.exe x:\sju /E/Y/Q > NUL
	xcopy %CD%\Deploy\LibColor.exe x:\sju /E/Y/Q > NUL
	start "ADD SJU Printer"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% -i c:\Windows\SJU\Printersetup.bat >> %CD%\logs\report%TARGET%%today%.txt
	timeout /T 20 /NOBREAK
	start "ADD SJU Printer"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% -i c:\Windows\SJU\addprinters.bat >> %CD%\logs\report%TARGET%%today%.txt
	echo Operation completed. Please confirm on the local machine.
	del %CD%\DEPLOY\SHColor.exe /S /Q > NUL
	del %CD%\DEPLOY\SHBW.exe /S /Q > NUL
	del %CD%\DEPLOY\LibBW.exe /S /Q > NUL
	del %CD%\DEPLOY\LibColor.exe /S /Q > NUL
	del %CD%\Printersetup.bat /S /Q > NUL
	del %CD%\Deploy\addprinters.bat /S /Q > NUL
	del x:\SJU\*.* /S /Q > NUL
	rmdir /S /Q x:\sju > NUL
	net use x: /delete
	exit /b
)
if %SPECIFIC%==20 (
	REM INstall Spiceworks collection agent
	curl -s -LJo %CD%\DEPLOY\SpiceworksAgentShell_Collection_Agent.msi https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/SpiceworksAgentShell_Collection_Agent.msi >> %CD%\logs\report%TARGET%%today%.txt
	net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME% > NUL
	if not exist x:\sju md x:\sju > NUL
	xcopy %CD%\Deploy\SpiceworksAgentShell_Collection_Agent.msi x:\sju /E/Y/Q > NUL
	start "Install Spiceworks Collection Agent"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% -i msiexec /i c:\Windows\sju\SpiceworksAgentShell_Collection_Agent.msi site_key="bwjRlmFTlQ4vQRSW5hL6" /q /norestart >> %CD%\logs\report%TARGET%%today%.txt 
	echo Operation completed. Please confirm on the local machine.
	del %CD%\Deploy\SpiceworksAgentShell_Collection_Agent.msi /S /Q > NUL
	del x:\SJU\*.* /S /Q > NUL
	rmdir /S /Q x:\sju > NUL
	net use x: /delete
	exit /b
)
if %SPECIFIC%==21 (
	REM Install Ninite agent
	curl -s -LJo %CD%\DEPLOY\NiniteAgent.msi https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/NiniteAgent.msi >> %CD%\logs\report%TARGET%%today%.txt
	net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME% > NUL
	if not exist x:\sju md x:\sju > NUL
	xcopy %CD%\Deploy\NiniteAgent.msi x:\sju /E/Y/Q > NUL
	start "Install Ninite Agent"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% -i msiexec -i c:\Windows\sju\NiniteAgent.msi /q /norestart >> %CD%\logs\report%TARGET%%today%.txt  
	echo Operation completed. Please confirm on the local machine.
	del %CD%\Deploy\NiniteAgent.msi /S /Q > NUL
	del x:\SJU\*.* /S /Q > NUL
	rmdir /S /Q x:\sju > NUL
	net use x: /delete
	exit /b
)
if %SPECIFIC%==22 (
	REM Install Cisco AnyConnect
	curl -s -LJo %CD%\DEPLOY\anyconnectWin.msi https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/anyconnectWin.msi >> %CD%\logs\report%TARGET%%today%.txt
	net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME% > NUL
	if not exist x:\sju md x:\sju > NUL
	xcopy %CD%\Deploy\anyconnectWin.msi x:\sju /E/Y/Q > NUL
	start "Install Cisco AnyConnect"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% -i msiexec -i c:\Windows\sju\anyconnectWin.msi /q /norestart >> %CD%\logs\report%TARGET%%today%.txt  
	echo Operation completed. Please confirm on the local machine.
	del %CD%\Deploy\anyconnectWin.msi /S /Q > NUL
	del x:\SJU\*.* /S /Q > NUL
	rmdir /S /Q x:\sju > NUL
	net use x: /delete
	exit /b
)
if %SPECIFIC%==23 (
	REM Install PDF Architect
	curl -s -LJo %CD%\DEPLOY\PDFArc8.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/PDF_Architect_8_Installer.exe >> %CD%\logs\report%TARGET%%today%.txt
	net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME% > NUL
	if not exist x:\sju md x:\sju > NUL
	echo @echo off > %CD%\PDFARC.bat
	echo cmd /c start /wait c:\Windows\sju\PDFArc8.exe /quiet >> PDFARC.bat
	xcopy %CD%\Deploy\PDFArc8.exe x:\sju /E/Y/Q > NUL
	xcopy %CD%\PDFARC.bat x:\sju /E/Y/Q > NUL
	start "Install PDF Architect"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% -i c:\Windows\sju\PDFARC.bat >> %CD%\logs\report%TARGET%%today%.txt  
	echo Operation completed. Please confirm on the local machine.
	del %CD%\PDFARC.bat /S /Q > NUL
	del %CD%\Deploy\PDFArc8.exe /S /Q > NUL
	del x:\SJU\*.* /S /Q > NUL
	rmdir /S /Q x:\sju > NUL
	net use x: /delete
	exit /b
)

echo Well Crap it looks like you entered an invalid selection lets go back to the selection.
PAUSE
call:WSPECIFICSELECT



:MSPECIFICSOFTWARE

GOTO EOF

:GETMACANDSENDINGIP
ping %TARGET% >NUL
arp -a |findstr %TARGET% > targetarp.txt
for /f "tokens=1-2" %%c in ('FINDSTR /C:"%TARGET%" targetarp.txt') do set PHY=%%d
REM echo the mac I got is:%PHY%
set TARGETEND=%TARGET:~-3%
REM echo the end of the IP is:%TARGETEND% so if this character:%TARGETEND:~0,1% is a period it is a two digit ending IP.
if "%TARGETEND:~0,1%"=="." (
	REM echo looks like the target has a two character last octet
	ipconfig |findstr /C:"IPv4 Address" > IPHOST.txt 
	for /F "tokens=1-2 delims=:" %%e in ('FINDSTR /C:"%TARGET:~0,-2%" IPHOST.txt') do set HOSTIP=%%f
	exit /b
)
set TARGETEND=%TARGET:~-4%
REM echo the end of the IP is:%TARGETEND% so if this character:%TARGETEND:~0,1% is a period it is a three digit ending IP.
if "%TARGETEND:~0,1%"=="." (
	REM echo looks like the target has a three character last octet
	ipconfig |findstr /C:"IPv4 Address" > IPHOST.txt 
	for /F "tokens=1-2 delims=:" %%e in ('FINDSTR /C:"%TARGET:~0,-3%" IPHOST.txt') do set HOSTIP=%%f
	exit /b
)
exit /b




:REPORT
echo.
echo.
echo.
echo SKIPPED MACHINES
for /F "delims=" %%a in ('findstr /i /C:"unsuccessful"  %CD%\logs\report%today%.txt') do echo %%a
echo.
echo FAILED MACHINES
for /F "delims=" %%a in ('findstr /i /C:"Failed"  %CD%\logs\report%today%.txt') do echo %%a
echo.
echo PARTIAL MACHINES
for /F "delims=" %%a in ('findstr /i /C:"Partial"  %CD%\logs\report%today%.txt') do echo %%a
echo.
echo OK MACHINES
for /F "delims=" %%a in ('findstr /i /C:"OK"  %CD%\logs\report%today%.txt') do echo %%a
EXIT /b




:HELP
echo Deploy, Audit, Update or Install software on a machine
echo.
echo DUCS [ACTION] [OSTYPE]  [TARGET] -u [USERNAME]  -p [PASSWORD] [PACKAGE - IF ACTION IS INSTALL]
echo.
echo *All Parameters except for Password and software Package are required.
echo    Action 
echo    	-d Deployment of a machine - This will perform several actions and install multiple pieces of software
echo    	-u Update - This will update as many pieces of software on the machine as possible
echo    	-a Audit - This will audit the machine and collect information about the machine and provide a report
echo 		-i Install a specific piece of software on the target machine
echo	OS TYPE
echo 		-w Windows Machine
echo 		-m MacOSX machine
echo    Package #- Indicated Not availible with Mac's
echo		-c Chrome
echo		-f firefox
echo		-r WinRAR #
echo		-n Notepad++ #
echo		-a Adobe Reader
echo		-j Java 
echo		-v VLC
echo 		-7 7Zip #
echo 		-au Audacity #
echo 		-e Everynote #
echo 		-ftp FileZilla #
echo 		-g GIMP #
echo 		-tty PuTTY #
echo 		-s Skype #
echo 		-t TeamViewer
echo 		-w WebEX #
echo 		-z Zoom #
echo 		-o Microsoft Office 365 also Licenses vis KMS
echo 		-uo Microsoft Office 365 Unlicensed
echo 		-prn Mailroom and Library Printers #
echo 		-sw Spiceworks Collection Agent #
echo 		-nn Ninite agent #
echo 		-any Cisco AnyConnect #
echo 		-pdf PDF Architect #
echo		-browsers Chrome & firefox
echo		-standard Chrome, Firefox, Adobe Reader, Java, WinRAR and VLC
echo 		-full Microsoft Office 365 (licensed), Chrome, Firefox, Adobe Reader, Java, TeamViewer, Printers, Cisco AnyConnect, PDF Architect, WinRAR and VLC #
echo		-all All Software listed above including Microsoft Office 365 (Licensed)
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
echo		DUCS -i -w  xxx.xxx.xxx.xxx -u sysadmin -p PASSWORDHERE -all
echo	INSTALL A SPECIFIC SOFTWARE PACKAGE WITH BEING PROMPTED FOR THE PASSWORD
echo		DUCS -i -w  xxx.xxx.xxx.xxx -u sysadmin -all
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

:END
echo if you would like to view a full report on these actions please open %CD%\logs\report%TODAY%.txt
REM type %CD%\logs\report%today%.txt
call:REPORT
PAUSE
EXIT

:EOF
echo Well looks like we are at the end of the script. Press enter to exit and close this window.
PAUSE
EXIT