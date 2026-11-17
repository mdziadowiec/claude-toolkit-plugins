#Requires -Version 7
# Shared helpers for the confluence-drawio scripts. Dot-source it: . "$PSScriptRoot\ConfluenceCommon.ps1"

function Get-ConfluenceSite {
    param([string] $Site)
    if (-not $Site) { $Site = [Environment]::GetEnvironmentVariable('ATLASSIAN_SITE', 'User') }
    if (-not $Site) { $Site = $env:ATLASSIAN_SITE }
    if (-not $Site) { throw 'Pass -Site (for example example.atlassian.net) or set the user environment variable ATLASSIAN_SITE.' }
    'https://' + ($Site -replace '^https?://', '').TrimEnd('/')
}

function Get-ConfluenceHeaders {
    $token = [Environment]::GetEnvironmentVariable('ATLASSIAN_API_TOKEN', 'User')
    $email = [Environment]::GetEnvironmentVariable('ATLASSIAN_EMAIL', 'User')
    if (-not $token -or -not $email) {
        throw 'Set the user environment variables ATLASSIAN_API_TOKEN and ATLASSIAN_EMAIL (see the skill, section "Credentials").'
    }
    $basic = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${email}:${token}"))
    @{ Authorization = "Basic $basic"; Accept = 'application/json' }
}

# The attachment download redirects to the media host, and PowerShell drops the Authorization header on a redirect
# to another host, which ends in a 401. Follow the redirect by hand: the media URL carries its own token.
function Save-ConfluenceAttachment {
    param([string] $Base, [hashtable] $Headers, [string] $PageId, [string] $AttachmentId, [string] $OutFile)
    $url = "$Base/wiki/rest/api/content/$PageId/child/attachment/$AttachmentId/download"
    $r = Invoke-WebRequest $url -Headers @{ Authorization = $Headers.Authorization } -MaximumRedirection 0 -SkipHttpErrorCheck -ErrorAction SilentlyContinue
    if ($r.StatusCode -in 301, 302, 303, 307, 308) {
        Invoke-WebRequest $r.Headers.Location[0] -OutFile $OutFile
    } elseif ($r.StatusCode -eq 200) {
        [IO.File]::WriteAllBytes($OutFile, $r.RawContentStream.ToArray())
    } else {
        throw "Download of attachment $AttachmentId failed with HTTP $($r.StatusCode)."
    }
}

function Get-DrawioMacros {
    # Returns diagramName and revision of every draw.io macro in an ADF body (JSON text).
    param([string] $AdfJson)
    $doc = $AdfJson | ConvertFrom-Json -Depth 200
    $found = [System.Collections.Generic.List[object]]::new()
    $walk = {
        param($node)
        if ($node -is [System.Array]) { foreach ($n in $node) { & $walk $n }; return }
        if ($node -isnot [psobject]) { return }
        if ($node.type -eq 'extension' -and $node.attrs.extensionKey -eq 'drawio') {
            $p = $node.attrs.parameters.macroParams
            $found.Add([pscustomobject]@{ Name = $p.diagramName.value; Revision = [int]$p.revision.value; CustomContentId = $p.custContentId.value })
        }
        foreach ($prop in $node.PSObject.Properties) { if ($prop.Value -is [psobject] -or $prop.Value -is [System.Array]) { & $walk $prop.Value } }
    }
    & $walk $doc
    $found
}
