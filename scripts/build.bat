@echo off
setlocal enabledelayedexpansion

set PROJECT_ROOT=%~dp0..
set DOCS=%PROJECT_ROOT%\docs
set MODELS=%DOCS%\models
set OUTPUT=%PROJECT_ROOT%\output
set MAIN=%DOCS%\passport.adoc
set THEME=%DOCS%\theme\brand-theme.yml
set FONTS=%DOCS%\fonts

if not exist "%OUTPUT%" mkdir "%OUTPUT%"

echo =====================================
echo AsciiDoc PDF Builder
echo =====================================

where asciidoctor-pdf >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: asciidoctor-pdf is not installed.
    echo Install it using: gem install asciidoctor-pdf
    exit /b 1
)

REM Генерация всех моделей
if "%1"=="all" (
    for %%f in ("%MODELS%\*.adoc") do (
        set NAME=%%~nf
        echo Generating PDF for !NAME!...
        asciidoctor-pdf "%MAIN%" ^
            -a include-model="%%f" ^
            -a pdf-theme="%THEME%" ^
            -a pdf-fontsdir="%FONTS%" ^
            -a imagesdir="%DOCS%\images" ^
            -o "%OUTPUT%\!NAME!.pdf"
    )
    goto end
)

REM Генерация одной модели
if not "%1"=="" (
    set MODEL=%MODELS%\%1.adoc
    if exist "%MODEL%" (
        echo Generating PDF for %1...
        asciidoctor-pdf "%MAIN%" ^
            -a include-model="%MODEL%" ^
            -a pdf-theme="%THEME%" ^
            -a pdf-fontsdir="%FONTS%" ^
            -a imagesdir="%DOCS%\images" ^
            -o "%OUTPUT%\%1.pdf"
    ) else (
        echo ERROR: Model %1 not found.
    )
    goto end
)

echo Usage:
echo   build.bat all
echo   build.bat S2101I

:end
endlocal