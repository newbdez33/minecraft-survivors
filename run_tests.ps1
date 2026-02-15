# Run all tests for Three Kingdoms Survivors
# Usage: .\run_tests.ps1
# Or: powershell -ExecutionPolicy Bypass -File run_tests.ps1

Write-Host "Running Three Kingdoms Survivors Test Suite..." -ForegroundColor Cyan
Write-Host ""

# Function to find Godot executable
function Find-Godot {
    # Check if GODOT_PATH is set
    if ($env:GODOT_PATH -and (Test-Path $env:GODOT_PATH)) {
        return $env:GODOT_PATH
    }

    # Check PATH
    $godotInPath = Get-Command "godot" -ErrorAction SilentlyContinue
    if ($godotInPath) {
        return $godotInPath.Source
    }

    $godot4InPath = Get-Command "godot4" -ErrorAction SilentlyContinue
    if ($godot4InPath) {
        return $godot4InPath.Source
    }

    # Common installation paths
    $commonPaths = @(
        "C:\Program Files\Godot\godot.exe",
        "C:\Program Files (x86)\Godot\godot.exe",
        "$env:LOCALAPPDATA\Godot\godot.exe",
        "$env:USERPROFILE\scoop\apps\godot\current\godot.exe",
        "$env:USERPROFILE\AppData\Local\Programs\Godot\godot.exe"
    )

    # Check for Godot 4.x versions
    $godot4Patterns = @(
        "C:\Program Files\Godot\Godot_v4*win64*.exe",
        "$env:LOCALAPPDATA\Godot\Godot_v4*win64*.exe",
        "$env:USERPROFILE\Downloads\Godot_v4*win64*.exe"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    foreach ($pattern in $godot4Patterns) {
        $matches = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($matches) {
            return $matches.FullName
        }
    }

    return $null
}

$godotPath = Find-Godot

if (-not $godotPath) {
    Write-Host "ERROR: Godot not found in PATH or common locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure Godot is installed and either:" -ForegroundColor Yellow
    Write-Host "  1. Add Godot to your PATH" -ForegroundColor Yellow
    Write-Host "  2. Set GODOT_PATH environment variable:" -ForegroundColor Yellow
    Write-Host '     $env:GODOT_PATH = "C:\path\to\godot.exe"' -ForegroundColor Gray
    Write-Host "     .\run_tests.ps1" -ForegroundColor Gray
    exit 1
}

Write-Host "Using Godot: $godotPath" -ForegroundColor Green
Write-Host ""

$scriptDir = $PSScriptRoot
$testRunner = Join-Path $scriptDir "tests\test_runner.gd"

# Run tests
$process = Start-Process -FilePath $godotPath -ArgumentList "--headless", "--script", $testRunner -Wait -PassThru -NoNewWindow

if ($process.ExitCode -eq 0) {
    Write-Host ""
    Write-Host "All tests passed!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Some tests failed!" -ForegroundColor Red
}

exit $process.ExitCode
