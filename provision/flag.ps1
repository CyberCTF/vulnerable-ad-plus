# Places the player's flag (CTF_FLAG_MAIN, given by the launcher) in C:\ctf\flag.txt, readable
# only by the local Administrators group and SYSTEM: getting it means administrative control of
# the machine. Without one (CI, a run by hand) the development flag.
# Plain PowerShell 2.0 and icacls, so it runs on every Windows version the labs use.
$ErrorActionPreference = 'Stop'
$dev = 'FLAG{dev-vulnerable-ad-plus}'
# The launcher delivers the flag as a file (a sensitive input); without it the development flag.
$seed = 'C:\Windows\Temp\ctf_flag_main'
$flag = ''
if (Test-Path $seed) { $flag = ([IO.File]::ReadAllText($seed)).Trim() }
if (-not $flag) { $flag = $dev }
if (Test-Path $seed) { Remove-Item -Force $seed -ErrorAction SilentlyContinue }
$dir = 'C:\ctf'
$file = Join-Path $dir 'flag.txt'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
[IO.File]::WriteAllText($file, "$flag`r`n", (New-Object Text.ASCIIEncoding))
# Administrators (S-1-5-32-544) and SYSTEM (S-1-5-18) only, nothing inherited.
foreach ($p in @($dir, $file)) {
  icacls $p /inheritance:r /grant:r '*S-1-5-32-544:(F)' '*S-1-5-18:(F)' | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "icacls $p failed" }
}
attrib +R $file
exit 0
