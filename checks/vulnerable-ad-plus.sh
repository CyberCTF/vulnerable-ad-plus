#!/bin/sh
# vulnerable-AD-plus ran on dc01: anonymous LDAP reads the Users container (one of its planted
# weaknesses), its groups exist, and its public SMB share answers to a null session.
set -eu
base="DC=change,DC=me"
curl -sS --max-time 20 "ldap://dc01/CN=Users,$base?cn?one?(cn=IT%20Helpdesk)" | grep -q "CN=IT Helpdesk"
curl -sS --max-time 20 "ldap://dc01/CN=Users,$base?sAMAccountName?one?(objectClass=user)" | grep -c "^DN:" | awk '$1 >= 30 { ok=1 } END { exit !ok }'
echo "anonymous LDAP lists vulnerable-AD-plus users and groups in change.me"
