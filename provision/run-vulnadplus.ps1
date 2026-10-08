# Runs upstream's vulnadplus.ps1, unchanged, as a scheduled task (SYSTEM) rather than over WinRM:
# its VulnAD-EnableWinRM step restarts the WinRM service, which ends any WinRM session running
# it. Two of its calls can't run unattended, so functions of the same name, defined first, stand
# in for them (PowerShell prefers a function to a cmdlet): Set-SmbClientConfiguration with an
# explicit -Confirm (nobody to answer) applies the same setting without the prompt, and its final
# Restart-Computer is left to the playbook, which reboots once this script has written `done`.
$dir = 'C:\vulnerable-AD-plus'
Set-Location $dir
Start-Transcript -Path "$dir\run.log" -Force | Out-Null
function Set-SmbClientConfiguration {
  param($RequireSecuritySignature, $EnableSecuritySignature, [switch]$Confirm, [switch]$Force)
  SmbShare\Set-SmbClientConfiguration -RequireSecuritySignature $RequireSecuritySignature -EnableSecuritySignature $EnableSecuritySignature -Confirm:$false -Force
}
function Restart-Computer { Write-Output "(restart left to the playbook)" }
try { & "$dir\vulnadplus.ps1" } catch { Write-Output "vulnadplus.ps1 stopped: $_" }
Stop-Transcript | Out-Null
New-Item -ItemType File -Force "$dir\done" | Out-Null
