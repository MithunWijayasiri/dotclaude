# Pre-removal helper for a worktree. Never removes the worktree itself.
# Usage: wt-remove.ps1 -Wt <worktree> [-Report] [-Unlink]
#   -Report: uncommitted, ignored (minus node_modules), unpushed commits on HEAD (capped).
#   -Unlink: remove node_modules junction only (never recursive).
# Exit: 0 ok, 1 error, 3 refused (node_modules is a non-junction link).
param(
    [Parameter(Mandatory = $true)][string]$Wt,
    [switch]$Report,
    [switch]$Unlink
)

$ErrorActionPreference = 'Stop'
$cap = 30

function ShowCapped([string]$title, [string[]]$lines) {
    $lines = @($lines | Where-Object { $_ })
    if ($lines.Count -eq 0) { Write-Output "${title}: none"; return }
    Write-Output "${title}: $($lines.Count)"
    $lines | Select-Object -First $cap | ForEach-Object { Write-Output "  $_" }
    if ($lines.Count -gt $cap) { Write-Output "  ... +$($lines.Count - $cap) more" }
}

try {
    if (-not ($Report -or $Unlink)) { throw 'pass -Report and/or -Unlink' }
    $Wt = [IO.Path]::GetFullPath($Wt).TrimEnd('\')
    if (-not (Test-Path -LiteralPath $Wt -PathType Container)) { throw "Wt not found: $Wt" }

    if ($Report) {
        $status = @(git -C $Wt status --short)
        if ($LASTEXITCODE -ne 0) { throw 'git status failed' }
        $ignored = @(git -C $Wt status --short --ignored | Where-Object { $_ -like '!! *' -and $_ -ne '!! node_modules/' })
        if ($LASTEXITCODE -ne 0) { throw 'git status --ignored failed' }
        $unpushed = @(git -C $Wt log --oneline HEAD --not --remotes)
        if ($LASTEXITCODE -ne 0) { throw 'git log failed' }
        ShowCapped 'uncommitted' $status
        ShowCapped 'ignored' $ignored
        ShowCapped 'unpushed commits' $unpushed
    }

    if ($Unlink) {
        $nm = Join-Path $Wt 'node_modules'
        $item = Get-Item -LiteralPath $nm -Force -ErrorAction SilentlyContinue
        if ($null -eq $item) {
            Write-Output 'node_modules: none'
        }
        elseif ($item.LinkType -eq 'Junction') {
            $item.Delete() # non-recursive: removes the reparse point only
            if (Test-Path -LiteralPath $nm) { throw "delete failed on junction: $nm" }
            Write-Output 'node_modules: junction unlinked (target untouched)'
        }
        elseif ($item.LinkType) {
            Write-Output "REFUSED: node_modules is a $($item.LinkType), not a Junction; left untouched."
            exit 3
        }
        else {
            Write-Output 'node_modules: real directory, not a junction; left untouched'
        }
    }
    exit 0
}
catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    exit 1
}
