#Requires -Version 7
<#
.SYNOPSIS
Publishes an ADF body as the next version of a Confluence page, and refuses when the page changed since the draft
was based on it.

.DESCRIPTION
Publishing is visible to everyone who can read the page: run it only after the user approved this page's changes.
The draw.io macros in the body are published as they are; a diagram change goes through the draw.io editor
afterwards (see the skill).

.PARAMETER ExpectedVersion
The version the draft was based on (page-<id>.meta.json of Get-ConfluencePage.ps1). If the live page has another
version, someone edited it in between: download it again and merge, never overwrite.

.EXAMPLE
.\Publish-ConfluencePage.ps1 -PageId 123456789 -AdfFile .\fix\page-123456789.json -ExpectedVersion 8 -Message 'Examples match the current API'
#>
param(
    [Parameter(Mandatory)] [string] $PageId,
    [Parameter(Mandatory)] [string] $AdfFile,
    [Parameter(Mandatory)] [int] $ExpectedVersion,
    [string] $Title,
    [string] $Message = 'Updated',
    [string] $Site
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\ConfluenceCommon.ps1"
$base = Get-ConfluenceSite $Site
$h = Get-ConfluenceHeaders
$url = "$base/wiki/api/v2/pages/$PageId"

$live = Invoke-RestMethod $url -Headers $h
if ($live.version.number -ne $ExpectedVersion) {
    throw "Page $PageId is at version $($live.version.number); the draft is based on $ExpectedVersion. Download it again and merge."
}
$adf = [IO.File]::ReadAllText((Resolve-Path $AdfFile))
$null = $adf | ConvertFrom-Json -Depth 200
$body = @{
    id      = $PageId
    status  = 'current'
    title   = if ($Title) { $Title } else { $live.title }
    body    = @{ representation = 'atlas_doc_format'; value = $adf }
    version = @{ number = $ExpectedVersion + 1; message = $Message }
} | ConvertTo-Json -Depth 5
$r = Invoke-RestMethod $url -Method Put -Headers $h -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body))
"published $PageId as version $($r.version.number): $($r.title)"
