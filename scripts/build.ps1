param (
    [string]$Model = "",
    [switch]$All
)

# Определение путей
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path "$ScriptDir\.."
$DocsDir = Join-Path $ProjectRoot "docs"
$ModelsDir = Join-Path $DocsDir "models"
$OutputDir = Join-Path $ProjectRoot "output"
$MainFile = Join-Path $DocsDir "passport.adoc"
$ThemeDir = Join-Path $DocsDir "theme"
$FontsDir = Join-Path $DocsDir "fonts"
$ThemeFile = Join-Path $ThemeDir "brand-theme.yml"

# Создание папки output
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host " AsciiDoc PDF Builder" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

function Build-Pdf($ModelFile) {
    $ModelName = [System.IO.Path]::GetFileNameWithoutExtension($ModelFile)
    $OutputFile = Join-Path $OutputDir "$ModelName.pdf"

    Write-Host "Генерация PDF для модели: $ModelName" -ForegroundColor Yellow

    asciidoctor-pdf `
        $MainFile `
        -a "include-model=$ModelFile" `
        -a "pdf-theme=$ThemeFile" `
        -a "pdf-fontsdir=$FontsDir" `
        -a "imagesdir=$DocsDir/images" `
        -o $OutputFile

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✔ Успешно создан: $OutputFile" -ForegroundColor Green
    } else {
        Write-Host "✖ Ошибка при создании: $ModelName" -ForegroundColor Red
    }
}

# Проверка наличия asciidoctor-pdf
if (!(Get-Command asciidoctor-pdf -ErrorAction SilentlyContinue)) {
    Write-Host "Ошибка: asciidoctor-pdf не установлен." -ForegroundColor Red
    Write-Host "Установите его командой: gem install asciidoctor-pdf"
    exit 1
}

# Генерация всех моделей
if ($All) {
    Write-Host "Генерация всех моделей..." -ForegroundColor Cyan
    Get-ChildItem "$ModelsDir\*.adoc" | ForEach-Object {
        Build-Pdf $_.FullName
    }
}
# Генерация одной модели
elseif ($Model -ne "") {
    $ModelPath = Join-Path $ModelsDir "$Model.adoc"

    if (Test-Path $ModelPath) {
        Build-Pdf $ModelPath
    } else {
        Write-Host "Ошибка: модель '$Model' не найдена." -ForegroundColor Red
    }
}
# Сообщение помощи
else {
    Write-Host ""
    Write-Host "Использование:" -ForegroundColor Cyan
    Write-Host "  Генерация всех моделей:"
    Write-Host "    .\scripts\build.ps1 -All"
    Write-Host ""
    Write-Host "  Генерация одной модели:"
    Write-Host "    .\scripts\build.ps1 -Model S2101I"
    Write-Host ""
}