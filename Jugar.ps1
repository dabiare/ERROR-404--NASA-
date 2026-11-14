$ErrorActionPreference = 'Stop'
$godotCandidates = @(
    (Join-Path $env:USERPROFILE 'Desktop\Godot\Godot_v4.7.2-stable_win64.exe')
)
$godotExecutable = $godotCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $godotExecutable) {
    $godotCommand = Get-Command godot,godot4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($godotCommand) { $godotExecutable = $godotCommand.Source }
}
if (-not $godotExecutable) {
    throw 'No se encontró Godot. Abre Godot 4.7.2 e importa el archivo project.godot de esta carpeta.'
}
& $godotExecutable --path $PSScriptRoot --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot no pudo importar el proyecto.' }
& $godotExecutable --path $PSScriptRoot
