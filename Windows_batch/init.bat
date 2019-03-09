:: Init Script for cmd.exe
:: Created as part of appie project

:: Find root dir
@if not defined appie_ROOT (
    for /f %%i in ("%ConEmuDir%\..\..") do @set appie_ROOT=%%~fi
)

:: Change the prompt style
@prompt $E[1;32;40m$P$S{git}$S$_$E[1;30;40m{lamb}$S$E[0m

:: Pick right version of clink
@if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set architecture=86
) else (
    set architecture=64
)

:: Run clink
@"%appie_ROOT%\base\clink\clink_x%architecture%.exe" inject --quiet --profile "%appie_ROOT%\config"

:: Prepare for git-for-windows

:: I do not even know, copypasted from their .bat
@set PLINK_PROTOCOL=ssh
@if not defined TERM set TERM=cygwin

:: Enhance Path
@set git_install_root=%appie_ROOT%\base\git-for-windows
@set PATH=%appie_ROOT%\bin;%git_install_root%\bin;%git_install_root%\usr\bin;%PATH%;%appie_ROOT%\bin\adt\sdk\platform-tools;%git_install_root%\mingw32\bin;%git_install_root%\cmd;%git_install_root%\share\vim\vim74;%appie_ROOT%\bin\adt\eclipse;%appie_ROOT%\base\python;%appie_ROOT%\bin\adt\eclipse\jre\bin;%appie_ROOT%\bin\adt\eclipse\jre\lib;%appie_ROOT%\bin\adt\eclipse\bin;%appie_ROOT%\bin\adt\sdk\tools;%appie_ROOT%\bin\Wireshark;%appie_ROOT%\bin\tools-repo\dex2jar
::@set PYTHONPATH=%appie_ROOT%\base\python\Lib\site-packages
:: Add aliases
@doskey /macrofile="%appie_ROOT%\config\aliases"

:: Set home path
@if not defined HOME set HOME=%USERPROFILE%

@if defined appie_START (
    @cd /d "%appie_START%"
) else (
    @if "%CD%\" == "%appie_ROOT%" (
        @cd /d "%HOME%"
    )
)
