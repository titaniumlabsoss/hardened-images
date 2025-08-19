#!/bin/sh
# Alpine Linux Audit and Logging Configuration
# Implements STIG-equivalent audit controls

set -e

echo "=== Starting Audit Logging Configuration ==="

# Install audit package if available
apk add --no-cache audit 2>/dev/null || echo "Audit package not available, using alternative logging"

# Configure auditd if available
if command -v auditd >/dev/null 2>&1; then
    mkdir -p /etc/audit/rules.d

    # Configure auditd (STIG V-257788-V-257800)
    cat > /etc/audit/auditd.conf << 'EOF'
# STIG Audit daemon configuration
local_events = yes
write_logs = yes
log_file = /var/log/audit/audit.log
log_group = root
log_format = ENRICHED
flush = INCREMENTAL_ASYNC
freq = 50
max_log_file = 10
num_logs = 5
priority_boost = 4
disp_qos = lossy
name_format = HOSTNAME
max_log_file_action = ROTATE
space_left = 75
space_left_action = SYSLOG
verify_email = yes
action_mail_acct = root
admin_space_left = 50
admin_space_left_action = HALT
disk_full_action = HALT
disk_error_action = HALT
use_libwrap = yes
tcp_listen_queue = 5
tcp_max_per_addr = 1
tcp_client_max_idle = 0
enable_krb5 = no
EOF

    # Configure audit rules (STIG V-257801-V-257820)
    cat > /etc/audit/rules.d/stig.rules << 'EOF'
# STIG Audit rules

# Remove any existing rules
-D

# Buffer Size
-b 8192

# Failure Mode
-f 1

# Audit successful/unsuccessful uses of privileged commands
-a always,exit -F path=/bin/su -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-priv_change
-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-sudo
-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-passwd

# File system modifications
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod

# File ownership changes
-a always,exit -F arch=b64 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod

# File deletion events
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=4294967295 -k delete

# Network modifications
-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname,setdomainname -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/hostname -p wa -k system-locale
-w /etc/resolv.conf -p wa -k system-locale

# System access, changes, and logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/faillog -p wa -k logins
-w /var/run/faillock -p wa -k logins

# Session initiation information
-w /var/run/utmp -p wa -k session
-w /var/log/btmp -p wa -k session
-w /var/log/wtmp -p wa -k session

# Unauthorized access attempts to files
-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access

# Privileged functions
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k privileged-mount
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k privileged-mount

# System administrator actions
-w /etc/sudoers -p wa -k actions
-w /etc/sudoers.d/ -p wa -k actions

# Kernel module loading and unloading
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module,delete_module -k modules

# Time synchronization events
-w /etc/localtime -p wa -k time-change
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
-a always,exit -F arch=b32 -S adjtimex,settimeofday,clock_settime -k time-change

# Account modifications
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity

# System startup scripts
-w /etc/init.d/ -p wa -k init
-w /etc/rc.d/ -p wa -k init

# Library search paths
-w /etc/ld.so.conf -p wa -k libpath
-w /etc/ld.so.conf.d/ -p wa -k libpath

# Kernel parameters
-w /etc/sysctl.conf -p wa -k sysctl
-w /etc/sysctl.d/ -p wa -k sysctl

# PAM configuration
-w /etc/pam.d/ -p wa -k pam
-w /etc/security/limits.conf -p wa -k pam
-w /etc/security/limits.d/ -p wa -k pam

# SSH configuration
-w /etc/ssh/sshd_config -p wa -k sshd
-w /etc/ssh/sshd_config.d/ -p wa -k sshd

# Audit configuration tampering
-w /etc/audit/ -p wa -k auditconfig
-w /etc/libaudit.conf -p wa -k auditconfig

# Cron jobs
-w /etc/cron.allow -p wa -k cron
-w /etc/cron.deny -p wa -k cron
-w /etc/cron.d/ -p wa -k cron
-w /etc/cron.daily/ -p wa -k cron
-w /etc/cron.hourly/ -p wa -k cron
-w /etc/cron.monthly/ -p wa -k cron
-w /etc/cron.weekly/ -p wa -k cron
-w /etc/crontab -p wa -k cron
-w /var/spool/cron/ -p wa -k cron
-w /etc/periodic/ -p wa -k cron

# Make the configuration immutable
-e 2
EOF
  
    # Load audit rules
    augenrules --load 2>/dev/null || true
fi

# Configure rsyslog or syslog-ng for centralized logging (STIG V-257821)
if command -v syslog-ng >/dev/null 2>&1; then
    mkdir -p /etc/syslog-ng/conf.d
    cat > /etc/syslog-ng/conf.d/stig.conf << 'EOF'
# STIG Centralized logging configuration
destination d_central { network("loghost" port(514)); };
log { source(s_sys); destination(d_central); };
EOF
elif [ -f /etc/rsyslog.conf ]; then
    cat >> /etc/rsyslog.conf << 'EOF'
# STIG Centralized logging configuration
*.*    @@loghost:514
& stop
EOF
fi

# Configure local logging
cat > /etc/syslog.conf << 'EOF'
# STIG Local logging configuration
*.info;mail.none;authpriv.none;cron.none    /var/log/messages
authpriv.*                                  /var/log/secure
mail.*                                      -/var/log/maillog
cron.*                                      /var/log/cron
*.emerg                                     :omusrmsg:*
local7.*                                    /var/log/boot.log
EOF

# Create necessary log directories and files
mkdir -p /var/log/audit
touch /var/log/messages /var/log/secure /var/log/maillog /var/log/cron /var/log/boot.log
chmod 640 /var/log/messages /var/log/secure /var/log/maillog /var/log/cron /var/log/boot.log
chown root:root /var/log/messages /var/log/secure /var/log/maillog /var/log/cron /var/log/boot.log

# Create audit log directory
mkdir -p /var/log/audit
chown root:root /var/log/audit
chmod 0755 /var/log/audit

echo "=== Audit Logging Configuration Complete ==="
