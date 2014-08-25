@echo off
::Checks if PC is connected to the server. If not exit.
if NOT EXIST "\\pa-fenris\data\Admin\Workshop Files\Suppliers\Foreigner" exit
::Deletes any temp.bat
if EXIST "Z:\temp.bat" del /F "Z:\temp.bat"
:: Checks the software creation dates.
for /F "Delims=" %%I In ('xcopy /DHYL \\pa-fenris\data\Programs_for_int_use\Project_Files_Management\HSS_Updater.bat Z:\HSS_Updater.bat ^|Findstr /I "File"') Do set /a Newer=%%I 2>Nul
if %Newer% == 1 goto Update
:: T: will be mapped to the folder Foreigner within our server fenris.
subst T: "\\pa-fenris\data\Admin\Workshop Files\Suppliers\Foreigner"
:: Change directory to our recently mapped T:
cd /d T:
:: Loops to update the folder tree.
for /d %%A in (*) do if NOT EXIST Z:\Foreigner\%%A md "Z:\Foreigner\%%A\1offline_data\"
::Added functionality to ask for which letter to start.
set input = a
set /P input=Please enter which letter you want to start updating:
set letter=%input:~0,1%
echo %letter%
call :toUpper letter
goto F1

:toUpper str -- converts lowercase character to uppercase
::           -- str [in,out] - valref of string variable to be converted
:$created 20060101 :$changed 20080219 :$categories StringManipulation
:$source http://www.dostips.com
if not defined %~1 EXIT /b
for %%a in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I"
            "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R"
            "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z" "ä=Ä"
            "ö=Ö" "ü=Ü") do (
    call set %~1=%%%~1:%%~a%%
)
EXIT /b
:F1
:: Loops through all folders inside Foreigner and update the folders in Z: (hard drive)

::for /d %%A in (*) do if not EXIST "Z:\Foreigner\%%A\1offline_data" md "Z:\Foreigner\%%A\1offline_data"

setlocal EnableDelayedExpansion
for /D %%C in (*) do ( 
	CALL :FUNC1 "%%C"
)
endlocal
GOTO FOLLOW1
::This function will extract the first letter and compare it against the letter input by the user. Then update the folders with that starting letter.
:FUNC1
set "theword=%~1"
set theletter=!theword:~0,1!
echo %theletter%
if "%theletter%" GEQ "%letter%" robocopy /Z /E /MIR "%~1\1offline_data" "z:\Foreigner\%~1\1offline_data"
EXIT /b

:: Loops through HDD to check if Server has all the folders inside HDD Foreigner. If not, then it has been changed/deleted and should be removed from HDD as well.
:FOLLOW1
Z:
cd Foreigner
for /d %%B in (*) do if NOT EXIST T:\%%B rd /Q /S "Z:\Foreigner\%%B\"
:: Free up the mapping.
cd /d C:
subst T: /d
:: We are done at this point.
echo Update performed succesfully... Now program will exit...
pause
exit
:Update
::If File in server is newer, create a separate batch file to update the script and reexecute.
echo start /wait robocopy \\pa-fenris\data\Programs_for_int_use\Project_Files_Management\ Z:\ HSS_Updater.bat>Z:\temp.txt
echo attrib -h Z:\HSS_Updater.bat>>Z:\temp.txt
echo touch -d "+1 minutes" Z:\HSS_Updater.bat>>Z:\temp.txt
echo attrib +h Z:\HSS_Updater.bat>>Z:\temp.txt
echo Z:\HSS_Updater.bat>>Z:\temp.txt
Z:
ren temp.txt temp.bat
::Execute the newly written batch file.
Z:\temp.bat
pause
