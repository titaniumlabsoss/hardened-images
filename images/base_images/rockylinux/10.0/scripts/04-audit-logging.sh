#!/bin/bash
# RHEL 9 STIG Audit Logging Configuration

set -e

echo "=== Starting Audit Logging Configuration ==="

# RHEL 9 STIG V-257788: Configure auditd
cat > /etc/audit/auditd.conf << 'EOF'
# RHEL 9 STIG V-257788-V-257800: Audit daemon configuration
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
dispatcher = /sbin/audispd
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
krb5_principal = auditd
EOF

# RHEL 9 STIG V-257801: Configure audit rules
cat > /etc/audit/rules.d/stig.rules << 'EOF'
# RHEL 9 STIG V-257801-V-257820: Audit rules

# Remove any existing rules
-D

# Buffer Size
-b 8192

# Failure Mode
-f 1

# RHEL 9 STIG V-257802: Audit successful/unsuccessful uses of the su command
-a always,exit -F path=/bin/su -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-priv_change

# RHEL 9 STIG V-257803: Audit successful/unsuccessful uses of the sudo command
-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-sudo

# RHEL 9 STIG V-257804: Audit successful/unsuccessful uses of the usermod command
-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-usermod

# RHEL 9 STIG V-257805: Audit successful/unsuccessful uses of the chage command
-a always,exit -F path=/usr/bin/chage -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-chage

# RHEL 9 STIG V-257806: Audit successful/unsuccessful uses of the setfacl command
-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng

# RHEL 9 STIG V-257807: Audit successful/unsuccessful uses of the chacl command
-a always,exit -F path=/usr/bin/chacl -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng

# RHEL 9 STIG V-257808: File system modifications
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod

# RHEL 9 STIG V-257809: File ownership changes
-a always,exit -F arch=b64 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod

# RHEL 9 STIG V-257810: File deletion events
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=4294967295 -k delete

# RHEL 9 STIG V-257811: Network modifications
-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname,setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/sysconfig/network -p wa -k system-locale

# RHEL 9 STIG V-257812: System access, changes, and logins
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock -p wa -k logins

# RHEL 9 STIG V-257813: Session initiation information
-w /var/run/utmp -p wa -k session
-w /var/log/btmp -p wa -k session
-w /var/log/wtmp -p wa -k session

# RHEL 9 STIG V-257814: DAC permission modification events
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod

# RHEL 9 STIG V-257815: Unauthorized access attempts to files
-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access

# RHEL 9 STIG V-257816: Privileged functions
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k privileged-mount
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k privileged-mount

# RHEL 9 STIG V-257817: System administrator actions
-w /etc/sudoers -p wa -k actions
-w /etc/sudoers.d/ -p wa -k actions

# RHEL 9 STIG V-257818: Kernel module loading and unloading
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module,delete_module -k modules

# RHEL 9 STIG V-258176-V-258229: Additional comprehensive audit rules

# Time synchronization events
-w /etc/localtime -p wa -k time-change
-w /etc/timezone -p wa -k time-change
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
-a always,exit -F arch=b32 -S adjtimex,settimeofday,clock_settime -k time-change

# Account modifications
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# Login/logout events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins

# Process and session initiation
-w /var/run/utmp -p wa -k session
-w /var/log/btmp -p wa -k session
-w /var/log/wtmp -p wa -k session

# System startup scripts
-w /etc/rc.d/init.d/ -p wa -k init
-w /etc/init.d/ -p wa -k init
-w /etc/systemd/ -p wa -k init

# Library search paths
-w /etc/ld.so.conf -p wa -k libpath
-w /etc/ld.so.conf.d/ -p wa -k libpath

# Kernel parameters
-w /etc/sysctl.conf -p wa -k sysctl
-w /etc/sysctl.d/ -p wa -k sysctl

# Modprobe configuration
-w /etc/modprobe.conf -p wa -k modprobe
-w /etc/modprobe.d/ -p wa -k modprobe

# PAM configuration
-w /etc/pam.d/ -p wa -k pam
-w /etc/security/limits.conf -p wa -k pam
-w /etc/security/limits.d/ -p wa -k pam
-w /etc/security/pam_env.conf -p wa -k pam
-w /etc/security/namespace.conf -p wa -k pam
-w /etc/security/namespace.d/ -p wa -k pam
-w /etc/security/namespace.init -p wa -k pam

# SSH configuration
-w /etc/ssh/sshd_config -p wa -k sshd
-w /etc/ssh/sshd_config.d/ -p wa -k sshd

# GRUB configuration (host system)
-w /etc/grub.conf -p wa -k grub
-w /etc/grub/grub.cfg -p wa -k grub
-w /etc/grub.d/ -p wa -k grub

# System call auditing for privileged commands
-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-passwd
-a always,exit -F path=/usr/bin/gpasswd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-gpasswd
-a always,exit -F path=/usr/bin/newgrp -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-newgrp
-a always,exit -F path=/usr/bin/mount -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-mount
-a always,exit -F path=/usr/bin/umount -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-umount
-a always,exit -F path=/usr/bin/ssh-agent -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-ssh

# Audit configuration tampering
-w /etc/audit/ -p wa -k auditconfig
-w /etc/libaudit.conf -p wa -k auditconfig
-w /etc/audisp/ -p wa -k audispconfig

# SELinux events (if applicable)
-w /etc/selinux/ -p wa -k selinux
-w /usr/share/selinux/ -p wa -k selinux

# System administration via sudo
-w /var/log/sudo.log -p wa -k actions

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

# User and group management
-a always,exit -F path=/usr/sbin/useradd -F perm=x -F auid>=1000 -F auid!=4294967295 -k user-mgmt
-a always,exit -F path=/usr/sbin/userdel -F perm=x -F auid>=1000 -F auid!=4294967295 -k user-mgmt
-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=1000 -F auid!=4294967295 -k user-mgmt
-a always,exit -F path=/usr/sbin/groupadd -F perm=x -F auid>=1000 -F auid!=4294967295 -k group-mgmt
-a always,exit -F path=/usr/sbin/groupdel -F perm=x -F auid>=1000 -F auid!=4294967295 -k group-mgmt
-a always,exit -F path=/usr/sbin/groupmod -F perm=x -F auid>=1000 -F auid!=4294967295 -k group-mgmt

# Network configuration changes
-a always,exit -F arch=b64 -S sethostname,setdomainname -k network-config
-a always,exit -F arch=b32 -S sethostname,setdomainname -k network-config
-w /etc/hostname -p wa -k network-config
-w /etc/hosts -p wa -k network-config
-w /etc/resolv.conf -p wa -k network-config
-w /etc/sysconfig/network -p wa -k network-config
-w /etc/sysconfig/network-scripts/ -p wa -k network-config

# Make the configuration immutable
-e 2
EOF

# RHEL 9 STIG V-257821: Configure rsyslog for centralized logging
mkdir -p /etc/rsyslog.d
cat > /etc/rsyslog.d/50-default.conf << 'EOF'
# RHEL 9 STIG V-257821: Centralized logging configuration
*.*    @@loghost:514
& stop

# Local logging for container environment
*.info;mail.none;authpriv.none;cron.none    /var/log/messages
authpriv.*                                  /var/log/secure
mail.*                                      -/var/log/maillog
cron.*                                      /var/log/cron
*.emerg                                     :omusrmsg:*
uucp,news.crit                             /var/log/spooler
local7.*                                    /var/log/boot.log
EOF

# Create audit log directory
mkdir -p /var/log/audit
chown root:root /var/log/audit
chmod 0755 /var/log/audit

echo "=== Audit Logging Configuration Complete ==="
