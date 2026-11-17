#Requires -Version 7
<#
.SYNOPSIS
Downloads a Confluence page body (ADF) and the XML of its draw.io diagrams, and checks that each diagram's
macro revision matches its attachment version.

.DESCRIPTION
Writes, per page:
  <OutDir>\page-<id>.json        the ADF body (the value of body.atlas_doc_format)
  <OutDir>\page-<id>.meta.json   id, title, version
  <OutDir>\drawio\<id>-<name>    the diagram XML, one file per draw.io macro (name with unsafe characters replaced)
Prints one line per page and diagram. "MISMATCH" means the page shows another revision than the newest attachment:
a save was half done or the page was not updated after the draw.io save.

.EXAMPLE
.\Get-ConfluencePage.ps1 -PageId 123456789 -OutDir C:\temp\pages -IncludeChildren
#>
param(
    [Parameter(Mandatory)] [string] $PageId,
    [Parameter(Mandatory)] [string] $OutDir,
    [string] $Site,
    [switch] $IncludeChildren
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\ConfluenceCommon.ps1"
$base = Get-ConfluenceSite $Site
$h = Get-ConfluenceHeaders
New-Item -ItemType Directory -Force (Join-Path $OutDir 'drawio') | Out-Null

$ids = @($PageId)
if ($IncludeChildren) {
    $ids += (Invoke-RestMethod "$base/wiki/api/v2/pages/$PageId/children?limit=250" -Headers $h).results.id
}

foreach ($id in $ids) {
    $pg = Invoke-RestMethod "$base/wiki/api/v2/pages/${id}?body-format=atlas_doc_format" -Headers $h
    $adf = $pg.body.atlas_doc_format.value
    [IO.File]::WriteAllText((Join-Path $OutDir "page-$id.json"), $adf)
    [IO.File]::WriteAllText((Join-Path $OutDir "page-$id.meta.json"),
        (@{ id = $id; title = $pg.title; version = $pg.version.number } | ConvertTo-Json))
    "page $id v$($pg.version.number): $($pg.title)"

    foreach ($m in Get-DrawioMacros $adf) {
        $q = [Uri]::EscapeDataString($m.Name)
        $att = (Invoke-RestMethod "$base/wiki/rest/api/content/$id/child/attachment?filename=$q&expand=version" -Headers $h).results | Select-Object -First 1
        if (-not $att) { "  $($m.Name): macro r$($m.Revision), NO ATTACHMENT"; continue }
        $file = Join-Path $OutDir ('drawio\' + $id + '-' + ($m.Name -replace '[^\w.-]', '_'))
        Save-ConfluenceAttachment -Base $base -Headers $h -PageId $id -AttachmentId $att.id -OutFile $file
        $state = if ($att.version.number -eq $m.Revision) { 'ok' } else { 'MISMATCH' }
        "  $($m.Name): macro r$($m.Revision), attachment v$($att.version.number) $state -> $file"
    }
}
