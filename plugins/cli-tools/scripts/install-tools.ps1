<#
.SYNOPSIS
    Installs the CLI tools required by the cli-tools plugin skills (Windows).

.DESCRIPTION
    Idempotent: each tool is only installed if its command is not already on PATH.
    winget tools: rg, fd, fzf, jq, yq, hyperfine
    pip tool:     jc
    scoop tools:  rga (ripgrep-all), poppler (optional, for rga PDF extraction)

    A per-tool failure is reported but does not abort the rest of the run.
    Re-run after installation if PATH changes have not taken effect in the current shell.

.PARAMETER SkipPoppler
    Skip installing poppler (the optional PDF text-extraction backend for rga).

.EXAMPLE
    pwsh -File install-tools.ps1
.EXAMPLE
    pwsh -File install-tools.ps1 -SkipPoppler
#>
[CmdletBinding()]
param(
    [switch]$SkipPoppler
)

$ErrorActionPreference = 'Stop'
$results = [System.Collections.Generic.List[object]]::new()

function Test-Cmd {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Add-Result {
    param([string]$Tool, [string]$Status, [string]$Detail = '')
    $results.Add([pscustomobject]@{ Tool = $Tool; Status = $Status; Detail = $Detail })
}

function Install-Tool {
    param(
        [string]$Tool,        # display / check command name
        [scriptblock]$Install,
        [string]$CheckCmd     # command to test for presence (defaults to $Tool)
    )
    if (-not $CheckCmd) { $CheckCmd = $Tool }
    if (Test-Cmd $CheckCmd) {
        Add-Result $Tool 'already installed'
        Write-Host "  [skip] $Tool already on PATH" -ForegroundColor DarkGray
        return
    }
    Write-Host "  [install] $Tool ..." -ForegroundColor Cyan
    try {
        & $Install
        if (Test-Cmd $CheckCmd) {
            Add-Result $Tool 'installed'
            Write-Host "  [ok] $Tool installed" -ForegroundColor Green
        } else {
            Add-Result $Tool 'installed (restart shell)' 'command not yet on PATH; reopen terminal'
            Write-Host "  [ok] $Tool installed (reopen terminal to pick up PATH)" -ForegroundColor Yellow
        }
    } catch {
        Add-Result $Tool 'FAILED' $_.Exception.Message
        Write-Host "  [fail] $Tool : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "cli-tools dependency installer (Windows)" -ForegroundColor White
Write-Host "----------------------------------------"

# --- Prerequisite package managers ---------------------------------------
$hasWinget = Test-Cmd 'winget'
$hasScoop  = Test-Cmd 'scoop'
$pip = $null
foreach ($c in @('pip3', 'pip')) { if (Test-Cmd $c) { $pip = $c; break } }
if (-not $pip -and (Test-Cmd 'python')) { $pip = 'python -m pip' }

if (-not $hasWinget) {
    Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, then re-run." -ForegroundColor Red
}

# scoop is needed for rga (+ poppler). Offer to install it if missing.
if (-not $hasScoop) {
    Write-Host "scoop not found (required for rga). Installing scoop ..." -ForegroundColor Cyan
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
        $hasScoop = Test-Cmd 'scoop'
    } catch {
        Write-Host "  [fail] scoop install: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- winget tools ---------------------------------------------------------
$wingetTools = @(
    @{ Tool = 'rg';        Id = 'BurntSushi.ripgrep.MSVC' },
    @{ Tool = 'fd';        Id = 'sharkdp.fd' },
    @{ Tool = 'fzf';       Id = 'junegunn.fzf' },
    @{ Tool = 'jq';        Id = 'jqlang.jq' },
    @{ Tool = 'yq';        Id = 'MikeFarah.yq' },
    @{ Tool = 'hyperfine'; Id = 'sharkdp.hyperfine' }
)
Write-Host "`nwinget tools:" -ForegroundColor White
foreach ($t in $wingetTools) {
    if ((Test-Cmd $t.Tool)) { Install-Tool $t.Tool { } $t.Tool; continue }
    if (-not $hasWinget) { Add-Result $t.Tool 'SKIPPED' 'winget unavailable'; continue }
    $id = $t.Id
    Install-Tool $t.Tool {
        winget install --exact --id $id --accept-source-agreements --accept-package-agreements --silent
    } $t.Tool
}

# --- pip tool: jc ---------------------------------------------------------
Write-Host "`npip tool:" -ForegroundColor White
if (Test-Cmd 'jc') {
    Install-Tool 'jc' { } 'jc'
} elseif ($pip) {
    Install-Tool 'jc' { Invoke-Expression "$pip install --user jc" } 'jc'
} else {
    Add-Result 'jc' 'SKIPPED' 'no pip/python found'
    Write-Host "  [skip] jc : no pip/python on PATH" -ForegroundColor Yellow
}

# --- scoop tools: rga (+ poppler) ----------------------------------------
Write-Host "`nscoop tools:" -ForegroundColor White
if ($hasScoop) {
    Install-Tool 'rga' { scoop install ripgrep-all } 'rga'
    if (-not $SkipPoppler) {
        Install-Tool 'poppler' { scoop install poppler } 'pdftotext'
    }
} else {
    Add-Result 'rga' 'SKIPPED' 'scoop unavailable'
    Write-Host "  [skip] rga : scoop unavailable" -ForegroundColor Yellow
}

# --- Summary --------------------------------------------------------------
Write-Host "`nSummary:" -ForegroundColor White
$results | Format-Table -AutoSize

$failed = @($results | Where-Object { $_.Status -eq 'FAILED' -or $_.Status -eq 'SKIPPED' })
if ($failed.Count -gt 0) {
    Write-Host "`n$($failed.Count) tool(s) need attention. See details above." -ForegroundColor Yellow
    exit 1
}
Write-Host "`nAll tools present. You may need to reopen the terminal for PATH changes." -ForegroundColor Green
exit 0
