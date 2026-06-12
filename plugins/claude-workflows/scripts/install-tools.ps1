<#
.SYNOPSIS
    Installs the external tools required by the claude-workflows plugin (Windows).

.DESCRIPTION
    Currently provisions:
      cc2md  - converts Claude Code session logs to markdown (used by /export-md).
               Installed from the prebuilt GitHub release binary into
               %USERPROFILE%\.claude\bin, which is added to the user PATH.

    Idempotent: a tool already resolvable on PATH (or already present in the
    target bin dir) is skipped. A per-tool failure is reported but does not
    abort the rest of the run. Re-run after install if PATH changes have not
    taken effect in the current shell.

.PARAMETER Force
    Reinstall cc2md even if it is already present (picks up the latest release).

.EXAMPLE
    pwsh -File install-tools.ps1
.EXAMPLE
    pwsh -File install-tools.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch]$Force
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

Write-Host "claude-workflows tool installer (Windows)" -ForegroundColor White
Write-Host "-----------------------------------------"

$binDir = Join-Path $env:USERPROFILE '.claude\bin'
$cc2mdExe = Join-Path $binDir 'cc2md.exe'

# --- cc2md ----------------------------------------------------------------
Write-Host "`ncc2md (Claude Code session -> markdown):" -ForegroundColor White

$alreadyOnPath = Test-Cmd 'cc2md'
$alreadyInBin  = Test-Path $cc2mdExe

if (($alreadyOnPath -or $alreadyInBin) -and -not $Force) {
    # Make sure the managed bin dir is on PATH even when we skip the download.
    if ($alreadyInBin) { [void](Add-ToUserPath $binDir) }
    $where = if ($alreadyOnPath) { 'on PATH' } else { "in $binDir" }
    Add-Result 'cc2md' 'already installed' $where
    Write-Host "  [skip] cc2md already present ($where). Use -Force to reinstall." -ForegroundColor DarkGray
} else {
    Write-Host "  [install] downloading prebuilt cc2md from GitHub releases ..." -ForegroundColor Cyan
    try {
        # Windows PowerShell 5.1 negotiates TLS 1.0/1.1 by default, which GitHub rejects.
        [System.Net.ServicePointManager]::SecurityProtocol = `
            [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

        if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir -Force | Out-Null }

        $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("cc2md_" + [System.Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tmp -Force | Out-Null
        $zip = Join-Path $tmp 'cc2md.zip'

        # /releases/latest/download/ redirects to the newest published asset.
        $url = 'https://github.com/magarcia/cc2md/releases/latest/download/cc2md_Windows_x86_64.zip'
        Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing

        Expand-Archive -Path $zip -DestinationPath $tmp -Force
        $src = Get-ChildItem -Path $tmp -Filter 'cc2md.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $src) { throw "cc2md.exe not found in the downloaded archive" }
        Copy-Item -Path $src.FullName -Destination $cc2mdExe -Force
        Remove-Item -Path $tmp -Recurse -Force -ErrorAction SilentlyContinue

        [void](Add-ToUserPath $binDir)

        $ver = (& $cc2mdExe --version 2>$null)
        if ($ver) {
            Add-Result 'cc2md' 'installed' "$binDir ($ver)"
            Write-Host "  [ok] cc2md installed: $ver" -ForegroundColor Green
        } else {
            Add-Result 'cc2md' 'installed (restart shell)' "binary at $cc2mdExe; reopen terminal for PATH"
            Write-Host "  [ok] cc2md installed to $cc2mdExe (reopen terminal to pick up PATH)" -ForegroundColor Yellow
        }
    } catch {
        Add-Result 'cc2md' 'FAILED' $_.Exception.Message
        Write-Host "  [fail] cc2md : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- Summary --------------------------------------------------------------
Write-Host "`nSummary:" -ForegroundColor White
$results | Format-Table -AutoSize

$failed = @($results | Where-Object { $_.Status -eq 'FAILED' })
if ($failed.Count -gt 0) {
    Write-Host "`n$($failed.Count) tool(s) failed. See details above." -ForegroundColor Yellow
    exit 1
}
Write-Host "`nDone. You may need to reopen the terminal for PATH changes to take effect." -ForegroundColor Green
exit 0
