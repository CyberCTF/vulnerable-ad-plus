# vulnerable-AD-plus

[vulnerable-AD-plus](https://github.com/WaterExecution/vulnerable-AD-plus) by WaterExecution, a
fork of [vulnerable-AD](https://github.com/safebuffer/vulnerable-AD) with more misconfigurations
and chained attack paths (a [write-up](vulnerable-AD-plus/WriteUp/README.md) comes with it). This
repository runs it with [Isoloom](https://www.isoloom.com): [`isoloom.yml`](isoloom.yml) describes
the machine, and [`provision/main.yml`](provision/main.yml) builds it from a controller: it
promotes a new forest, `change.me` (the domain upstream's script calls itself with), then runs
upstream's [`vulnadplus.ps1`](vulnerable-AD-plus/vulnadplus.ps1) unchanged.

| Machine | Name | Services |
| --- | --- | --- |
| dc01 | domain controller of change.me (Windows Server 2019) | DNS 53, Kerberos 88, RPC 135, LDAP 389, SMB 445, WinRM 5985 |

Users and paths are random on every build. What the script plants: anonymous LDAP reads, a
public SMB share (Guest enabled), leaked and shared passwords, Kerberoastable and AS-REP
roastable accounts, ACL chains between users and groups, DnsAdmins members, DCSync rights, WinRM
open to everyone, SMB client signing off and the firewall off.

## Run it

```bash
isoloom run vagrant
isoloom test vagrant
```

About 4 GB of memory (3 GB for the domain controller, 1 GB for the controller) and 20 minutes.
The Windows Server 2019 box is an evaluation build downloaded by Vagrant.

The script runs as a scheduled task (SYSTEM) on the domain controller rather than in the
playbook's WinRM session, because its WinRM step restarts the WinRM service. Two of its calls
can't run unattended; [`provision/run-vulnadplus.ps1`](provision/run-vulnadplus.ps1) defines
functions of the same name before running it, so the script itself stays unchanged:
`Set-SmbClientConfiguration -Confirm` (nobody to answer) applies the same setting without the
prompt, and the final `Restart-Computer` is done by the playbook once the script has finished.

Upstream version and commit: [UPSTREAM.md](UPSTREAM.md).

## Licence

MIT, as vulnerable-AD-plus ([LICENSE](LICENSE)). This lab is deliberately vulnerable: keep it
isolated.
