::   Made with ❤️ by Watashi o yūwaku suru 
@echo off
chcp 1251
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
if "%StatusFireWall%"=="RUNNING" ( set "ReplyStatFirewall={0a}Работает{#}" 
) else ( set "ReplyStatFirewall={0e}Не запущен{#}" )
set regfirewallServ="HKLM\SYSTEM\ControlSet001\Services\MpsSvc" /v "Start"
reg query %regfirewallServ% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regfirewallServ% 2^>nul ') do set /a "valueServFirewall=%%I"
 if "!valueServFirewall!"=="2" ( set "ReplyServFirewall={0a}Автоматически{#}" 
 ) else ( set "ReplyServFirewall={0e}Не автоматически{#}" )
) else ( set "ReplyServFirewall={0c}Служба не существует{#}" )
set regfirewallStandard="HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "EnableFirewall"
reg query %regfirewallStandard% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regfirewallStandard% 2^>nul ') do set /a "valueStandardFirewall=%%I"
 if "!valueStandardFirewall!"=="1" ( set "ReplyStandardFirewall={0a}Включен{#}" 
 ) else ( set "ReplyStandardFirewall={0e}Отключен{#}" )
) else ( set "ReplyStandardFirewall={0c}Параметр не существует{#}" )
set regfirewallPublic="HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "EnableFirewall"
reg query %regfirewallPublic% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regfirewallPublic% 2^>nul ') do set /a "valuePublicFirewall=%%I"
 if "!valuePublicFirewall!"=="1" ( set "ReplyPublicFirewall={0a}Включен{#}" 
 ) else ( set "ReplyPublicFirewall={0e}Отключен{#}" )
) else ( set "ReplyPublicFirewall={0c}Параметр не существует{#}" )
if "%StatusFireWall%"=="RUNNING" if "!valueServFirewall!"=="2" if "!valueStandardFirewall!"=="1" if "!valuePublicFirewall!"=="1" ( set "FireWallOptions=1" )
cls
echo.
%cr% {0f}     ================================================================== {\n #}
%cr%          Управление {0e}Блокировкой IP{#} в Брандмауэре Windows{\n #}
%cr%          Один файл = Одно правило, Префикс имени правила: {0a}%NameRulePrefix%{\n #}
%cr% {0f}     ================================================================== {\n #}
echo.
echo:         Параметры Брандмауэра в данный момент:
%cr%                   Служба: %ReplyStatFirewall%        Профиль частной сети: %ReplyStandardFirewall%{\n #}
%cr%              Тип запуска: %ReplyServFirewall%   Профиль общественной сети: %ReplyPublicFirewall%{\n #}
echo.
if not "%FireWallOptions%"=="1" (
 %cr% {0c}         Не все параметры для работы Брандмауэра правильные^^^! {\n #}
 %cr% {0c}         Для продолжения нужно восстановить параметры {\n #}
 goto :SetFireWallOptions
)
echo:         Правила по блокировке IP в Брандмауэре:
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
  if "!GroupYes!"=="" ( set "GroupName=" ) else ( set "GroupName=  Группа: {0e}!GroupName:~1,-1!" )
  %cr%            !N!. {0a}%NameRulePrefix%%%J{#}!GroupName!{\n #}
 )
)
if "!MyRules!"=="" ( %cr% {0e}           Нет созданных правил с префиксом %NameRulePrefix% {\n #}& set "NoMyRules=1" )
echo.
echo:         Файлы c адресами IP:
chcp 437 >nul
set "FileRules="& set "NoFiles="
set /a N=0
for /f "tokens=*" %%I in (' 2^>nul dir /b "%FolderListsIP%" ^| findstr /i /r /c:".txt$" ^| findstr /v "[?]" ') do (
 set /a N+=1
 set "FileRules=%%I" & %cr%            !N!. {0a}%%I{\n #})
chcp 1251 >nul
if "!FileRules!"=="" ( %cr% {0e}           Не найдены {\n #}& set "NoFiles=1" )
%cr%                                                    {08} ^| Версия 1.0 {\n #}
echo:         Варианты действий:
echo.
%cr% {0b}     [1]{#} = Создать/обновить правила блокировки IP из всех файлов {\n #}
%cr% {0b}     [2]{#} = Выбрать файлы для блокировки IP {\n #}
%cr% {0e}     [3]{#} = Удалить {0e}выборочно{#} правила (с префиксом {0e}%NameRulePrefix%{#} в названии){\n #}
%cr% {0c}     [4]{#} = Удалить {0c}все{#} правила (с префиксом {0e}%NameRulePrefix%{#} в названии) {\n #}
%cr% {0b}     [Без ввода]{#} = Выход {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo:&%cr%     {0e} - Пропущено управление блокировкой - {\n #}
			endlocal & TIMEOUT /T 4 >nul & goto :Exit )
if "%input%"=="1" ( goto :IPBlocking )
if "%input%"=="2" ( goto :IPBlockSelectMenu )
if "%input%"=="3" ( goto :DeleteRulesSelectMenu )
if "%input%"=="4" ( goto :DeleteRulesIP
 ) else ( echo.&%cr%     {0e} Не правильный выбор {\n #}& echo.
	  TIMEOUT /T 2 >nul & endlocal & goto :IPBlockMenu )

:IPBlocking
if "%NoFiles%"=="1" ( echo:&%cr%     {0e} - Нет файлов для использования - {\n #}
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
 %cr%         {2f} Созданы {#} правила в Брандмауэре Windows {\n #}
 echo:&echo:         Для продолжения нажмите любую клавишу
) else ( %cr%         {2f} Обновлены {#} правила в Брандмауэре Windows {\n #}
 echo:&echo:         Для продолжения нажмите любую клавишу
)
echo:
TIMEOUT /T -1 >nul & endlocal & goto :IPBlockMenu


:DeleteRulesIP
if "%NoMyRules%"=="1" ( echo:&%cr%     {0e} - Нет правил для удаления - {\n #}
			endlocal & TIMEOUT /T 4 >nul & goto :IPBlockMenu )
echo.
set "MyRules="
set RegRules="HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f "Name=%NameRulePrefix%" /d
for /f "tokens=3-100*" %%I in (' reg query %RegRules% ^| findstr "Name=%NameRulePrefix%" ') do (
 set "MyRules=%%I"& set "MyRules=!MyRules:*%NameRulePrefix%=!"
 for /f "tokens=1 delims=|" %%J in ("!MyRules!") do (
  echo.
  echo:     ----------------------------------------------------------------------
  %cr% {0e}         Удаление{#} правила: {0e}%NameRulePrefix%%%J{\n #}
  Netsh Advfirewall Firewall delete rule name="%NameRulePrefix%%%J" 
 )
)
echo:
%cr%         {2f} Удалены {#} все правила с префиксом: {0e}%NameRulePrefix%{\n #}
echo:&echo:         Для продолжения нажмите любую клавишу
TIMEOUT /T -1 >nul & endlocal & goto :IPBlockMenu




:IPBlockSelectMenu
setlocal EnableDelayedExpansion
cls
echo.
%cr% {0f}     ==================================== {\n #}
%cr%          {0e}Выборочное{#} применение файлов{\n #}
%cr% {0f}     ==================================== {\n #}
echo.
echo:         Правила по блокировке IP в Брандмауэре:
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
  if "!GroupYes!"=="" ( set "GroupName=" ) else ( set "GroupName=  Группа: {0e}!GroupName:~1,-1!" )
  %cr%            !N!. {0a}%NameRulePrefix%%%J{#}!GroupName!{\n #}
 )
)
if "!MyRules!"=="" ( %cr% {0e}           Нет созданных правил с префиксом %NameRulePrefix% {\n #}& set "NoMyRules=1" )
echo.
echo:         Укажите номер файла для создания/обновления правила.
%cr%          Если несколько файлов, то через знак {0e}+{#} (например: {0e}1+3{#}){\n #}
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
if "!FileRules!"=="" ( %cr% {0e}           Не найдены файлы{\n #}
 endlocal & TIMEOUT /T 4 >nul & goto :IPBlockMenu
)
echo.
%cr% {0b}          [Без ввода]{#} = Возврат в главное меню {\n #}



set "choice="& set "MyChoice="
echo:
set /p choice=-  Ваш выбор: 
if not defined Choice ( echo: & %cr% {0A}        Возврат в главное меню {\n #}
			TIMEOUT /T 3 >nul & endlocal & goto :IPBlockMenu )
set /a "MyChoice=%choice%" 2>nul 
if not defined MyChoice ( echo: & %cr% {0e}        Не правильный выбор {\n #}
			  TIMEOUT /T 3 >nul & endlocal & goto :IPBlockSelectMenu )
if "%MyChoice%"=="0"  ( echo: & %cr% {0e}        Не правильный выбор {\n #}
			TIMEOUT /T 3 >nul & endlocal & goto :IPBlockSelectMenu
) else (
 set "choice=%choice:+= %"& echo:
 for %%I in (!choice!) do (
 %cr%       Выбран файл: {0b}[%%I]{\n #}
 Call :GetFileName "%%I"
 )
)
echo:         Для продолжения нажмите любую клавишу
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
if "!NoFileName!"=="" ( echo: & %cr% {0e}      Не правильный выбор файла{\n #}& echo: )
exit /b


:AddFireWallRule
chcp 1251 >nul
set "NameRule=%~1"
set "NumberFile=%~2"
echo.
echo:     ---------------------------------------------------------------------------
%cr% {0a}         Получение адресов IP{#} из файла: {0b}[%NumberFile%] {0a}!NameRule!{#}:{\n #}
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
 %cr% {0e}         Создаем{#} новое правило: {0e}%NameRulePrefix%!NameRule:~0,-4! {\n #}
 Netsh Advfirewall Firewall add rule name="%NameRulePrefix%!NameRule:~0,-4!" dir=out action=block remoteip="!AllBlockIP:~0,-1!"
 ) else (
 echo:
 %cr% {0e}         Обновляем{#} существующее правило: {0e}%NameRulePrefix%!NameRule:~0,-4! {\n #}
 Netsh Advfirewall Firewall set rule name="%NameRulePrefix%!NameRule:~0,-4!" new remoteip="!AllBlockIP:~0,-1!"
 )
)
if exist "%FolderListsIP%\TempBlockIP_!NameRule!.txt" ( del /f /q "%FolderListsIP%\TempBlockIP_!NameRule!.txt" )
echo.
exit /b


:SetFireWallOptions
echo.
echo:         Варианты действий:
echo.
%cr% {0b}     [1]{#} = Восстановить параметры Брандмауэра {\n #}
%cr% {0b}     [Без ввода]{#} = Выход {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo:&%cr%     {0e} - Пропущена настройка параметров Брандмауэра - {\n #}
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
) else ( echo.&%cr%     {0e} Не правильный выбор {\n #} & echo.
	 TIMEOUT /T 3 >nul & endlocal & goto :IPBlockMenu )



:DeleteRulesSelectMenu
setlocal EnableDelayedExpansion
cls
echo.
%cr% {0f}     ================================== {\n #}
%cr%          {0e}Выборочное {0c}удаление{#} правил{\n #}
%cr% {0f}     ================================== {\n #}
echo.
echo:         Укажите номер правила для удаления.
%cr%          Если несколько правил, то через знак {0e}+{#} (например: {0e}1+3{#}){\n #}
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
  if "!GroupYes!"=="" ( set "GroupName=" ) else ( set "GroupName=  Группа: {0e}!GroupName:~1,-1!" )
  %cr%            {0b}[!N!]{#} = {0a}%NameRulePrefix%%%J{#}!GroupName!{\n #}
 )
)
if "!MyRules!"=="" ( %cr% {0e}           Нет созданных правил с префиксом %NameRulePrefix% {\n #}
 TIMEOUT /T 3 >nul & endlocal & goto :IPBlockMenu
)
echo.
%cr% {0b}           [Без ввода]{#} = Возврат в главное меню {\n #}
echo:
set "choice="& set "MyChoice="
set /p choice=-  Ваш выбор: 
if not defined Choice ( echo: & %cr% {0A}        Возврат в главное меню {\n #}
			TIMEOUT /T 3 >nul & endlocal & goto :IPBlockMenu )
set /a "MyChoice=%choice%" 2>nul 
if not defined MyChoice ( echo: & %cr% {0e}        Не правильный выбор {\n #}
			  TIMEOUT /T 3 >nul & endlocal & goto :DeleteRulesSelectMenu )
if "%MyChoice%"=="0"  ( echo: & %cr% {0e}        Не правильный выбор {\n #}
			TIMEOUT /T 3 >nul & endlocal & goto :DeleteRulesSelectMenu
) else (
  Call :GetRuleName "%choice%"
)
echo:
echo:         Для продолжения нажмите любую клавишу
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
    %cr%       Правило: {0b}[!N2!]{#} найдено{\n #}
    Call :DeleteSelectRule "!SetRule!" "!N5!"
   )
  )
 )
)

   
 rem  if "!RulesYes!"=="" if "!MyRules!"=="" ( echo: & %cr%            Не верный выбор правила {0e} "!N2!"{\n #}& echo: )

exit /b


:DeleteSelectRule
set "NameSelectRule=%~1"
set "NumberSelectRule=%~2"
echo.
echo:     ----------------------------------------------------------------------
%cr% {0e}         Удаление{#} правила: {0b}[%NumberSelectRule%] {0e}%NameRulePrefix%%NameSelectRule%{\n #}
Netsh Advfirewall Firewall delete rule name="%NameRulePrefix%%NameSelectRule%" 
exit /b



:Exit
exit


:First
cd /d "%~dps0Tools"
set "cr=@"%~dps0"Tools\cecho"
Set xOS=x64& (If "%PROCESSOR_ARCHITECTURE%"=="x86" If Not Defined PROCESSOR_ARCHITEW6432 Set xOS=x86)
chcp 1251 >nul
if not exist "cecho.exe" ( echo: & echo:        Нет файла "cecho.exe" в папке "Tools" & echo.
			   echo:        Отмена, выход & TIMEOUT /T 5 >nul & exit )

REG QUERY "HKU\S-1-5-19\Environment"& cls
if "%errorlevel%" NEQ "0" (
	echo: Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	echo: UAC.ShellExecute "%~f0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
	"%temp%\getadmin.vbs" &	exit )
if exist "%temp%\getadmin.vbs" ( del /f /q "%temp%\getadmin.vbs" ) & exit /b
