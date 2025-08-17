#!/bin/bash
# STIG audit logging and monitoring configuration
# Implements comprehensive audit logging per DISA STIG requirements

set -e

echo "=== Starting Audit Logging Configuration ==="

# STIG V-238252: System must generate audit records for successful/unsuccessful uses of the su command
cat > /etc/audit/rules.d/stig-audit.rules << EOF
# STIG V-238252: Monitor su command
-a always,exit -F path=/bin/su -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-priv_change

# STIG V-238253: Monitor sudo command
-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-sudo

# STIG V-238254: Monitor passwd command
-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-passwd

# STIG V-238255: Monitor unix_chkpwd command
-a always,exit -F path=/sbin/unix_chkpwd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-unix-update

# STIG V-238256: Monitor gpasswd command
-a always,exit -F path=/usr/bin/gpasswd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-passwd

# STIG V-238257: Monitor chage command
-a always,exit -F path=/usr/bin/chage -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-passwd

# STIG V-238258: Monitor usermod command
-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-passwd

# STIG V-238259: Monitor crontab command
-a always,exit -F path=/usr/bin/crontab -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-cron

# STIG V-238260: Monitor pam_timestamp_check command
-a always,exit -F path=/usr/sbin/pam_timestamp_check -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-pam

# STIG V-238261: Monitor init command
-a always,exit -F path=/sbin/init -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-init

# STIG V-238262: Monitor poweroff command
-a always,exit -F path=/sbin/poweroff -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-init

# STIG V-238263: Monitor reboot command
-a always,exit -F path=/sbin/reboot -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-init

# STIG V-238264: Monitor shutdown command
-a always,exit -F path=/sbin/shutdown -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-init

# STIG V-238265: Monitor halt command
-a always,exit -F path=/sbin/halt -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-init

# STIG V-238266: System must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/passwd
-w /etc/passwd -p wa -k identity

# STIG V-238267: System must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/group
-w /etc/group -p wa -k identity

# STIG V-238268: System must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/gshadow
-w /etc/gshadow -p wa -k identity

# STIG V-238269: System must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/shadow
-w /etc/shadow -p wa -k identity

# STIG V-238270: System must generate audit records for all account creations, modifications, disabling, and termination events that affect /etc/security/opasswd
-w /etc/security/opasswd -p wa -k identity

# STIG V-238271: Audit system calls
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change

# STIG V-238272: Monitor network environment changes
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/network -p wa -k system-locale

# STIG V-238273: Monitor MAC policy changes
-w /etc/apparmor/ -p wa -k MAC-policy
-w /etc/apparmor.d/ -p wa -k MAC-policy

# STIG V-238274: Monitor login/logout events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins

# STIG V-238275: Monitor session initiation information
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k logins
-w /var/log/btmp -p wa -k logins

# STIG V-238276: Monitor discretionary access control permission modifications
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod

# STIG V-238277: Monitor unsuccessful unauthorized file access attempts
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access

# STIG V-238278: Monitor file deletion events
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete

# STIG V-238279: Monitor kernel module loading
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b32 -S init_module -S delete_module -k modules
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules

# STIG V-238280: Make audit configuration immutable
-e 2
EOF

# STIG V-238281: Configure auditd
cat > /etc/audit/auditd.conf << EOF
# STIG V-238281: Audit daemon configuration

# Log file location
log_file = /var/log/audit/audit.log

# Log file format
log_format = RAW

# Maximum log file size (MB)
max_log_file = 50

# Number of log files to keep
num_logs = 5

# Priority for writing to log
priority_boost = 4

# Action when log file reaches max size
max_log_file_action = ROTATE

# Space left on disk (MB)
space_left = 75

# Action when space is low
space_left_action = SYSLOG

# Administrator space left (MB)
admin_space_left = 50

# Action when admin space is low
admin_space_left_action = SUSPEND

# Action when disk is full
disk_full_action = SUSPEND

# Action when disk error occurs
disk_error_action = SUSPEND

# Use augenrules to load rules
use_libwrap = yes

# TCP listen port
tcp_listen_port = 60

# TCP listen queue
tcp_listen_queue = 5

# TCP max connections per IP
tcp_max_per_addr = 1

# TCP client ports
tcp_client_ports = 1024-65535

# TCP client max idle time
tcp_client_max_idle = 0

# Enable krb5 principal
enable_krb5 = no

# Kerberos principal
krb5_principal = auditd

# Kerberos key file
krb5_key_file = /etc/audit/audit.key
EOF

# STIG V-238282: Configure audit log rotation
cat > /etc/logrotate.d/audit << EOF
/var/log/audit/audit.log {
    daily
    rotate 5
    compress
    delaycompress
    notifempty
    create 640 root root
    postrotate
        /sbin/service auditd restart > /dev/null 2>&1 || true
    endscript
}
EOF

# STIG V-238283: Set audit log file ownership and permissions
mkdir -p /var/log/audit
touch /var/log/audit/audit.log
chown root:root /var/log/audit/audit.log
chmod 640 /var/log/audit/audit.log
chown -R root:root /etc/audit/
chmod -R 640 /etc/audit/

# STIG V-238284: Configure rsyslog for centralized logging
cat >> /etc/rsyslog.conf << EOF

# STIG V-238284: Centralized logging
*.* @@localhost:514

# Log audit messages to separate file
local6.* /var/log/audit/audit.log
& stop
EOF

# STIG V-238285: Enable audit service (container-compatible)
# Note: Audit service would be enabled on container host system

# STIG V-238286: Configure audit buffer size (container-compatible)
# Note: GRUB configuration handled by container host system

echo "=== Audit Logging Configuration Complete ==="
