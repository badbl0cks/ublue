#!/usr/bin/env bash
set -euo pipefail

# Runs inside the `hostiqo` distrobox container AFTER install-hostiqo.sh.
# Patches fail2ban so every jail bans via host firewalld ipsets, and the
# [sshd] jail reads the host journal (bind-mounted ro at /var/log/journal).
# See plan: /home/rob/.claude/plans/let-s-explore-approach-4-snoopy-newell.md

JAIL_D="/etc/fail2ban/jail.d"
mkdir -p "${JAIL_D}"

# 1. Switch default banaction to firewallcmd-ipset (host firewalld ipset).
#    Replaces install-hostiqo.sh's iptables-multiport default.
cat > "${JAIL_D}/00-defaults.local" <<'EOF'
[DEFAULT]
banaction = firewallcmd-ipset[ipset=fail2ban-default, ipset6=fail2ban-default-ipv6, type=ip]
banaction_allports = firewallcmd-ipset[ipset=fail2ban-default, ipset6=fail2ban-default-ipv6, type=ip]
EOF

# 2. sshd: read host journald, pin port to 24 (host SSH port).
#    logpath= explicitly empty overrides the script's /var/log/auth.log
#    which does not exist on uCore/Fedora (journald-only).
cat > "${JAIL_D}/10-sshd.local" <<'EOF'
[sshd]
enabled = true
backend = systemd
journalmatch = _SYSTEMD_UNIT=sshd.service + _COMM=sshd
port = 24
logpath =
maxretry = 3
findtime = 60
bantime = 604800

[sshd-ddos]
enabled = true
backend = systemd
journalmatch = _SYSTEMD_UNIT=sshd.service + _COMM=sshd
port = 24
logpath =
maxretry = 6
findtime = 60
bantime = 3600
EOF

# 3. recidive: long-bantime ipset on host firewalld.
cat > "${JAIL_D}/40-recidive.local" <<'EOF'
[recidive]
enabled = true
action = firewallcmd-ipset[ipset=fail2ban-recidive, ipset6=fail2ban-recidive-ipv6, type=ip]
EOF

# 4. Disable container-local firewalld. The container has no business
#    running its own firewalld - firewall-cmd inside the container must
#    talk to the host's firewalld over the bind-mounted D-Bus socket.
systemctl disable --now firewalld.service >/dev/null 2>&1 || true

# 5. Restart fail2ban so the new jail config takes effect.
systemctl restart fail2ban.service

# 6. Smoke tests
echo "Smoke test: fail2ban-client status"
fail2ban-client status

echo "Smoke test: firewall-cmd --state (should reach HOST firewalld via D-Bus)"
firewall-cmd --state

echo "Smoke test: host ipset reachable"
firewall-cmd --ipset=fail2ban-default --get-entries >/dev/null && echo "OK"

echo "post-install-hostiqo.sh complete"
