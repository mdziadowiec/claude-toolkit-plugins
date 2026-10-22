<#
.SYNOPSIS
    Repairs nested code-fence collisions in a cc2md markdown export.

.DESCRIPTION
    cc2md (v0.1.0) wraps every tool result in a 3-backtick code fence but does not
    lengthen that fence when the wrapped output already contains ``` fences (common:
    README fetches, file reads, files written in a coding session). The inner fence
    then closes cc2md's wrapper early and the rest of the document mis-renders.

    This script rewrites only the *wrapper* fences so the whole tool output becomes a
    single literal code block:

      - It operates strictly inside cc2md's `<details>` blocks (where tool output
        lives). Prose and user/Claude messages outside `<details>` are never touched.
      - Within a details block it tracks fence nesting. The fence that opens at depth
        0 and the matching fence that returns to depth 0 are the wrapper pair.
      - A wrapper is lengthened to (longest inner backtick run + 1), minimum 4, only
        when it actually contains an inner fence — otherwise it is left as-is.

    Best-effort: a tool output with *unbalanced* inner fences leaves its wrapper
    unmatched; that wrapper is left unchanged and reported. Assumes cc2md's default
    collapsed output (tool calls inside `<details>`).

.PARAMETER Path
    The markdown file to repair in place.

.EXAMPLE
    pwsh -File fix-fences.ps1 -Path session.md
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) { throw "File not found: $Path" }

$lines = [System.IO.File]::ReadAllLines($Path)

# A fenced line: optional indent, >=3 backticks, optional info string.
$fenceRe = [regex]'^(?<indent>\s*)(?<ticks>`{3,})(?<info>.*)$'
# Leading backtick run on any content line (to size the wrapper).
$runRe   = [regex]'^\s*(?<ticks>`+)'

$inDetails = $false
$depth = 0
$wrapperOpen = -1          # line index of the current wrapper's opening fence
$spans = New-Object System.Collections.Generic.List[object]
$unmatched = 0

for ($i = 0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i]

    # Block markers are emitted by cc2md on their own line at column 0. Match the
    # whole line so literal "<details>" text inside tool output (e.g. cc2md --help)
    # does not toggle the state.
    if ($line -eq '<details>')  { $inDetails = $true;  $depth = 0; $wrapperOpen = -1; continue }
    if ($line -eq '</details>') {
        if ($depth -ne 0) { $unmatched++ }   # wrapper left open by unbalanced inner fences
        $inDetails = $false; $depth = 0; $wrapperOpen = -1; continue
    }
    if (-not $inDetails) { continue }

    $m = $fenceRe.Match($line)
    if (-not $m.Success) { continue }

    $hasInfo = $m.Groups['info'].Value.Trim().Length -gt 0
    if ($hasInfo) {
        # An info string (```bash) can only open a block.
        if ($depth -eq 0) { $wrapperOpen = $i }
        $depth++
    } else {
        if ($depth -gt 0) {
            $depth--
            if ($depth -eq 0 -and $wrapperOpen -ge 0) {
                $spans.Add([pscustomobject]@{ Open = $wrapperOpen; Close = $i })
                $wrapperOpen = -1
            }
        } else {
            # bare fence at depth 0 -> wrapper open
            $wrapperOpen = $i
            $depth++
        }
    }
}

$fixed = 0
foreach ($span in $spans) {
    # Longest backtick run among the wrapper's content lines.
    $maxRun = 0
    for ($j = $span.Open + 1; $j -lt $span.Close; $j++) {
        $rm = $runRe.Match($lines[$j])
        if ($rm.Success) {
            $len = $rm.Groups['ticks'].Value.Length
            if ($len -gt $maxRun) { $maxRun = $len }
        }
    }
    if ($maxRun -lt 3) { continue }            # no inner fence -> no collision -> leave it
    $need = [Math]::Max(4, $maxRun + 1)
    foreach ($idx in @($span.Open, $span.Close)) {
        $fm = $fenceRe.Match($lines[$idx])
        $indent = $fm.Groups['indent'].Value
        $lines[$idx] = $indent + ('`' * $need)
    }
    $fixed++
}

if ($fixed -gt 0) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($Path, $lines, $utf8NoBom)
}

Write-Host "fix-fences: repaired $fixed tool-output wrapper(s) in $Path"
if ($unmatched -gt 0) {
    Write-Host "fix-fences: $unmatched wrapper(s) had unbalanced inner fences and were left unchanged" -ForegroundColor Yellow
}
exit 0
