param([Parameter(Mandatory=$true)][string]$GodotExe)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotExe).Path
$buildRoot = Join-Path $projectRoot 'builds'
$windowsRoot = Join-Path $buildRoot 'windows'
New-Item -ItemType Directory -Path $windowsRoot -Force | Out-Null
$templatePath = Join-Path $projectRoot '.godot/export_templates/windows_release_x86_64.exe'
if (-not (Test-Path -LiteralPath $templatePath)) {
& python (Join-Path $PSScriptRoot 'fetch_windows_template.py') $templatePath
if ($LASTEXITCODE -ne 0) { throw 'Could not download the official Godot 4.4.1 Windows export template.' }
}
function Invoke-BuildCheck([string]$Arguments) {
$buildProcess = Start-Process -FilePath $enginePath -ArgumentList $Arguments -WorkingDirectory $projectRoot -WindowStyle Hidden -PassThru
if (-not $buildProcess.WaitForExit(120000)) { $buildProcess.Kill(); throw 'Build command timed out.' }
$buildProcess.WaitForExit()
if ($buildProcess.ExitCode -ne 0) { throw ('Build command failed: ' + $Arguments) }
}
Invoke-BuildCheck '--headless --path . --editor --import --quit --log-file .godot/build-import.log'
& (Join-Path $PSScriptRoot 'test.ps1') -GodotExe $enginePath
Invoke-BuildCheck '--headless --path . --log-file .godot/build-licences.log res://tests/ReleaseMetadata.tscn'
Invoke-BuildCheck '--headless --path . --export-release "Windows Desktop" builds/windows/LagosLife.exe --quit --log-file .godot/build-export.log'
$exportLog = Get-Content -LiteralPath (Join-Path $projectRoot '.godot/build-export.log') -Raw
if ($exportLog -match '(?m)^(SCRIPT ERROR|ERROR):') { throw $exportLog }
foreach ($mode in @('write','read')) {
$smokeLog = Join-Path $windowsRoot ('qa-' + $mode + '.log')
$smokeProcess = Start-Process -FilePath (Join-Path $windowsRoot 'LagosLife.exe') -ArgumentList ('--headless --log-file "' + $smokeLog + '" -- --smoke-' + $mode) -WorkingDirectory $windowsRoot -WindowStyle Hidden -PassThru
if (-not $smokeProcess.WaitForExit(45000)) { $smokeProcess.Kill(); throw 'Standalone test timed out.' }
$smokeProcess.WaitForExit()
$smokeText = Get-Content -LiteralPath $smokeLog -Raw
if ($smokeProcess.ExitCode -ne 0 -or $smokeText -match '(?m)^(SCRIPT ERROR|ERROR):' -or $smokeText -notmatch 'PASS') { throw $smokeText }
}
Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/PLAYER_README.txt') -Destination (Join-Path $windowsRoot 'README.txt') -Force
foreach ($notice in @('GODOT_LICENSE.txt','THIRD_PARTY_NOTICES.txt')) {
Copy-Item -LiteralPath (Join-Path $projectRoot ('.godot/release-metadata/' + $notice)) -Destination (Join-Path $windowsRoot $notice) -Force
}
$packageFiles = @('LagosLife.exe','LagosLife.pck','README.txt','GODOT_LICENSE.txt','THIRD_PARTY_NOTICES.txt') | ForEach-Object { Join-Path $windowsRoot $_ }
$packagePath = Join-Path $buildRoot 'LagosLife-0.1.0-windows.zip'
Compress-Archive -LiteralPath $packageFiles -DestinationPath $packagePath -Force
Get-FileHash -LiteralPath $packagePath -Algorithm SHA256 | Format-List Algorithm,Hash,Path
Write-Output ('Release candidate ready: ' + $packagePath)
