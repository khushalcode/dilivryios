<#
.SYNOPSIS
    Applies outstanding iOS config fixes:
      - Adds GMSApiKey to Info.plist (pulled from AndroidManifest.xml)
      - Adds CFBundleDisplayName / CFBundleName to Info.plist (pulled from android:label)
      - Flags missing assets/images/logo.png (can't auto-generate this one)

.USAGE
    Dry run (default, no changes):
        powershell -ExecutionPolicy Bypass -File .\update-all.ps1

    Apply for real:
        powershell -ExecutionPolicy Bypass -File .\update-all.ps1 -Apply
#>

param(
    [switch]$Apply,
    [string]$ProjectRoot = "C:\Users\Khushal\Downloads\Deliveryios\Delivery"
)

$ErrorActionPreference = "Stop"

function Write-Step($msg, $color = "Cyan") { Write-Host $msg -ForegroundColor $color }
function Write-Ok($msg)   { Write-Host "  [OK]   $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Write-Bad($msg)  { Write-Host "  [FAIL] $msg" -ForegroundColor Red }

if (-not (Test-Path $ProjectRoot)) {
    Write-Bad "Project root not found: $ProjectRoot"
    exit 1
}

Write-Host "=========================================="
Write-Host " Applying outstanding fixes"
Write-Host " Mode: $(if ($Apply) { 'APPLY' } else { 'DRY RUN' })"
Write-Host "=========================================="
Write-Host ""

$manifestPath = Join-Path $ProjectRoot "android\app\src\main\AndroidManifest.xml"
$plistPath    = Join-Path $ProjectRoot "ios\Runner\Info.plist"
$logoPath     = Join-Path $ProjectRoot "assets\images\logo.png"

if (-not (Test-Path $manifestPath)) { Write-Bad "AndroidManifest.xml not found at expected path"; exit 1 }
if (-not (Test-Path $plistPath))    { Write-Bad "Info.plist not found at expected path"; exit 1 }

$manifestContent = Get-Content $manifestPath -Raw

# ---------- Extract values from AndroidManifest.xml ----------
Write-Step "--- Reading values from AndroidManifest.xml ---"

$appLabel = $null
if ($manifestContent -match 'android:label\s*=\s*"([^"]+)"') {
    $appLabel = $matches[1]
    Write-Ok "App name (android:label): '$appLabel'"
} else {
    Write-Warn "Could not find android:label in manifest"
}

$mapsKey = $null
if ($manifestContent -match 'com\.google\.android\.geo\.API_KEY"\s*\r?\n?\s*android:value\s*=\s*"([^"]+)"') {
    $mapsKey = $matches[1]
    Write-Ok "Maps API key (android): $mapsKey"
} else {
    Write-Warn "Could not find Maps API key in manifest"
}
Write-Host ""

# ---------- Update Info.plist ----------
Write-Step "--- Updating Info.plist ---"
$plistContent = Get-Content $plistPath -Raw
$originalPlist = $plistContent
$changed = $false

# Add GMSApiKey if missing
if ($mapsKey) {
    if ($plistContent -match "<key>GMSApiKey</key>") {
        Write-Ok "GMSApiKey already present in Info.plist - leaving as-is"
    } else {
        $insertion = "`t<key>GMSApiKey</key>`n`t<string>$mapsKey</string>`n"
        $plistContent = $plistContent -replace '(<dict>\s*\r?\n)', "`$1$insertion"
        Write-Ok "Will add GMSApiKey = $mapsKey"
        $changed = $true
    }
} else {
    Write-Warn "Skipping GMSApiKey insert - no Maps key found in manifest"
}

# Add CFBundleDisplayName / CFBundleName if missing
if ($appLabel) {
    if ($plistContent -match "<key>CFBundleDisplayName</key>") {
        Write-Ok "CFBundleDisplayName already present - leaving as-is"
    } else {
        $insertion = "`t<key>CFBundleDisplayName</key>`n`t<string>$appLabel</string>`n"
        $plistContent = $plistContent -replace '(<dict>\s*\r?\n)', "`$1$insertion"
        Write-Ok "Will add CFBundleDisplayName = '$appLabel'"
        $changed = $true
    }

    if ($plistContent -match "<key>CFBundleName</key>") {
        Write-Ok "CFBundleName already present - leaving as-is"
    } else {
        $insertion = "`t<key>CFBundleName</key>`n`t<string>$appLabel</string>`n"
        $plistContent = $plistContent -replace '(<dict>\s*\r?\n)', "`$1$insertion"
        Write-Ok "Will add CFBundleName = '$appLabel'"
        $changed = $true
    }
} else {
    Write-Warn "Skipping CFBundleDisplayName/CFBundleName insert - no app label found"
}

if ($Apply -and $changed) {
    # Backup original first
    $backupPath = "$plistPath.bak"
    Set-Content -Path $backupPath -Value $originalPlist -NoNewline -Encoding UTF8
    Set-Content -Path $plistPath -Value $plistContent -NoNewline -Encoding UTF8
    Write-Ok "Info.plist updated (backup saved to $($backupPath.Substring($ProjectRoot.Length)))"
} elseif (-not $Apply -and $changed) {
    Write-Warn "DRY RUN - no changes written. Re-run with -Apply to commit."
} elseif (-not $changed) {
    Write-Ok "No changes needed to Info.plist"
}
Write-Host ""

# ---------- Logo check ----------
Write-Step "--- Checking logo asset ---"
if (Test-Path $logoPath) {
    Write-Ok "assets/images/logo.png exists"
} else {
    Write-Bad "assets/images/logo.png is missing - this script cannot generate it"
    Write-Host "         Copy your logo file to: $logoPath" -ForegroundColor DarkGray
}
Write-Host ""

Write-Host "=========================================="
if (-not $Apply) {
    Write-Host " DRY RUN complete. Re-run with -Apply to write changes." -ForegroundColor Yellow
} else {
    Write-Host " Apply complete." -ForegroundColor Green
    Write-Host " Next: flutter clean; flutter pub get; rebuild iOS" -ForegroundColor Green
}
Write-Host "=========================================="