$dir = $PSScriptRoot
$tex = "Resume.tex"

$watcher = New-Object System.IO.FileSystemWatcher $dir, $tex
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite
$watcher.EnableRaisingEvents = $true

function Build {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Change detected — compiling..."
    Push-Location $dir
    xelatex -interaction=nonstopmode $tex | Out-Null
    xelatex -interaction=nonstopmode $tex | Out-Null
    Pop-Location
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Done -> Resume.pdf"
}

Write-Host "Watching $tex for changes. Press Ctrl+C to stop."

while ($true) {
    $result = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::Changed, 500)
    if (-not $result.TimedOut) {
        Start-Sleep -Milliseconds 200  # debounce
        Build
    }
}
