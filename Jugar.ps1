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
    throw 'No se encontró Godot. Abre Godot 4.7.2 e importa mision-killa-wasi\project.godot.'
}
$gameProject = Join-Path $PSScriptRoot 'mision-killa-wasi'
& $godotExecutable --path $gameProject --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot no pudo importar el proyecto.' }
& $godotExecutable --path $gameProject
