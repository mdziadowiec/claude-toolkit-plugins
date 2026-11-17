#Requires -Version 7
<#
.SYNOPSIS
Compares a page's editor draft with its published version: text diff, inline comments, draw.io revisions.

.DESCRIPTION
Run it before clicking Update in the page editor. The text must be identical (the text was published before) and only
the revisions of the diagrams you saved may differ. The draft API can lag the editor by a minute; when a revision you
just saved still shows the old number, read it from the editor instead (see the skill).
#>
param(
    [Parameter(Mandatory)] [string] $PageId,
    [string] $OutDir = (Join-Path ([IO.Path]::GetTempPath()) 'confluence-drawio-verify'),
    [string] $Site
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\ConfluenceCommon.ps1"
$base = Get-ConfluenceSite $Site
$h = Get-ConfluenceHeaders
$dir = Join-Path $OutDir $PageId
New-Item -ItemType Directory -Force $dir | Out-Null

$url = "$base/wiki/api/v2/pages/$PageId"
$pub = Invoke-RestMethod "${url}?body-format=atlas_doc_format" -Headers $h
$draft = Invoke-RestMethod "${url}?get-draft=true&body-format=atlas_doc_format" -Headers $h
[IO.File]::WriteAllText("$dir\pub.json", $pub.body.atlas_doc_format.value)
[IO.File]::WriteAllText("$dir\draft.json", $draft.body.atlas_doc_format.value)

"published v$($pub.version.number)"
python3 -I (Join-Path $PSScriptRoot 'review_page.py') "$dir\pub.json" "$dir\draft.json"
'published: ' + ((Get-DrawioMacros $pub.body.atlas_doc_format.value | ForEach-Object { "$($_.Name) r$($_.Revision)" }) -join ', ')
'draft:     ' + ((Get-DrawioMacros $draft.body.atlas_doc_format.value | ForEach-Object { "$($_.Name) r$($_.Revision)" }) -join ', ')
