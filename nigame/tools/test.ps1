param([Parameter(Mandatory=$true)][string]$GodotExe)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotExe).Path
$cachePath = Join-Path $projectRoot '.godot'
New-Item -ItemType Directory -Path $cachePath -Force | Out-Null
$cases = @(
@('foundation', 'res://tests/Steps3To5.tscn', ''),
@('daily-loop', 'res://tests/Steps6To15.tscn', ''),
@('final-systems', 'res://tests/Steps16To19.tscn', ''),
@('restart-write', 'res://tests/PersistenceRestart.tscn', '-- write'),
@('restart-read', 'res://tests/PersistenceRestart.tscn', ''))
foreach ($case in $cases) {
$logPath = Join-Path $cachePath ('qa-' + $case[0] + '.log')
$arguments = '--headless --path . --log-file "' + $logPath + '" ' + $case[1] + ' ' + $case[2]
$testProcess = Start-Process -FilePath $enginePath -ArgumentList $arguments -WorkingDirectory $projectRoot -WindowStyle Hidden -PassThru
if (-not $testProcess.WaitForExit(45000)) { $testProcess.Kill(); throw ('Test timed out: ' + $case[0]) }
$testProcess.WaitForExit()
$logText = Get-Content -LiteralPath $logPath -Raw
if ($testProcess.ExitCode -ne 0 -or $logText -match '(?m)^(SCRIPT ERROR|ERROR):' -or $logText -notmatch 'PASS') { throw ($case[0] + ' failed: ' + $logText) }
Write-Output ($case[0] + ': PASS')
}
