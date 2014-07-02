@echo off
setlocal enableextensions

if "%1" == "" (
    set tag_name=systags
) else (
    set tag_name=%1
)

echo minGWͷ�ļ�������ɳ��� - StarWing��д
echo.

if exist %tag_name% (
    set /p a="���������ļ�..." <nul
    rename %tag_name% "%tag_name%.old" 2>&1 1>nul
    if %errorlevel% == 0 echo done
)

set /p a="����%tag_name%�ļ�..." <nul
ctags -R --c++-kinds=+p --fields=+iaS --extra=+q -f%tag_name% -n "..\..\..\minGW\include"
if %errorlevel% == 0 echo done

set /p a="�滻std��..." <nul
set vimflags=-c ":e $VIMDIR/tools/systags|silent! %%s/_GLIBCXX_STD/std/g|%%sor|wq"

if NOT "%VIMRUNTIME%" == "" (
    "%VIMRUNTIME%/vim" %vimflags%
    ) else (
        :loop
        if "%CD:~3%" == "" exit

        if EXIST vim72 (
            "vim72\vim.exe" %vimflags%
        ) else (
            cd..
            goto :loop
        )
    )
    if %errorlevel% == 0 echo done

pause
:: vim: ft=dosbatch:fdm=marker:sw=4:ts=4:et:sta:nu
