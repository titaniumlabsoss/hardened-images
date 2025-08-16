#!/bin/bash
# Audit logging and monitoring configuration

set -e

echo "=== Starting Audit Logging Configuration ==="

# STIG V-270656, V-270657: Enable auditd service
# Configure for container environment - service will be started by init system
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl enable auditd.service
else
    # Create enable link manually
    mkdir -p /etc/systemd/system/multi-user.target.wants
    ln -sf /lib/systemd/system/auditd.service /etc/systemd/system/multi-user.target.wants/auditd.service
fi

# Configure auditd
cat > /etc/audit/auditd.conf << 'EOF'
# STIG-compliant auditd configuration

# Primary audit log file location
log_file = /var/log/audit/audit.log

# Enable writing audit logs to disk (yes = enabled, no = disabled)
write_logs = yes

# Log format type (RAW = machine readable format for analysis tools)
log_format = RAW

# Group ownership of log files (root for maximum security)
log_group = root

# Process priority boost (4 = higher priority to ensure audit logging isn't delayed)
priority_boost = 4

# Flush method for writing logs to disk
# incremental_async = periodic async writes for performance with data protection
flush = incremental_async

# Frequency of log flushes to disk (50 = every 50 records)
freq = 50

# Maximum size of individual log files in MB (10 MB per file)
max_log_file = 10

# Number of log files to retain (5 files = 50MB total before oldest is deleted)
num_logs = 5

# Action when max log file size reached (rotate = create new file, keep old ones)
max_log_file_action = rotate

# Disk space threshold in KB for space_left_action trigger (250MB remaining)
space_left = 250000

# Action when space_left threshold reached (email = send notification to admin)
space_left_action = email

# Email recipient for space_left notifications
action_mail_acct = root

# Critical disk space threshold in MB (50MB remaining)
admin_space_left = 50

# Action when admin_space_left reached (halt = stop system to preserve audit integrity)
admin_space_left_action = halt

# Action when disk becomes completely full (halt = stop system)
disk_full_action = halt

# Action on disk write errors (halt = stop system to maintain audit integrity)
disk_error_action = halt

# Enable TCP wrappers for network access control (yes = use /etc/hosts.allow/deny)
use_libwrap = yes

# TCP listen queue size for remote audit connections (5 pending connections)
tcp_listen_queue = 5

# Maximum TCP connections per IP address (1 = single connection per source)
tcp_max_per_addr = 1

# TCP client idle timeout (0 = no timeout, maintain persistent connections)
tcp_client_max_idle = 0

# Disable Kerberos authentication (no = use simpler authentication methods)
enable_krb5 = no

# Kerberos principal name for audit daemon (if Kerberos were enabled)
krb5_principal = auditd
EOF

# STIG V-270658: Configure audisp-remote for log forwarding
cat > /etc/audit/plugins.d/au-remote.conf << 'EOF'
# Remote audit log forwarding configuration

# Enable the remote forwarding plugin (yes = active, no = disabled)
active = yes

# Data flow direction (out = send logs to remote server)
direction = out

# Path to the remote forwarding executable
path = /sbin/audisp-remote

# When to activate plugin (always = for all audit events)
type = always

# Format for forwarded data (string = human-readable text format)
format = string
EOF

# Create comprehensive audit rules
cat > /etc/audit/rules.d/stig.rules << 'EOF'
# STIG audit rules for Ubuntu 24.04 LTS

# Remove any existing rules
-D

# Buffer Size
-b 8192

# Failure Mode (2 = panic)
-f 1

# STIG V-270684: Monitor /etc/passwd
-w /etc/passwd -p wa -k usergroup_modification

# STIG V-270685: Monitor /etc/group
-w /etc/group -p wa -k usergroup_modification

# STIG V-270686: Monitor /etc/shadow
-w /etc/shadow -p wa -k usergroup_modification

# STIG V-270687: Monitor /etc/gshadow
-w /etc/gshadow -p wa -k usergroup_modification

# STIG V-270688: Monitor /etc/security/opasswd
-w /etc/security/opasswd -p wa -k usergroup_modification

# STIG V-270689: Monitor privilege escalation
-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -F key=execpriv
-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -F key=execpriv
-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -F key=execpriv
-a always,exit -F arch=b32 -S execve -C gid!=egid -F egid=0 -F key=execpriv

# STIG V-270715: Monitor systemd journal
-w /var/log/journal -p wa -k systemd_journal

# STIG V-270740: Monitor sudo usage
-w /var/log/sudo.log -p wa -k maintenance

# STIG V-270778: Monitor su command
-a always,exit -F path=/bin/su -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-priv_change

# STIG V-270779: Monitor chfn command
-a always,exit -F path=/usr/bin/chfn -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-chfn

# STIG V-270780: Monitor mount command
-a always,exit -F path=/usr/bin/mount -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-mount

# STIG V-270781: Monitor umount command
-a always,exit -F path=/usr/bin/umount -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-umount

# STIG V-270782: Monitor ssh-agent command
-a always,exit -F path=/usr/bin/ssh-agent -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-ssh

# STIG V-270783: Monitor ssh-keysign command
-a always,exit -F path=/usr/lib/openssh/ssh-keysign -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-ssh

# STIG V-270784: Monitor file attribute changes
-a always,exit -F arch=b32 -S setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr -F auid=0 -k perm_mod
-a always,exit -F arch=b64 -S setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr -F auid=0 -k perm_mod

# STIG V-270785: Monitor ownership changes
-a always,exit -F arch=b32 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=-1 -k perm_chng
-a always,exit -F arch=b64 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=-1 -k perm_chng

# STIG V-270786: Monitor permission changes
-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=-1 -k perm_chng
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=-1 -k perm_chng

# STIG V-270787: Monitor file access attempts
-a always,exit -F arch=b32 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k perm_access
-a always,exit -F arch=b32 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k perm_access
-a always,exit -F arch=b64 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k perm_access
-a always,exit -F arch=b64 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k perm_access

# STIG V-270788: Monitor sudo command
-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=-1 -k priv_cmd

# STIG V-270789: Monitor sudoedit command
-a always,exit -F path=/usr/bin/sudoedit -F perm=x -F auid>=1000 -F auid!=-1 -k priv_cmd

# STIG V-270790: Monitor chsh command
-a always,exit -F path=/usr/bin/chsh -F perm=x -F auid>=1000 -F auid!=-1 -k priv_cmd

# STIG V-270791: Monitor newgrp command
-a always,exit -F path=/usr/bin/newgrp -F perm=x -F auid>=1000 -F auid!=-1 -k priv_cmd

# STIG V-270792: Monitor chcon command
-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=-1 -k perm_chng

# STIG V-270793: Monitor apparmor_parser command
-a always,exit -F path=/sbin/apparmor_parser -F perm=x -F auid>=1000 -F auid!=-1 -k perm_chng

# STIG V-270794: Monitor setfacl command
-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=1000 -F auid!=-1 -k perm_chng

# STIG V-270795: Monitor chacl command
-a always,exit -F path=/usr/bin/chacl -F perm=x -F auid>=1000 -F auid!=-1 -k perm_chng

# STIG V-270796: Monitor faillog
-w /var/log/faillog -p wa -k logins

# STIG V-270797: Monitor lastlog
-w /var/log/lastlog -p wa -k logins

# STIG V-270798: Monitor passwd command
-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-passwd

# STIG V-270799: Monitor unix_update command
-a always,exit -F path=/sbin/unix_update -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-unix-update

# STIG V-270800: Monitor gpasswd command
-a always,exit -F path=/usr/bin/gpasswd -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-gpasswd

# STIG V-270801: Monitor chage command
-a always,exit -F path=/usr/bin/chage -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-chage

# STIG V-270802: Monitor usermod command
-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-usermod

# STIG V-270803: Monitor crontab command
-a always,exit -F path=/usr/bin/crontab -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-crontab

# STIG V-270804: Monitor pam_timestamp_check command
-a always,exit -F path=/usr/sbin/pam_timestamp_check -F perm=x -F auid>=1000 -F auid!=-1 -k privileged-pam_timestamp_check

# STIG V-270805: Monitor module loading
-a always,exit -F arch=b32 -S init_module,finit_module -F auid>=1000 -F auid!=-1 -k module_chng
-a always,exit -F arch=b64 -S init_module,finit_module -F auid>=1000 -F auid!=-1 -k module_chng

# STIG V-270806: Monitor module removal
-a always,exit -F arch=b32 -S delete_module -F auid>=1000 -F auid!=-1 -k module_chng
-a always,exit -F arch=b64 -S delete_module -F auid>=1000 -F auid!=-1 -k module_chng

# STIG V-270807: Monitor /etc/sudoers
-w /etc/sudoers -p wa -k privilege_modification

# STIG V-270808: Monitor /etc/sudoers.d
-w /etc/sudoers.d -p wa -k privilege_modification

# STIG V-270809: Monitor file deletions
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat,rmdir -F auid>=1000 -F auid!=-1 -k delete
-a always,exit -F arch=b32 -S unlink,unlinkat,rename,renameat,rmdir -F auid>=1000 -F auid!=-1 -k delete

# STIG V-270810: Monitor /var/log/wtmp
-w /var/log/wtmp -p wa -k logins

# STIG V-270811: Monitor /var/run/utmp
-w /var/run/utmp -p wa -k logins

# STIG V-270812: Monitor /var/log/btmp
-w /var/log/btmp -p wa -k logins

# STIG V-270813: Monitor modprobe
-w /sbin/modprobe -p x -k modules

# STIG V-270814: Monitor kmod
-w /bin/kmod -p x -k modules

# STIG V-270815: Monitor fdisk
-w /usr/sbin/fdisk -p x -k fdisk

# Make audit configuration immutable
-e 2
EOF

# STIG V-270653: Enable rsyslog
# Configure for container environment - service will be started by init system
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl enable rsyslog
else
    # Create enable link manually
    mkdir -p /etc/systemd/system/multi-user.target.wants
    ln -sf /lib/systemd/system/rsyslog.service /etc/systemd/system/multi-user.target.wants/rsyslog.service
fi

# Configure rsyslog for remote access monitoring
mkdir -p /etc/rsyslog.d
if [ ! -f /etc/rsyslog.d/50-default.conf ]; then
    # Create rsyslog default configuration if it doesn't exist
    cat > /etc/rsyslog.d/50-default.conf << 'EOF'
# Default logging configuration
*.*;auth,authpriv.none          -/var/log/syslog
auth,authpriv.*                 /var/log/auth.log
*.*;auth,authpriv.none          -/var/log/kern.log
daemon.*                        -/var/log/daemon.log
mail.*                          -/var/log/mail.log
user.*                          -/var/log/user.log
EOF
fi

# Add STIG-specific logging configuration
cat >> /etc/rsyslog.d/50-default.conf << 'EOF'
# STIG V-270681: Monitor remote access
auth,authpriv.*                 /var/log/secure
daemon.*                        /var/log/messages
EOF

# STIG V-270652: Configure AIDE notifications
# Create aide configuration file if it doesn't exist
if [ ! -f /etc/default/aide ]; then
    mkdir -p /etc/default
    cat > /etc/default/aide << 'EOF'
# AIDE configuration for STIG compliance
SILENTREPORTS=no
COPYNEWDB=ifnochange
DATABASE=/var/lib/aide/aide.db
DATABASE_OUT=/var/lib/aide/aide.db.new
GZIP_DBOUT=yes
EOF
else
    sed -i 's/^SILENTREPORTS=.*/SILENTREPORTS=no/' /etc/default/aide
fi

# Initialize AIDE database
aideinit || echo "AIDE initialization will complete during first boot"

echo "=== Audit Logging Configuration Complete ==="
