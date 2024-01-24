@echo off
cls
chcp 65001 > nul
setlocal enabledelayedexpansion

set str1=%1
set str=%str1%

set countö=0
set countä=0
set countü=0
set countõ=0
set countš=0
set countž=0

set lcountÖ=0
set lcountÄ=0
set lcountÜ=0
set lcountÕ=0
set lcountŠ=0
set lcountŽ=0

set /a len=0
:loop
if defined str1 (
    set "str1=!str1:~1!"
    set /a len+=1
    goto loop
)

for /L %%i in (0,1,%len%) do (
    set "letter=!str:~%%i,1!"
    if "!letter!"=="ö" (
        set /A countö+=1
    ) else if "!letter!"=="Ö" (
        set /A lcountÖ+=1
    )
    if "!letter!"=="ä" (
        set /A countä+=1
    ) else if "!letter!"=="Ä" (
        set /A lcountÄ+=1
    )
    if "!letter!"=="ü" (
        set /A countü+=1
    ) else if "!letter!"=="Ü" (
        set /A lcountÜ+=1
    )
    if "!letter!"=="õ" (
        set /A countõ+=1
    ) else if "!letter!"=="Õ" (
        set /A lcountÕ+=1
    )
    if "!letter!"=="š" (
        set /A countš+=1
    ) else if "!letter!"=="Š" (
        set /A lcountŠ+=1
    )
    if "!letter!"=="ž" (
        set /A countž+=1
    ) else if "!letter!"=="Ž" (
        set /A lcountŽ+=1
    )
)

set "str=!str:"=!"

set "str=!str:ö=^&ouml;!"
set "str=!str:ä=^&auml;!"
set "str=!str:ü=^&uuml;!"
set "str=!str:õ=^&otilde;!"
set "str=!str:š=^&scaron;!"
set "str=!str:ž=^&zcaron;!"

set "str=!str:Ö=^&Ouml;!"
set "str=!str:Ä=^&Auml;!"
set "str=!str:Ü=^&Uuml;!"
set "str=!str:Õ=^&Otilde;!"
set "str=!str:Š=^&Scaron;!"
set "str=!str:Ž=^&Zcaron;!"

echo %str%
echo. & rem

set /a sum=countö + countä + countü + countõ + countš + countž + lcountÖ + lcountÄ + lcountÜ + lcountÕ + lcountŠ + lcountŽ

if %sum% neq 0 (
    echo Vahetatud:
    echo. & rem

    if %countö% neq 0 echo ö: %countö%
    if %countä% neq 0 echo ä: %countä%
    if %countü% neq 0 echo ü: %countü%
    if %countõ% neq 0 echo õ: %countõ%
    if %countš% neq 0 echo š: %countš%
    if %countž% neq 0 echo ž: %countž%

    if %lcountÖ% neq 0 echo Ö: %lcountÖ%
    if %lcountÄ% neq 0 echo Ä: %lcountÄ%
    if %lcountÜ% neq 0 echo Ü: %lcountÜ%
    if %lcountÕ% neq 0 echo Õ: %lcountÕ%
    if %lcountŠ% neq 0 echo Š: %lcountŠ%
    if %lcountŽ% neq 0 echo Ž: %lcountŽ%

    echo. & rem
    echo Kokku: %sum%  
) else echo Ei leidnud ühtegi täpitähte.

endlocal