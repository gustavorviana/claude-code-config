@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "CLAUDE_DIR=%USERPROFILE%\.claude"

echo ========================================
echo  Claude Code - Config Linker
echo ========================================
echo.
echo Repository: %SCRIPT_DIR%
echo Claude:     %CLAUDE_DIR%
echo.

if not exist "%CLAUDE_DIR%" mkdir "%CLAUDE_DIR%"

call :PROCESS_FOLDER "skills"
call :PROCESS_FOLDER "agents"
call :PROCESS_FOLDER "commands"
call :PROCESS_FOLDER "hooks"

echo.
echo ========================================
echo  Concluido
echo ========================================
exit /b 0


:PROCESS_FOLDER
set "FOLDER=%~1"
set "SOURCE=%SCRIPT_DIR%\%FOLDER%"
set "TARGET=%CLAUDE_DIR%\%FOLDER%"

echo.
echo ----------------------------------------
echo Pasta: %FOLDER%
echo ----------------------------------------

if not exist "%SOURCE%" (
    echo SKIP: %SOURCE% nao existe.
    exit /b 0
)

REM ----------------------------------------------------------
REM If target is already a link (junction or symlink), skip.
REM DIR /AL lists only reparse points (junctions and symlinks).
REM ----------------------------------------------------------
if exist "%TARGET%" (
    dir /AL /B "%CLAUDE_DIR%" 2>nul | findstr /I /X /C:"%FOLDER%" >nul
    if not errorlevel 1 (
        echo SKIP: %TARGET% ja e um link simbolico.
        exit /b 0
    )
)

REM ----------------------------------------------------------
REM Target doesn't exist
REM ----------------------------------------------------------
if not exist "%TARGET%" (
    mklink /J "%TARGET%" "%SOURCE%" >nul
    if errorlevel 1 (
        echo ERRO: nao foi possivel criar o link.
    ) else (
        echo OK: link criado.
    )
    exit /b 0
)

REM ----------------------------------------------------------
REM Check whether directory is empty
REM ----------------------------------------------------------
dir /A /B "%TARGET%" 2>nul | findstr "." >nul
if errorlevel 1 (
    rmdir "%TARGET%"
    mklink /J "%TARGET%" "%SOURCE%" >nul

    if errorlevel 1 (
        echo ERRO: nao foi possivel criar o link.
    ) else (
        echo OK: pasta vazia substituida por link.
    )

    exit /b 0
)

echo.
echo A pasta do Claude ja possui conteudo:
echo   %TARGET%
echo.
echo [I] Ignorar esta pasta
echo [S] Substituir pelo link (APAGA o conteudo existente)
echo [C] Copiar conteudo do Claude -^> Repo
echo [X] Cancelar tudo
echo.

choice /C ISCX /N /M "Escolha: "

if errorlevel 4 (
    echo Operacao cancelada.
    exit /b 1
)

if errorlevel 3 (
    call :MERGE_FOLDER "%TARGET%" "%SOURCE%"

    if errorlevel 1 (
        echo.
        echo Operacao cancelada durante a copia.
        exit /b 1
    )

    echo.
    echo Removendo pasta original do Claude...
    rmdir /S /Q "%TARGET%"

    mklink /J "%TARGET%" "%SOURCE%" >nul

    if errorlevel 1 (
        echo ERRO: nao foi possivel criar o link.
    ) else (
        echo OK: conteudo mesclado e link criado.
    )

    exit /b 0
)

if errorlevel 2 (
    echo.
    echo ATENCAO: isto ira apagar:
    echo   %TARGET%
    echo.
    set /p "CONFIRM=Digite SIM para confirmar: "

    if /I "!CONFIRM!"=="SIM" (
        rmdir /S /Q "%TARGET%"
        mklink /J "%TARGET%" "%SOURCE%" >nul

        if errorlevel 1 (
            echo ERRO: nao foi possivel criar o link.
        ) else (
            echo OK: substituido por link.
        )
    ) else (
        echo SKIP: substituicao cancelada.
    )

    exit /b 0
)

echo SKIP: usuario escolheu ignorar.
exit /b 0


REM ==========================================================
REM MERGE_FOLDER
REM
REM %1 = source (Claude)
REM %2 = destination (Repo)
REM ==========================================================
:MERGE_FOLDER
set "FROM=%~1"
set "TO=%~2"

echo.
echo Copiando:
echo   Claude: %FROM%
echo   Repo:   %TO%
echo.

if not exist "%TO%" mkdir "%TO%"

for /R "%FROM%" %%F in (*) do (
    set "FILE=%%F"
    set "RELATIVE=!FILE:%FROM%=!"
    set "DEST=%TO%!RELATIVE!"

    if exist "!DEST!" (
        echo.
        echo CONFLITO:
        echo   Claude: !FILE!
        echo   Repo:   !DEST!
        echo.
        echo [C] Copiar Claude -^> Repo
        echo [A] Apagar arquivo do Claude
        echo [S] Pular
        echo [X] Cancelar
        echo.

        choice /C CASX /N /M "Escolha: "

        if errorlevel 4 (
            exit /b 1
        )

        if errorlevel 3 (
            echo   - Pulado.
        )

        if errorlevel 2 (
            del /F /Q "!FILE!"
            echo   - Apagado do Claude.
        )

        if errorlevel 1 (
            copy /Y "!FILE!" "!DEST!" >nul
            echo   - Copiado.
        )
    ) else (
        if not exist "!DEST!\.." mkdir "!DEST!\.." 2>nul
        copy /Y "!FILE!" "!DEST!" >nul
        echo   + !RELATIVE!
    )
)

exit /b 0
