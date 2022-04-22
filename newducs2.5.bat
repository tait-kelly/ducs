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

REM 2016-03-30 -instead of going to help with no paramater could go to a prompt for questions of what you want to run get group or individual then action and software if install and then do a start same script with a wait and a pause and go to end.
REM 2016-03-30 - Could perform a backup of this script to a backup folder to provide versioning in the future as well
REM =================================NOTES============================================================

REM =====================KNOWN ISSUES=============================================================
REM 2022-04-19 Ninite agent and spiceworks agent shell are not installing correctly need to fix.
REM 2022-04-19 Need to remove a lot of output for a cleaner interface
REM 2022-04-19 Need to remove restart after copying files
REM 2022-04-07 All Windows Actions not tested
REM 2022-04-11 Windows Specific software actions are not programmed yet.
REM 2022-04-08 Printers function is not working correct from old script
REM 2022-04-08 Final reporting is not always working as it gets duplicate enties at times
REM 2022-04-08 Missing Error reports in script
REM 2022-04-08 Wakeup wol call is using an assumed static IP and should be changed to dynamic based on machine it is run on
REM 2022-04-08 Script update call is not working: need to determine a online location for the required files and credentials to be used to download when needed RESOLVED 2022-04-07
REM 2022-04-08 dependancies need to be downloaded from an online location if not existing and win.csv file needs to be removed from depenancies RESOLVED 2022-04-08
REM 2022-04-11 sysadmin references used instead of %USRENAME% RESOLVED 2022-04-13
REM 2022-04-11 IP variable references instead of %TARGET% RESOLVED 2022-04-13
REM 2022-04-11 Static paths are used in some instances need to change to %CD% RESOLVED 2022-04-13
REM =====================KNOWN ISSUES - AS OF 2022-04-07=============================================================


set VERSION=2.4
set COMPILED=April 21st, 2022
set GITHUBKEY=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
set TITLE=Welcome to the new DUCS script version %VERSION% compiled on %COMPILED%
echo I am creating the logs folder now
if NOT EXIST "%CD%\logs\" mkdir %CD%\logs
set UPDATE=
set OSTYPE=
set PREREQ=
set VALIDOS=
if "%1"=="" goto MENU
if "%1"=="?" goto HELP
if "%1"=="/?" goto HELP
if "%1"=="-?" goto HELP
if "%1"=="s" goto MENU





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
set /p PREREQ="Have you run the prerequisites on the target machine (y/n or Yes/No)?"
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
REM echo Now I will need either an IP or DNS name of the target machine
set /p TARGET="Enter the target machines IP or DNS name (DNS Names may need to be fully domain qualified):"
call:GETMACANDSENDINGIP
set /p USERNAME="Enter the username of the admin user to use:"
echo Next up will be running the actions but a password prompt will get the password from you for the specified username first.
call:pwd pw
echo.
echo.
echo now to determine if the action is 4
if /I %ACTION%==4 (
	echo looks like the action is 4
	REM if /I "%OS%=="WINDOWS" call:WSPECIFICSOFTWARE
	REM if /I "%OS%=="MAC" call:MSPECIFICSOFTWARE
)
echo calling decisions.
call:DECISIONS

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




:SCRIPTUPDATE
REM echo I am in the script update section
REM I can grab the current version listing from github via curl -LJO  https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/Version.txt
REM echo I am in the script update section
del Version.txt
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
echo OK Lets review you selection before we get started. You selected Action:%ACTION% on a OS Type:%OS% with username:%USERNAME%. Let go.
PAUSE
if /I "%OS%"=="WINDOWS" (
	if %ACTION%==1 call:WDEPLOY
	if %ACTION%==2 call:WUPDATE
	if %ACTION%==3 call:WAUDIT
)
if /I "%OS%"="MAC" (
	if %ACTION%==1 call:MDEPLOY
	if %ACTION%==2 call:MUPDATE
	if %ACTION%==3 call:MAUDIT
)

GOTO EOF


:DEPENDANCIES


:WDEPLOY
echo %today%%time%: deploying on machine %TARGET% >>%CD%\logs\report%TARGET%%today%.txt
echo %today%%time%:Deleting existing batch files if they exist >>%CD%\logs\report%TARGET%%today%.txt
if exist %CD%\Deploy\inst2016ato.bat del %CD%\Deploy\inst2016ato.bat
if exist %CD%\Deploy\hideupdates.bat del %CD%\Deploy\hideupdates.bat
if exist %CD%\Deploy\MSUpdates.bat del %CD%\Deploy\MSUpdates.bat
if exist %CD%\Deploy\satslinstall.bat del %CD%\Deploy\satslinstall.bat
if exist %CD%\Deploy\addprinters.bat del %CD%\Deploy\addprinters.bat
echo %today%%time%:Generating new batch files >>%CD%\logs\report%TARGET%%today%.txt
md %CD%\DEPLOY
(
echo @echo off
echo echo time to install office 365
echo if exist  "C:\Program Files ^(x86^)\Microsoft Office" ^(
echo echo Looks like a 32 bit version of office is already installed and the install can not continue ^>^> c:\windows\sju\errors.txt
echo exit
echo ^)
echo echo Now is the time to run the setup.exe with the configuration file
echo c:\windows\SJU\setup.exe /configure %systemroot%\sju\configuration-Office365-x64.xml  ^>^> c:\officeinstall.log
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
echo timeout timeout /T 20 /NOBREAK
echo shutdown -r -t 10
)>>%CD%\Deploy\inst365ato.bat

(
echo @echo off
echo echo Lets hide the language updates
echo cscript c:\windows\SJU\Hideupdates.vbs
)>>%CD%\Deploy\hideupdates.bat

(
echo @echo off
echo lets install windows updates
echo cscript c:\windows\SJU\wsusupdate.vbs
echo shutdown -r -t 10
)>>%CD%\Deploy\MSUpdates.bat

(
echo @echo off
echo echo installing spiceworks and Ninite
echo msiexec /i c:\Windows\sju\satsl.msi spiceworks_server=172.25.122.43 spiceworks_auth_key="7sqCCaA+y6mkqOwGZszgMEz0CEg=" spiceworks_port=4001 /q /norestart
echo msiexec -i c:\Windows\sju\NiniteAgent.msi /q /norestart
)>>%CD%\Deploy\satslinstall.bat

echo Creating the Printer batch
(
echo @echo off
echo REM SH MAILROOM Colour Copier /Printer
echo c:\Windows\SJU\SHColor.exe /Quiet
echo REM SH MAILROOM Copier /Printer
echo c:\Windows\SJU\SHBW.exe /Quiet
echo REM Library Copier /Printer
echo c:\Windows\SJU\LibBW.exe /Quiet
echo REM Library Colour Copier /Printer
echo c:\Windows\SJU\LibColor.exe /Quiet
)>>%CD%\Deploy\addprinters.bat




echo %today%%time%: deployment scripts have been created >> %CD%\logs\report%TARGET%%today%.txt
echo now I am just going download the additional required files for you.
curl -LJo %CD%\DEPLOY\Hideupdates.vbs https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/Hideupdates.vbs
curl -LJo %CD%\DEPLOY\wsusupdate.vbs https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/wsusupdate.vbs
curl -LJo %CD%\DEPLOY\satsl.msi https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/satsl.msi
curl -LJo %CD%\NinitePro.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/NinitePro.exe
curl -LJo %CD%\DEPLOY\SHColor.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/SHColor.exe
curl -LJo %CD%\DEPLOY\SHBW.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/SHBW.exe
curl -LJo %CD%\DEPLOY\LibBW.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/LibBW.exe
curl -LJo %CD%\DEPLOY\LibColor.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/LibColor.exe
curl -LJo %CD%\DEPLOY\7za.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/7za.exe
curl -LJo %CD%\DEPLOY\7za.dll https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/7za.dll
curl -LJo %CD%\DEPLOY\7zxa.dll https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/7zxa.dll
curl -LJo %CD%\PsExec.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/PsExec.exe
curl -LJo %CD%\DEPLOY\setup.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/setup.exe
curl -LJo %CD%\DEPLOY\configuration-Office365-x64.xml https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/configuration-Office365-x64.xml

echo %today%%time%: Time to copy the required files to the system >> %CD%\logs\report%TARGET%%today%.txt
REM 1. map to the admin share for copying files
echo %today%%time%: Mapping admin share for connection >> %CD%\logs\report%TARGET%%today%.txt
if exist x: net use x: /delete
net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME%
REM 1. make a directory for the files
if not exist x:\sju md x:\sju
REM 1. copy all the deployment files to the machine
echo %today%%time%: Copying files to the share >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Copying files to the system...PLEASE WAIT...
xcopy %CD%\Deploy\*.* x:\sju /E/Y/Q
echo %today%%time%: Copy of files is complete - now for the installations
echo %today%%time%: Files copied to the share ended with error level:%errorlevel% >> %CD%\logs\report%TARGET%%today%.txt
REM 2. Install .net - prerequisit for office 2013 and spiceworks agent
echo %today%%time%: Installing Dot net >> %CD%\logs\report%TARGET%%today%.txt
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select  ".NET 4.5"	".NET 3.5" /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%dotnetINSTALL.csv
echo %today%%time%: Dot net installed with errorlevel:%errorlevel% >> %CD%\logs\report%TARGET%%today%.txt
REM 3. run the install of Windows 7 SP1 this will install then restart need to perform a ping check after this task is done
REM LEGACY echo %today%%time%: Install Windows 7 SP1 if applicable >> %CD%\logs\report%TARGET%%today%.txt
REM LEGACY start "Install SP1 if this is a windows 7 machine"  /wait psexec -s \\%TARGET% -u sysadmin -p %pw% c:\Windows\SJU\W7SP1install.bat >> %CD%\logs\report%TARGET%%today%.txt
REM LEGACY echo SP1 checked/installed >> %CD%\logs\report%TARGET%%today%.txt
REM 3. PING test waiting for machine to come back up by calling health
echo %today%%time%: Call health to see if the machine is back online >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%:waiting for 30 seconds for the restart of the machine
timeout /T 30 /NOBREAK
call:HEALTH
REM 3. check to make sure that the machine did come back online and if it didn't error and exit
if "%wakeupfailed%"=="1" (
echo %today%%time%:The machine has not come back online after installing SP1 there could be a problem >> %CD%\logs\report%today%.txt
EXIT /b
)
REM 4. NEXT is the install of office which will also activate windows and Office 365
echo %today%%time%: Install Office 365 x64 >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Install Office 365 x64
start "Install Office 365 x64"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% c:\Windows\SJU\inst365ato.bat >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%:Office365 install and activate >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%:Office365 install and activate

echo %today%%time%: Call health to see if the machine is back online >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%:waiting for 30 seconds for the restart of the machine
timeout /T 30 /NOBREAK
call:HEALTH
echo %today%%time%: Lets install the spiceworks agent now. >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Lets install the spiceworks agent now.
start "Install Spiceworks Agent" /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% c:\Windows\SJU\satslinstall.bat >> %CD%\logs\report%TARGET%%today%.txt

REM 8. Install of Standard Software
echo %today%%time%: Install all other software >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Install all other software
call:WINSTALL
echo %today%%time%:Install all software >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%:Install all software


REM 9. install Printers
REM start "ADD SJU Printer"  /wait %CD%\psexec -s \\%TARGET% -u sysadmin -p %pw% c:\Windows\SJU\addprinters.bat >> %CD%\logs\report%TARGET%%today%.txt

rem 10. Remove batch files from machine and current directory
echo %today%%time%: Cleanup time >> %CD%\logs\report%TARGET%%today%.txt
echo %today%%time%: Get the system Information >> %CD%\logs\report%TARGET%%today%.txt
start "Get System Info"  /wait psexec -s \\%TARGET% -u %USERNAME% -p %pw% systeminfo > c:\windows\sju\%TARGET%sysinfo.txt
copy x:\sju\%TARGET%sysinfo.txt %cd%\logs\%TARGET%sysinfo.txt
echo %today%%time%:I should have a proper sysinfo now.


del x:\SJU\*.* /S /Q
rmdir /S /Q x:\sju
del %CD%\Deploy\W7SP1install.bat
del %CD%\Deploy\inst365ato.bat
del %CD%\Deploy\hideupdates.bat
del %CD%\Deploy\MSUpdates.bat
del %CD%\Deploy\satslinstall.bat
net use x: /delete
goto END

:WINSTALL
if "%TARGET:~0,3%"=="172" (
echo %today%%time%:I have a 172 address maybe I can get the dns name and then get the MAC to attempt a wakeup but skipping for now
)
if "%TARGET:~0,3%"=="129" (
echo %today%%time%:I have a 129 address maybe I can get the dns name and then get the MAC to attempt a wakeup but skipping for now
)
echo %today%%time%:perform audit on:%TARGET% with MAC:%PHY%
echo %today%%time%:Waking up %TARGET%...Please Wait
call:HEALTH REM THis will check for the machines health do an NSLOOKUP if required and try to wakeup the machine
if "%wakeupfailed%"=="1" (
echo Wakeup of machine:%TARGET% unsuccessful skipping this machine >> %CD%\logs\report%today%.txt
EXIT /b
)
echo looks like the machine is awake time for it's INSTALL. >> %CD%\logs\report%today%.txt
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Flash "Flash (IE)" Reader Java VLC Firefox WinRAR Silverlight ".NET 4.5" "TeamViewer 15" /disableautoupdate /disableshortcuts /silent %CD%\logs\%today%\%TARGET%INSTALL1.csv
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /select Chrome /allusers /disableshortcuts /silent %CD%\logs\%today%\%TARGET%INSTALL2.csv
set status=0
for /F "delims=" %%b in ('find /c "Partial" %CD%\logs\%today%\%TARGET%INSTALL1.csv') do set status=%%b
if %status:~-1%==1 echo System:%TARGET% is only Partially up-to-date >> %CD%\logs\report%today%.txt
for /F "delims=" %%b in ('find /c "Failed" %CD%\logs\%today%\%TARGET%INSTALL1.csv') do set status=%%b
if %status:~-1%==1 echo System:%TARGET% Something Failed during the INSTALL >> %CD%\logs\report%today%.txt
for /F "delims=" %%b in ('find /c ",OK," %CD%\logs\%today%\%TARGET%INSTALL1.csv') do set status=%%b
if %status:~-1%==1 echo System:%TARGET% OK - All software is up-to-date >> %CD%\logs\report%today%.txt
REM LEGACY cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u sysadmin -p %pw% "c:\Program Files (x86)\Symantec\Symantec Endpoint Protection\SepLiveUpdate.exe"
cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% net stop spiceworksagent
cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% net start spiceworksagent
EXIT /b

:WUPDATE
rem Check the health of the machine and determine if IP or dns name then wakeup if able then audit
echo %today%%time%:time to set my variables
if "%TARGET:~0,3%"=="172" (
echo %today%%time%:I have a 172 address maybe I can get the dns name and then get the MAC to attempt a wakeup but skipping for now
)
if "%TARGET:~0,3%"=="129" (
echo %today%%time%:I have a 129 address maybe I can get the dns name and then get the MAC to attempt a wakeup but skipping for now
)
echo perform audit on:%TARGET% with MAC:%PHY%
echo %today%%time%:Waking up %TARGET%...Please Wait
call:HEALTH REM THis will check for the machines health do an NSLOOKUP if required and try to wakeup the machine
if "%wakeupfailed%"=="1" (
echo Wakeup of machine:%TARGET% unsuccessful skipping this machine >> %CD%\logs\report%today%.txt
EXIT /b
)
echo %today%%time%:Updating system:%TARGET% Please wait.
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /updateonly /silent %CD%\logs\%today%\%TARGET%UPDATE.csv
set status=0
for /F "delims=" %%b in ('find /c "Partial" %CD%\logs\%today%\%TARGET%UPDATE.csv') do set status=%%b
if %status:~-1%==1 echo System:%TARGET% is only Partially up-to-date >> %CD%\logs\report%today%.txt
for /F "delims=" %%b in ('find /c "Failed" %CD%\logs\%today%\%TARGET%UPDATE.csv') do set status=%%b
if %status:~-1%==1 echo System:%TARGET% Something Failed during the UPDATE >> %CD%\logs\report%today%.txt
for /F "delims=" %%b in ('find /c ",OK," %CD%\logs\%today%\%TARGET%UPDATE.csv') do set status=%%b
if %status:~-1%==1 echo System:%TARGET% OK - All software is up-to-date >> %CD%\logs\report%today%.txt
REM INSTALL NEWEST VERSION OF SPICEWORKS
(
echo @echo off
echo echo installing spiceworks
echo msiexec /i c:\Windows\sju\satsl.msi spiceworks_server=172.17.6.250 spiceworks_auth_key="7sqCCaA+y6mkqOwGZszgMEz0CEg=" spiceworks_port=4001 /q /norestart
)>>%CD%\Deploy\satslinstall.bat

if exist x: net use x: /delete
net use x: \\%TARGET%\admin$ %PW% /USER:%USERNAME%
REM 1. make a directory for the files
if not exist x:\sju md x:\sju
xcopy %CD%\Deploy\satsl.* x:\sju /E/Y/Q
echo %today%%time%:Lets install the spiceworks agent now.
start "Install Spiceworks Agent"  /wait %CD%\psexec -s \\%TARGET% -u %USERNAME% -p %pw% c:\Windows\SJU\satslinstall.bat >> %CD%\logs\report%TARGET%%today%.txt
net use x: /delete
cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% net stop spiceworksagent
cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% net start spiceworksagent
EXIT /b


:WAUDIT
rem Check the health of the machine and determine if IP or dns name then wakeup if able then audit
echo %today%%time%:Waking up %TARGET%...Please Wait
call:HEALTH REM THis will check for the machines health do an NSLOOKUP if required and try to wakeup the machine
if "%wakeupfailed%"=="1" (
echo Wakeup of machine:%TARGET% unsuccessful skipping this machine >> %CD%\logs\report%today%.txt
EXIT /b
)
echo %today%%time%:looks like the machine is awake time for it's audit.
cmd /c NinitePro.exe /remote %TARGET% /remoteauth %USERNAME% %PW% /audit /silent %CD%\logs\%today%\%TARGET%AUDIT.csv >> %CD%\logs\report%today%.txt
set status=0
for /F "delims=" %%b in ('find /c "Partial" %CD%\logs\%today%\%TARGET%Audit.csv') do set status=%%b
if %status:~-1%==1 echo System:%TARGET% is only Partially up-to-date >> %CD%\logs\report%today%.txt
for /F "delims=" %%b in ('find /c "Failed" %CD%\logs\%today%\%TARGET%Audit.csv') do set status=%%b
if %status:~-1%==1 echo System:%TARGET% Something Failed during the audit >> %CD%\logs\report%today%.txt
for /F "delims=" %%b in ('find /c ",OK," %CD%\logs\%today%\%TARGET%Audit.csv') do set status=%%b
if %status:~-1%==1 echo System:%TARGET% OK - All software is up-to-date >> %CD%\logs\report%today%.txt
cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% systeminfo >> %CD%\logs\report%today%.txt
cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% wmic product get name,version >> %CD%\logs\report%today%.txt
cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% net stop spiceworksagent >> %CD%\logs\report%today%.txt
cmd /c d:\Scripts\Ducs\pstools\psexec -s \\%TARGET% -u %USERNAME% -p %pw% net start spiceworksagent >> %CD%\logs\report%today%.txt
EXIT /b

:WOFFICEINSTALL


:HEALTH
set wakeupfailed=0
REM check to see if an IP was provided then bypass this because I cannot wakeup if no name is given
if "%TARGET:~0,3%"=="172" (
echo %today%%time%:I have a 172 address maybe I can get the dns name and then get the MAC to attempt a wakeup
)
if "%TARGET:~0,3%"=="129" (
echo %today%%time%:I have a 129 address maybe I can get the dns name and then get the MAC to attempt a wakeup
)
echo %today%%time%:I am past the IP Check
set piping=0
ping -n 1 %TARGET% -4|find "TTL="
if NOT "%errorlevel%"=="0" (
	REM the machine is not responding to ping lets do an nslookup to see if it is in the dns server
	echo %today%%time%:machine did not respond to a ping
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
ping -n 1 %TARGET%|find "TTL="
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #2

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL="
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #3

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL="
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #4

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL="
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #5

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL="
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #6

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL="
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #7

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL="
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #8

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL="
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #9

timeout /T 10 /NOBREAK
ping -n 1 %TARGET%|find "TTL="
if "%errorlevel%"=="0" EXIT /b
echo %today%%time%:machine did not respond to a ping #10

set wakeupfailed=1
echo Failed to get a connection to %TARGET% after a WOL and 10 ping attempts >> %CD%\logs\report%today%.txt
EXIT /b

:WAKEUP
REM This will not be working now and will dependant on getting the MAC address and the local IP that it will be sent from.
if %PHY%==NUL (
	echo Looks like I can't get the MAC address not going to be able to wake the target
	EXIT /b
)
echo %today%%time%:Waking Up %PHY%
curl -LJo -s %CD%\wol.exe https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/wol.exe
wol %PHY% %HOSTIP%
set pingcount=0
echo %today%%time%:Trying to wake up:%TARGET%
rem call:PINGSTART REM aftre a return return back and a check for wakeup failed will need to be performed and then the device is skipped if it failed.
EXIT /b

:WSPECIFICSOFTWARE
REM Need to create a list of availible software for Windows which can be installed to the taregt machine
echo Welcome to the Software selection options. Below is a list of availible software products please select the desired software to install on the target. You will be returned to this selection after your previous selection is completed.
echo 1. 7Zip - Compression Utility
echo 2. Audacity - Audio editing software
echo 3. Chrome - Internet Browser
echo 4. Evernote - Note management system
echo 5. Filezilla - FTP and SFTP protocol application
echo 6. Firefox - Internet Broswer
echo 7.	GIMP - Photo editing software
echo 8. Notepad ++ - Text editing program
echo 9. Putty - Remote console connection program (SSH, Telenet and others)
echo 10. Skype - Standard Skype not skype for business
echo 11. TeamViewer 15 - Remote connection and support program
echo 12. VLC - Media Player
echo 13. Java - Web protocol and application system
echo 14. WebEx - Video conferencing software
echo 15. WinRar - Compression Utility
echo 16. Zoom - Video conferencing software
echo 17. Microsoft Office - Office Suite
echo 18. Adobe Reade - PDF Reader
echo 0. Exit
set /p 
GOTO EOF

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

:END
type %CD%\logs\report%today%.txt
call:REPORT
PAUSE
EXIT

:EOF