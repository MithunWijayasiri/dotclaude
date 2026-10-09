# Provision a worktree: nesting guard, shared node_modules junction, root .env* copy.
# Usage: wt-create.ps1 -Main <main repo> [-Wt <worktree>] [-ForceJunction]
#   -Wt omitted -> guard only (run before EnterWorktree).
# Exit: 0 ok, 1 error/guard refusal, 2 lockfile DRIFT (node_modules not linked).
param(
    [Parameter(Mandatory = $true)][string]$Main,
    [string]$Wt,
    [switch]$ForceJunction
)

$ErrorActionPreference = 'Stop'

function Norm([string]$p) { [IO.Path]::GetFullPath($p).TrimEnd('\') }
function CountNest([string]$p) { ([regex]::Matches($p, '\\\.claude\\worktrees\\', 'IgnoreCase')).Count }

try {
    $Main = Norm $Main
    if (-not (Test-Path -LiteralPath $Main -PathType Container)) { throw "Main not found: $Main" }

    # Guard-only mode runs before EnterWorktree, so cwd is still where the user started.
    $cwd = (Get-Location).Path + '\'
    if ((CountNest $Main) -gt 0 -or (-not $Wt -and (CountNest $cwd) -gt 0)) {
        throw "already inside .claude\worktrees (Main=$Main, cwd=$cwd); worktrees don't nest. Remove or exit the current worktree first."
    }

    if (-not $Wt) { Write-Output 'guard: ok'; exit 0 }

    $Wt = Norm $Wt
    if (-not (Test-Path -LiteralPath $Wt -PathType Container)) { throw "Wt not found: $Wt" }
    if ((CountNest ($Wt + '\')) -gt 1) { throw "Wt is nested under another worktree: $Wt" }
    if ($Wt -ieq $Main) { throw 'Wt equals Main' }

    # .env*: copy root-level files from Main that Wt lacks
    $copied = @()
    foreach ($f in (Get-ChildItem -LiteralPath $Main -Filter '.env*' -File -Force)) {
        $dest = Join-Path $Wt $f.Name
        if (-not (Test-Path -LiteralPath $dest)) {
            Copy-Item -LiteralPath $f.FullName -Destination $dest
            $copied += $f.Name
        }
    }

    # node_modules
    $mode = $null
    $nmWt = Join-Path $Wt 'node_modules'
    $nmMain = Join-Path $Main 'node_modules'
    $exit = 0

    if (-not (Test-Path -LiteralPath (Join-Path $Wt 'package.json'))) {
        $mode = 'skipped (no package.json)'
    }
    elseif (Test-Path -LiteralPath $nmWt) {
        $mode = 'skipped (node_modules already exists)'
    }
    elseif (-not (Test-Path -LiteralPath $nmMain -PathType Container)) {
        $mode = 'skipped (Main has no node_modules)'
    }
    else {
        $lockMain = Join-Path $Main 'package-lock.json'
        $lockWt = Join-Path $Wt 'package-lock.json'
        $same = $false
        $why = ''
        if (-not (Test-Path -LiteralPath $lockMain) -or -not (Test-Path -LiteralPath $lockWt)) {
            $why = 'package-lock.json missing in Main or Wt'
        }
        elseif ((Get-FileHash -LiteralPath $lockMain).Hash -eq (Get-FileHash -LiteralPath $lockWt).Hash) {
            $same = $true
        }
        else {
            $why = 'package-lock.json differs between Main and Wt'
        }

        if ($same -or $ForceJunction) {
            New-Item -ItemType Junction -Path $nmWt -Target $nmMain | Out-Null
            $mode = if ($same) { 'junction' } else { 'junction (forced despite drift)' }
        }
        else {
            $mode = "DRIFT ($why); not linked. Re-run with -ForceJunction, or run npm ci in Wt."
            $exit = 2
        }
    }

    Write-Output "node_modules: $mode"
    $envReport = if ($copied.Count -gt 0) { $copied -join ', ' } else { 'none' }
    Write-Output "env copied: $envReport"
    exit $exit
}
catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    exit 1
}
