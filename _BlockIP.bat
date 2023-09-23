::   Made with ❤️ by Watashi o yūwaku suru 
@echo off
Call :First


::   Сценарий Меню блокировок IP
:IPBlockMenu
cd /d "%~dps0"
setlocal EnableDelayedExpansion
set "NameRulePrefix=BlockIP__"
set "FolderListsIP=IPLists"
chcp 437 >nul
for /f "tokens=3 delims=: " %%I in (' 2^>nul sc query MpsSvc ^| find "STATE" ') do set "StatusFireWall=%%I"
chcp 1251 >nul
if "%StatusFireWall%"=="RUNNING" ( set "ReplyStatFirewall={0a}Running{#}" 
) else ( set "ReplyStatFirewall={0e}Not running{#}" )
set regfirewallServ="HKLM\SYSTEM\ControlSet001\Services\MpsSvc" /v "Start"
reg query %regfirewallServ% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regfirewallServ% 2^>nul ') do set /a "valueServFirewall=%%I"
 if "!valueServFirewall!"=="2" ( set "ReplyServFirewall={0a}Automatically{#}" 
 ) else ( set "ReplyServFirewall={0e}Not automatically{#}" )
) else ( set "ReplyServFirewall={0c}Service does not exist{#}" )
set regfirewallStandard="HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "EnableFirewall"
reg query %regfirewallStandard% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regfirewallStandard% 2^>nul ') do set /a "valueStandardFirewall=%%I"
 if "!valueStandardFirewall!"=="1" ( set "ReplyStandardFirewall={0a}Included{#}" 
 ) else ( set "ReplyStandardFirewall={0e}Disabled{#}" )
) else ( set "ReplyStandardFirewall={0c}Parameter does not exist{#}" )
set regfirewallPublic="HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "EnableFirewall"
reg query %regfirewallPublic% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regfirewallPublic% 2^>nul ') do set /a "valuePublicFirewall=%%I"
 if "!valuePublicFirewall!"=="1" ( set "ReplyPublicFirewall={0a}Included{#}" 
 ) else ( set "ReplyPublicFirewall={0e}Disabled{#}" )
) else ( set "ReplyPublicFirewall={0c}Parameter does not exist{#}" )
if "%StatusFireWall%"=="RUNNING" if "!valueServFirewall!"=="2" if "!valueStandardFirewall!"=="1" if "!valuePublicFirewall!"=="1" ( set "FireWallOptions=1" )
cls
echo.
%cr% {0f}     ================================================================== {\n #}
%cr%          Managing {0e}IP Blocking{#} in Windows Firewall{\n #}
%cr%          One file = One rule, Rule name prefix: {0a}%NameRulePrefix%{\n #}
%cr% {0f}     ================================================================== {\n #}
echo.
echo:         Firewall settings at the moment:
%cr%                   Service: %ReplyStatFirewall%         Private network profile: %ReplyStandardFirewall%{\n #}
%cr%              Startup type: %ReplyServFirewall%   Public Network Profile: %ReplyPublicFirewall%{\n #}
echo.
if not "%FireWallOptions%"=="1" (
 %cr% {0c}         Not all parameters for Firewall operation are correct^^^! {\n #}
 %cr% {0c}         To continue, you need to restore the settings {\n #}
 goto :SetFireWallOptions
)
echo:         Rules for blocking IP in the Firewall:
set RegRules1="HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f "Name=%NameRulePrefix%" /d
set /a N=0
for /f "tokens=3-100*" %%I in (' reg query %RegRules1% ^| findstr "Name=%NameRulePrefix%" ') do (
 set "MyRules="& set "NoMyRules="& set "RuleName="& set "GroupName="
 set /a N+=1
 set "MyRules=%%I"& set "RuleName=!MyRules:*%NameRulePrefix%=!"& set "GroupName=!RuleName:*EmbedCtxt=!"
 for /f "tokens=1 delims=|" %%J in ("!RuleName!") do (
  set "GroupYes="
  set RegRules2="HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f "%NameRulePrefix%%%J" /d
  for /f %%K in (' reg query !RegRules2!^| findstr "EmbedCtxt=" ') do set GroupYes=1
  if "!GroupYes!"=="" ( set "GroupName=" ) else ( set "GroupName=  Group: {0e}!GroupName:~1,-1!" )
  %cr%            !N!. {0a}%NameRulePrefix%%%J{#}!GroupName!{\n #}
 )
)
if "!MyRules!"=="" ( %cr% {0e}           There are no created rules with the prefix %NameRulePrefix% {\n #}& set "NoMyRules=1" )
echo.
echo:         Files with IP addresses:
chcp 437 >nul
set "FileRules="& set "NoFiles="
set /a N=0
for /f "tokens=*" %%I in (' 2^>nul dir /b "%FolderListsIP%" ^| findstr /i /r /c:".txt$" ^| findstr /v "[?]" ') do (
 set /a N+=1
 set "FileRules=%%I" & %cr%            !N!. {0a}%%I{\n #})
chcp 1251 >nul
if "!FileRules!"=="" ( %cr% {0e}           Not found {\n #}& set "NoFiles=1" )
%cr%                                                    {08} ^| Version 1.0 {\n #}
echo:         Options for action:
echo.
%cr% {0b}     [1]{#} = Create/update IP blocking rules from all files {\n #}
%cr% {0b}     [2]{#} = Select files to block IP {\n #}
%cr% {0e}     [3]{#} = Delete {0e}selectively{#} rules (with the prefix {0e}%NameRulePrefix%{#} in the name){\n #}
%cr% {0c}     [4]{#} = Delete {0c}all{#} rules (with the prefix {0e}%NameRulePrefix%{#} in the name) {\n #}
%cr% {0b}     [No input]{#} = Exit {\n #}
echo.
set "input="
set /p input=*    Your choice: 
if not defined input ( echo:&%cr%     {0e} - Lock control skipped - {\n #}
			endlocal & TIMEOUT /T 4 >nul & goto :Exit )
if "%input%"=="1" ( goto :IPBlocking )
if "%input%"=="2" ( goto :IPBlockSelectMenu )
if "%input%"=="3" ( goto :DeleteRulesSelectMenu )
if "%input%"=="4" ( goto :DeleteRulesIP
 ) else ( echo.&%cr%     {0e} Incorrect choice {\n #}& echo.
	  TIMEOUT /T 2 >nul & endlocal & goto :IPBlockMenu )

:IPBlocking
if "%NoFiles%"=="1" ( echo:&%cr%     {0e} - No files to use - {\n #}
			endlocal & TIMEOUT /T 4 >nul & goto :IPBlockMenu )
echo.
chcp 437 >nul
set /a N3=0
for /f "tokens=*" %%I in (' 2^>nul dir /b "%FolderListsIP%" ^| findstr /i /r /c:".txt$" ^| findstr /v "[?]" ') do (
 set /a N3+=1
 CAll :AddFireWallRule "%%I" "!N3!"
)
chcp 1251 >nul
if "%NoMyRules%"=="1" (
 %cr%         {2f} Created {#} rules in Windows Firewall {\n #}
 echo:&echo:         Press any key to continue
) else ( %cr%         {2f} Updated {#} rules in Windows Firewall {\n #}
 echo:&echo:         Press any key to continue
)
echo:
TIMEOUT /T -1 >nul & endlocal & goto :IPBlockMenu


:DeleteRulesIP
if "%NoMyRules%"=="1" ( echo:&%cr%     {0e} - No rules for deletion - {\n #}
			endlocal & TIMEOUT /T 4 >nul & goto :IPBlockMenu )
echo.
set "MyRules="
set RegRules="HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f "Name=%NameRulePrefix%" /d
for /f "tokens=3-100*" %%I in (' reg query %RegRules% ^| findstr "Name=%NameRulePrefix%" ') do (
 set "MyRules=%%I"& set "MyRules=!MyRules:*%NameRulePrefix%=!"
 for /f "tokens=1 delims=|" %%J in ("!MyRules!") do (
  echo.
  echo:     ----------------------------------------------------------------------
  %cr% {0e}         Deleting{#} rules: {0e}%NameRulePrefix%%%J{\n #}
  Netsh Advfirewall Firewall delete rule name="%NameRulePrefix%%%J" 
 )
)
echo:
%cr%         {2f} Removed {#} all rules with the prefix: {0e}%NameRulePrefix%{\n #}
echo:&echo:         Press any key to continue
TIMEOUT /T -1 >nul & endlocal & goto :IPBlockMenu




:IPBlockSelectMenu
setlocal EnableDelayedExpansion
cls
echo.
%cr% {0f}     ==================================== {\n #}
%cr%          {0e}Selective{#} application of files{\n #}
%cr% {0f}     ==================================== {\n #}
echo.
echo:         Rules for blocking IP in the Firewall:
set RegRules1="HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f "Name=%NameRulePrefix%" /d
set /a N=0
for /f "tokens=3-100*" %%I in (' reg query %RegRules1% ^| findstr "Name=%NameRulePrefix%" ') do (
 set "MyRules="& set "NoMyRules="& set "RuleName="& set "GroupName="
 set /a N+=1
 set "MyRules=%%I"& set "RuleName=!MyRules:*%NameRulePrefix%=!"& set "GroupName=!RuleName:*EmbedCtxt=!"
 for /f "tokens=1 delims=|" %%J in ("!RuleName!") do (
  set "GroupYes="
  set RegRules2="HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f "%NameRulePrefix%%%J" /d
  for /f %%K in (' reg query !RegRules2!^| findstr "EmbedCtxt=" ') do set GroupYes=1
  if "!GroupYes!"=="" ( set "GroupName=" ) else ( set "GroupName=  Group: {0e}!GroupName:~1,-1!" )
  %cr%            !N!. {0a}%NameRulePrefix%%%J{#}!GroupName!{\n #}
 )
)
if "!MyRules!"=="" ( %cr% {0e}           There are no created rules with the prefix %NameRulePrefix% {\n #}& set "NoMyRules=1" )
echo.
echo:         Specify the file number to create/update the rule.
%cr%          If there are several files, then through the sign {0e}+{#} (for example: {0e}1+3{#}){\n #}
echo.
chcp 437 >nul
set "FileRules="& set "NoFiles="
set /a N1=0
for /f "tokens=*" %%I in (' 2^>nul dir /b "IPLists" ^| findstr /i /r /c:".txt$" ^| findstr /v "[?]" ') do (
 set /a N1+=1
 set "FileRules=%%I"
 %cr% {0b}          [!N1!]{#} = {0a}!FileRules!{\n #}
)
chcp 1251 >nul
if "!FileRules!"=="" ( %cr% {0e}           No files found{\n #}
 endlocal & TIMEOUT /T 4 >nul & goto :IPBlockMenu
)
echo.
%cr% {0b}          [No input]{#} = Return to main menu {\n #}



set "choice="& set "MyChoice="
echo:
set /p choice=-  Your choice: 
if not defined Choice ( echo: & %cr% {0A}        Return to main menu {\n #}
			TIMEOUT /T 3 >nul & endlocal & goto :IPBlockMenu )
set /a "MyChoice=%choice%" 2>nul 
if not defined MyChoice ( echo: & %cr% {0e}        Incorrect choice {\n #}
			  TIMEOUT /T 3 >nul & endlocal & goto :IPBlockSelectMenu )
if "%MyChoice%"=="0"  ( echo: & %cr% {0e}        Incorrect choice {\n #}
			TIMEOUT /T 3 >nul & endlocal & goto :IPBlockSelectMenu
) else (
 set "choice=%choice:+= %"& echo:
 for %%I in (!choice!) do (
 %cr%       Selected file: {0b}[%%I]{\n #}
 Call :GetFileName "%%I"
 )
)
echo:         Press any key to continue
TIMEOUT /T -1 >nul & endlocal & goto :IPBlockSelectMenu




:GetFileName
set "N2=%~1"
chcp 437 >nul
set "FileIP="& set "NoFileName="
set /a N1=0
for /f "tokens=*" %%I in (' 2^>nul dir /b "IPLists" ^| findstr /i /r /c:".txt$" ^| findstr /v "[?]" ') do (
 set /a N1+=1
 set "FileIP=%%I"
 if "!N1!"=="!N2!" ( 
  Call :AddFireWallRule "!FileIP!" "!N1!"
  set "NoFileName=1"
 )
)
chcp 1251 >nul
if "!NoFileName!"=="" ( echo: & %cr% {0e}      Incorrect file selection{\n #}& echo: )
exit /b


:AddFireWallRule
chcp 1251 >nul
set "NameRule=%~1"
set "NumberFile=%~2"
echo.
echo:     ---------------------------------------------------------------------------
%cr% {0a}         Getting IP{#} addresses from a file: {0b}[%NumberFile%] {0a}!NameRule!{#}:{\n #}
echo.
for /f "tokens=1* delims=#" %%J in (' findstr /b "[0-9]" "%FolderListsIP%\!NameRule!" ') do (
 set "ClearIP=%%J" & set "ClearIP=!ClearIP: =!" & set "ClearIP=!ClearIP:	=!"
 echo:           "!ClearIP!"
 <nul set /p "Z=!ClearIP!,">>"%FolderListsIP%\TempBlockIP_!NameRule!.txt"
)
set "AllBlockIP="
for /f "tokens=* delims=" %%J in (' type "%FolderListsIP%\TempBlockIP_!NameRule!.txt" 2^>nul ') do set "AllBlockIP=%%J"
if not "!AllBlockIP!"=="" (
 set "MyRules="
 set RegRules="HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f "Name=%NameRulePrefix%!NameRule:~0,-4!|" /d
 for /f "tokens=3-100*" %%I in (' reg query !RegRules! ^| findstr "Name=%NameRulePrefix%!NameRule:~0,-4!|" ') do set "MyRules=%%I"
 if "!MyRules!"=="" (
 echo:
 %cr% {0e}         Create{#} a new rule: {0e}%NameRulePrefix%!NameRule:~0,-4! {\n #}
 Netsh Advfirewall Firewall add rule name="%NameRulePrefix%!NameRule:~0,-4!" dir=out action=block remoteip="!AllBlockIP:~0,-1!"
 ) else (
 echo:
 %cr% {0e}         We update {#} an existing rule: {0e}%NameRulePrefix%!NameRule:~0,-4! {\n #}
 Netsh Advfirewall Firewall set rule name="%NameRulePrefix%!NameRule:~0,-4!" new remoteip="!AllBlockIP:~0,-1!"
 )
)
if exist "%FolderListsIP%\TempBlockIP_!NameRule!.txt" ( del /f /q "%FolderListsIP%\TempBlockIP_!NameRule!.txt" )
echo.
exit /b


:SetFireWallOptions
echo.
echo:         Options for action:
echo.
%cr% {0b}     [1]{#} = Restore Firewall settings {\n #}
%cr% {0b}     [No input]{#} = Exit {\n #}
echo.
set "input="
set /p input=*    Your choice: 
if not defined input ( echo:&%cr%     {0e} - Missed setting Firewall settings - {\n #}
			endlocal & TIMEOUT /T 4 >nul & goto :Exit )
if "%input%"=="1" (
 echo.
 net stop MpsSvc
 reg add "HKLM\SYSTEM\ControlSet001\Services\MpsSvc" /v "Start" /t REG_DWORD /d 2 /f
 reg add !regfirewallStandard! /t REG_DWORD /d 1 /f
 reg add !regfirewallPublic! /t REG_DWORD /d 1 /f
 net start MpsSvc
 echo.
 TIMEOUT /T 4 >nul & endlocal & goto :IPBlockMenu
) else ( echo.&%cr%     {0e} Incorrect choice {\n #} & echo.
	 TIMEOUT /T 3 >nul & endlocal & goto :IPBlockMenu )



:DeleteRulesSelectMenu
setlocal EnableDelayedExpansion
cls
echo.
%cr% {0f}     ================================== {\n #}
%cr%          {0e}Selective {0c}deleting{#} rules{\n #}
%cr% {0f}     ================================== {\n #}
echo.
echo:         Specify the number of the rule to delete.
%cr%          If there are several rules, then through the sign {0e}+{#} (for example: {0e}1+3{#}){\n #}
echo.
set RegRules1="HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f "Name=%NameRulePrefix%" /d
set /a N=0
for /f "tokens=3-100*" %%I in (' reg query %RegRules1% ^| findstr "Name=%NameRulePrefix%" ') do (
 set "MyRules="& set "NoMyRules="& set "RuleName="& set "GroupName="
 set /a N+=1
 set "MyRules=%%I"& set "RuleName=!MyRules:*%NameRulePrefix%=!"& set "GroupName=!RuleName:*EmbedCtxt=!"
 for /f "tokens=1 delims=|" %%J in ("!RuleName!") do (
  set "GroupYes="
  set RegRules2="HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f "%NameRulePrefix%%%J" /d
  for /f %%K in (' reg query !RegRules2!^| findstr "EmbedCtxt=" ') do set GroupYes=1
  if "!GroupYes!"=="" ( set "GroupName=" ) else ( set "GroupName=  Group: {0e}!GroupName:~1,-1!" )
  %cr%            {0b}[!N!]{#} = {0a}%NameRulePrefix%%%J{#}!GroupName!{\n #}
 )
)
if "!MyRules!"=="" ( %cr% {0e}           There are no created rules with the prefix %NameRulePrefix% {\n #}
 TIMEOUT /T 3 >nul & endlocal & goto :IPBlockMenu
)
echo.
%cr% {0b}           [No input]{#} = Return to main menu {\n #}
echo:
set "choice="& set "MyChoice="
set /p choice=-  Your choice: 
if not defined Choice ( echo: & %cr% {0A}        Return to main menu {\n #}
			TIMEOUT /T 3 >nul & endlocal & goto :IPBlockMenu )
set /a "MyChoice=%choice%" 2>nul 
if not defined MyChoice ( echo: & %cr% {0e}        Incorrect choice {\n #}
			  TIMEOUT /T 3 >nul & endlocal & goto :DeleteRulesSelectMenu )
if "%MyChoice%"=="0"  ( echo: & %cr% {0e}        Incorrect choice {\n #}
			TIMEOUT /T 3 >nul & endlocal & goto :DeleteRulesSelectMenu
) else (
  Call :GetRuleName "%choice%"
)
echo:
echo:         Press any key to continue
echo:
TIMEOUT /T -1 >nul & endlocal & goto :DeleteRulesSelectMenu



:GetRuleName
set "GroupChoice=%~1"
set "GroupChoice=%GroupChoice:+= %"
set "MyRule="
set RegRules="HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f "Name=%NameRulePrefix%" /d
set /a N5=0
for /f "tokens=3-100*" %%I in (' reg query !RegRules! ^| findstr "Name=%NameRulePrefix%" ') do (
 set /a N5+=1
 set "MyRule=%%I"& set "MyRule=!MyRule:*%NameRulePrefix%=!"
 for /f "tokens=1 delims=|" %%J in ("!MyRule!") do (
  set "SetRule=%%J" 
  for %%K in (%GroupChoice%) do (
   set "N2=%%K"
   if "!N5!"=="!N2!" ( 
    echo:
    %cr%       Rule: {0b}[!N2!]{#} found{\n #}
    Call :DeleteSelectRule "!SetRule!" "!N5!"
   )
  )
 )
)

   
 rem  if "!RulesYes!"=="" if "!MyRules!"=="" ( echo: & %cr%            Wrong choice of rule {0e} "!N2!"{\n #}& echo: )

exit /b


:DeleteSelectRule
set "NameSelectRule=%~1"
set "NumberSelectRule=%~2"
echo.
echo:     ----------------------------------------------------------------------
%cr% {0e}         Deleting{#} rules: {0b}[%NumberSelectRule%] {0e}%NameRulePrefix%%NameSelectRule%{\n #}
Netsh Advfirewall Firewall delete rule name="%NameRulePrefix%%NameSelectRule%" 
exit /b



:Exit
exit


:First
cd /d "%~dps0Tools"
set "cr=@"%~dps0"Tools\cecho"
Set xOS=x64& (If "%PROCESSOR_ARCHITECTURE%"=="x86" If Not Defined PROCESSOR_ARCHITEW6432 Set xOS=x86)
chcp 1251 >nul
if not exist "cecho.exe" ( echo: & echo:        There is no file "cecho.exe" in the "Tools" folder & echo.
			   echo:        Cancel, exit & TIMEOUT /T 5 >nul & exit )

REG QUERY "HKU\S-1-5-19\Environment"& cls
if "%errorlevel%" NEQ "0" (
	echo: Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	echo: UAC.ShellExecute "%~f0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
	"%temp%\getadmin.vbs" &	exit )
if exist "%temp%\getadmin.vbs" ( del /f /q "%temp%\getadmin.vbs" ) & exit /b
