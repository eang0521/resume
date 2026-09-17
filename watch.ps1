param(
    [string]$TargetTex = "Resume.tex",
    [switch]$Once
)

$dir = $PSScriptRoot
$tex = $TargetTex
$pdf = [System.IO.Path]::ChangeExtension($tex, "pdf")

function Build {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Change detected -> compiling..."
    Push-Location $dir
    xelatex -interaction=nonstopmode $tex | Out-Null
    xelatex -interaction=nonstopmode $tex | Out-Null
    Pop-Location
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Done -> $pdf"
}

if ($Once) {
    Build
    exit
}

$watcher = New-Object System.IO.FileSystemWatcher $dir, "*.tex"
$watcher.IncludeSubdirectories = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite
$watcher.EnableRaisingEvents = $true

Write-Host "Watching *.tex (including partials/) -> rebuilding $tex on change. Press Ctrl+C to stop."

while ($true) {
    $result = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::Changed, 500)
    if (-not $result.TimedOut) {
        Start-Sleep -Milliseconds 200  # debounce
        Build
    }
}
