<#
.SYNOPSIS
    Installs the CLI tools required by the cli-tools plugin skills (Windows).

.DESCRIPTION
    Idempotent: each tool is only installed if its command is not already on PATH.
    winget tools: rg, fd, fzf, jq, yq, hyperfine, bat, gron, sd, ast-grep
    pip tool:     jc (auto-installs a real Python via winget if only the Windows
                  Store stub is present, then puts the --user Scripts dir on PATH)
    scoop tools:  rga (ripgrep-all), poppler (optional, for rga PDF extraction)
                  scoop bootstrap forces TLS 1.2 so the get.scoop.sh fetch does not
                  fail with a security error under Windows PowerShell 5.1.

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

# Re-read PATH from the registry into the current process so freshly installed
# tools resolve without reopening the terminal.
function Update-ProcessPath {
    $machine = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user    = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = (@($machine, $user) | Where-Object { $_ }) -join ';'
}

# Append a directory to the persistent *user* PATH (and the current process) if absent.
function Add-ToUserPath {
    param([string]$Dir)
    if (-not $Dir -or -not (Test-Path $Dir)) { return $false }
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $parts = @($userPath -split ';' | Where-Object { $_ -ne '' })
    if ($parts -notcontains $Dir) {
        [System.Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ';' + $Dir), 'User')
    }
    if (($env:Path -split ';') -notcontains $Dir) { $env:Path = $env:Path.TrimEnd(';') + ';' + $Dir }
    return $true
}

# True only for a REAL python that can install packages. The Windows Store
# execution-alias stub lives under WindowsApps and answers `python` but cannot
# pip-install anything -- it must not be treated as a usable interpreter.
function Test-RealPython {
    param([string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) { return $false }
    if ($cmd.Source -and $cmd.Source -match '\\WindowsApps\\') { return $false }
    try {
        $v = & $Name --version 2>$null
        return [bool]$v
    } catch { return $false }
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
if (-not $pip) {
    foreach ($py in @('python3', 'python', 'py')) {
        if (Test-RealPython $py) { $pip = "$py -m pip"; break }
    }
}

if (-not $hasWinget) {
    Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, then re-run." -ForegroundColor Red
}

# scoop is needed for rga (+ poppler). Offer to install it if missing.
if (-not $hasScoop) {
    Write-Host "scoop not found (required for rga). Installing scoop ..." -ForegroundColor Cyan
    try {
        # Windows PowerShell 5.1 negotiates TLS 1.0/1.1 by default, which get.scoop.sh
        # rejects -> "Could not establish trust relationship" / security error. Force TLS 1.2.
        [System.Net.ServicePointManager]::SecurityProtocol = `
            [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
        # Process-scope bypass so the bootstrap's child process isn't blocked by execution policy.
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
        Update-ProcessPath   # scoop adds ~\scoop\shims to user PATH; pick it up now
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
    @{ Tool = 'hyperfine'; Id = 'sharkdp.hyperfine' },
    @{ Tool = 'bat';       Id = 'sharkdp.bat' },
    @{ Tool = 'gron';      Id = 'TomHudson.gron' },
    @{ Tool = 'sd';        Id = 'chmln.sd' },
    @{ Tool = 'ast-grep';  Id = 'ast-grep.ast-grep' }
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
} else {
    # No usable interpreter? The only `python` is often the Windows Store stub, which
    # cannot install packages. Provision a real Python via winget before continuing.
    if (-not $pip) {
        if ($hasWinget) {
            Write-Host "  no usable Python found (Store stub does not count); installing Python via winget ..." -ForegroundColor Cyan
            try {
                winget install --exact --id Python.Python.3.13 --accept-source-agreements --accept-package-agreements --silent
                Update-ProcessPath
                foreach ($py in @('python', 'python3', 'py')) {
                    if (Test-RealPython $py) { $pip = "$py -m pip"; break }
                }
            } catch {
                Write-Host "  [fail] Python install: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "  [skip] jc : no usable Python and winget unavailable to install one" -ForegroundColor Yellow
        }
    }
    if ($pip) {
        Install-Tool 'jc' {
            Invoke-Expression "$pip install --user jc"
            # pip --user console scripts land in %APPDATA%\Python\Python<ver>\Scripts,
            # which is not on PATH by default -- find jc.exe there and add its dir.
            $userPyRoot = Join-Path $env:APPDATA 'Python'
            $jcExe = Get-ChildItem -Path $userPyRoot -Filter 'jc.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($jcExe) { [void](Add-ToUserPath $jcExe.DirectoryName) }
        } 'jc'
    } else {
        Add-Result 'jc' 'SKIPPED' 'no usable Python/pip (Windows Store stub does not count)'
        Write-Host "  [skip] jc : no usable Python/pip on PATH" -ForegroundColor Yellow
    }
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
