# CipherBlue &nbsp; 

[![build-cipherblue](https://github.com/quantumcerberus/cipherblue/actions/workflows/build.yml/badge.svg)](https://github.com/quantumcerberus/cipherblue/actions/workflows/build.yml)

## Installation

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/quantumcerberus/cipherblue:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/quantumcerberus/cipherblue:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/quantumcerberus/cipherblue
```

## CipherBlue Post-Install Scripts

### Kernel Parameter Hardening

```
kargs=(
    amd_iommu=force_isolation
    debugfs=off
    efi=disable_early_pci_dma
    extra_latent_entropy
    gather_data_sampling=force
    ia32_emulation=0
    init_on_alloc=1
    init_on_free=1
    intel_iommu=on
    iommu.passthrough=0
    iommu.strict=1
    iommu=force
    ipv6.disable=1
    kvm.nx_huge_pages=force
    l1d_flush=on
    l1tf=full,force
    lockdown=confidentiality
    loglevel=0
    mds=full,nosmt
    mitigations=auto,nosmt
    module.sig_enforce=1
    nosmt=force
    oops=panic
    page_alloc.shuffle=1
    pti=on
    random.trust_bootloader=off
    random.trust_cpu=off
    randomize_kstack_offset=on
    reg_file_data_sampling=on
    slab_nomerge
    spec_rstack_overflow=safe-ret
    spec_store_bypass_disable=on
    spectre_bhi=on
    spectre_v2=on
    tsx=off
    tsx_async_abort=full,nosmt
    vsyscall=none
)

kargs_str=$(IFS=" "; echo "${kargs[*]}")

rpm-ostree kargs --append-if-missing="$kargs_str" > /dev/null
```

### SELinux Hardening

```
# selinux confined users
semanage login -m -s guest_u -r s0 __default__
semanage login -m -s guest_u -r s0 root
semanage login -a -s user_u gdm
semanage login -a -s unconfined_u anonymous
semanage login -a -s unconfined_u sysadmin

# SELinux Booleans To Turn Off
sebools=(
    abrt_anon_write
    abrt_handle_event
    abrt_upload_watch_anon_write
    auditadm_exec_content
    boinc_execmem
    cdrecord_read_content
    cluster_can_network_connect
    cobbler_anon_write
    cobbler_can_network_connect
    collectd_tcp_network_connect
    condor_tcp_network_connect
    conman_can_network
    conman_use_nfs
    container_connect_any
    container_manage_cgroup
    container_read_certs
    container_use_cephfs
    container_use_devices
    container_use_dri_devices
    container_use_ecryptfs
    container_use_xserver_devices
    container_user_exec_content
    cron_can_relabel
    cron_system_cronjob_use_shares
    cron_userdomain_transition
    daemons_dump_core
    daemons_enable_cluster_mode
    daemons_use_tcp_wrapper
    daemons_use_tty
    dbadm_exec_content
    domain_kernel_load_modules
    entropyd_use_audio
    exim_can_connect_db
    fcron_crond
    fenced_can_network_connect
    ftpd_anon_write
    ftpd_connect_all_unreserved
    ftpd_connect_db
    git_session_bind_all_unreserved_ports
    git_session_users
    gluster_anon_write
    gluster_export_all_ro
    gluster_export_all_rw
    gpg_web_anon_write
    gssd_read_tmp
    guest_exec_content
    haproxy_connect_any
    httpd_anon_write
    httpd_builtin_scripting
    httpd_can_connect_ftp
    httpd_can_connect_ldap
    httpd_can_connect_mythtv
    httpd_can_connect_zabbix
    httpd_can_network_connect
    httpd_can_network_connect_cobbler
    httpd_can_network_connect_db
    httpd_dontaudit_search_dirs
    httpd_enable_cgi
    httpd_read_user_content
    httpd_sys_script_anon_write
    keepalived_connect_any
    kerberos_enabled
    logadm_exec_content
    logging_syslogd_append_public_content
    logging_syslogd_list_non_security_dirs
    logging_syslogd_run_unconfined
    logging_syslogd_use_tty
    login_console_enabled
    logrotate_read_inside_containers
    logwatch_can_network_connect_mail
    lsmd_plugin_connect_any
    mcelog_exec_scripts
    minidlna_read_generic_user_content
    mount_anyfile
    mozilla_plugin_can_network_connect
    mozilla_read_content
    mysql_connect_any
    mysql_connect_http
    named_write_master_zones
    neutron_can_network
    nfs_export_all_ro
    nfs_export_all_rw
    nfsd_anon_write
    nscd_use_shm
    openfortivpn_can_network_connect
    openvpn_can_network_connect
    openvpn_enable_homedirs
    openvpn_run_unconfined
    pdns_can_network_connect_db
    polipo_connect_all_unreserved
    polipo_session_bind_all_unreserved_ports
    polipo_session_users
    polyinstantiation_enabled
    postfix_local_write_mail_spool
    postgresql_selinux_unconfined_dbadm
    postgresql_selinux_users_ddl
    privoxy_connect_any
    racoon_read_shadow
    rsync_anon_write
    samba_domain_controller
    samba_enable_home_dirs
    samba_export_all_ro
    samba_export_all_rw
    samba_run_unconfined
    samba_share_fusefs
    samba_share_nfs
    screen_allow_session_sharing
    secadm_exec_content
    selinuxuser_direct_dri_enabled
    selinuxuser_execheap
    selinuxuser_execmod
    selinuxuser_execstack
    selinuxuser_mysql_connect_enabled
    selinuxuser_ping
    selinuxuser_postgresql_connect_enabled
    selinuxuser_rw_noexattrfile
    smartmon_3ware
    smbd_anon_write
    spamd_enable_home_dirs
    squid_connect_any
    sshd_launch_containers
    sslh_can_connect_any_port
    sssd_connect_all_unreserved_ports
    staff_exec_content
    sysadm_exec_content
    systemd_socket_proxyd_connect_any
    telepathy_connect_all_ports
    telepathy_tcp_connect_generic_network_ports
    tftp_anon_write
    tomcat_can_network_connect_db
    tor_can_onion_services
    unconfined_chrome_sandbox_transition
    unconfined_dyntrans_all
    unconfined_mozilla_plugin_transition
    usbguard_daemon_write_conf
    use_virtualbox
    user_exec_content
    varnishd_connect_any
    virt_hooks_unconfined
    virt_qemu_ga_read_nonsecurity_files
    virt_qemu_ga_run_unconfined
    virt_sandbox_share_apache_content
    virt_sandbox_use_all_caps
    virt_sandbox_use_audit
    virt_transition_userdomain
    virt_use_nfs
    virt_use_usb
    virtqemud_use_execmem
    xend_run_blktap
    xend_run_qemu
    xguest_connect_network
    xguest_exec_content
    xguest_mount_media
    xguest_use_bluetooth
    zebra_write_config
    zoneminder_anon_write
    zoneminder_run_sudo
)

for sebool in "${sebools[@]}"; do
        setsebool -P "$sebool" off > /dev/null
done


# SELinux Booleans To Turn On
sebools=(
    deny_bluetooth
    deny_ptrace
    secure_mode
    secure_mode_policyload
)

for sebool in "${sebools[@]}"; do
        setsebool -P "$sebool" on > /dev/null
done
```

### Adding flathub-verified-floss repo in each user

```
flatpak remote-add --if-not-exists --user --subset=verified_floss flathub-verified-floss https://flathub.org/repo/flathub.flatpakrepo
```

### Microcode Updates

```
fwupdmgr refresh --force
fwupdmgr get-updates
fwupdmgr update
```

### Additional Hardening

```
# fstab hardening
if ! grep -q 'zstd' /etc/fstab; then
    sed -i 's/zstd:1/zstd/g' /etc/fstab
fi

FILE="/etc/fstab"

if ! grep -q 'x-systemd.device-timeout=0,nosuid,noexec,nodev' "$FILE"; then
    sed -i -e 's/x-systemd.device-timeout=0/x-systemd.device-timeout=0,nosuid,noexec,nodev/' \
           -e 's/shortname=winnt/shortname=winnt,nosuid,noexec,nodev/' \
           -e 's/defaults/defaults,nosuid,noexec,nodev/' "$FILE"
fi

echo "fstab hardening complete."

# firewall hardening
systemctl enable --now firewalld
firewall-cmd --lockdown-on

echo "firewall hardening complete."

# Coredump Cleanup
ulimit -c 0
systemd-tmpfiles --clean 2> /dev/null
systemctl daemon-reload

echo "coredump cleanup complete."

# disable system-tracking
hostnamectl set-hostname host
new_machine_id="b08dfa6083e7567a1921a715000001fb"
echo "$new_machine_id" | tee /etc/machine-id > /dev/null
echo "$new_machine_id" | tee /var/lib/dbus/machine-id > /dev/null

echo "system tracking disabled."

# Enable USBGuard
systemctl enable --now usbguard.service

echo "usbguard enabled."

# flatpak hardening
flatpak remote-delete --system --force fedora
flatpak remote-delete --system --force fedora-testing
flatpak remote-delete --user --force fedora
flatpak remote-delete --user --force fedora-testing
flatpak remote-delete --system --force flathub
flatpak remote-delete --user --force flathub
flatpak remove --system --noninteractive --all
chown root:anonymous /var/home/anonymous/.local/share/flatpak/overrides -R
chmod 050 /var/home/anonymous/.local/share/flatpak/overrides
chmod 040 /var/home/anonymous/.local/share/flatpak/overrides/*
chown root:sysadmin /var/home/sysadmin/.local/share/flatpak/overrides -R
chmod 050 /var/home/sysadmin/.local/share/flatpak/overrides
chmod 040 /var/home/sysadmin/.local/share/flatpak/overrides/*

echo "flatpak hardening complete."

# Home Hardening
chmod 700 /home/*
chown root:anonymous /home/anonymous
chown root:sysadmin /home/sysadmin
chmod 050 /home/anonymous /home/sysadmin
rm -rf /var/home/anonymous/.local/share/applications
rm -rf /var/home/anonymous/.config/autostart
rm -rf /var/home/anonymous/.config/systemd
rm -rf /var/home/anonymous/.local/share/systemd
rm -rf /var/home/sysadmin/.local/share/applications
rm -rf /var/home/sysadmin/.config/autostart
rm -rf /var/home/sysadmin/.config/systemd
rm -rf /var/home/sysadmin/.local/share/systemd
chown root:anonymous '/var/home/anonymous/.bash_history' '/var/home/anonymous/.bash_logout' '/var/home/anonymous/.bash_profile' '/var/home/anonymous/.bashrc' /var/home/anonymous/.config /var/home/anonymous/.local /var/home/anonymous/.local/share
chown root:sysadmin '/var/home/sysadmin/.bash_history' '/var/home/sysadmin/.bash_logout' '/var/home/sysadmin/.bash_profile' '/var/home/sysadmin/.bashrc' /var/home/sysadmin/.config /var/home/sysadmin/.local /var/home/sysadmin/.local/share
chmod 040 '/var/home/anonymous/.bash_history' '/var/home/anonymous/.bash_logout' '/var/home/anonymous/.bash_profile' '/var/home/anonymous/.bashrc' '/var/home/sandbox/.bash_history' '/var/home/sandbox/.bash_logout' '/var/home/sandbox/.bash_profile' '/var/home/sandbox/.bashrc' '/var/home/sysadmin/.bash_history' '/var/home/sysadmin/.bash_logout' '/var/home/sysadmin/.bash_profile' '/var/home/sysadmin/.bashrc'
chmod 050 '/var/home/anonymous/.config' '/var/home/anonymous/.local' '/var/home/anonymous/.local/share' '/var/home/sysadmin/.config' '/var/home/sysadmin/.local' '/var/home/sysadmin/.local/share'

echo "Home hardening complete."

# block wireless devices
rfkill block all
rfkill unblock wifi

# lockdown root
passwd -l root
dconf update

echo "Hardening complete. Now head to secureblue page to refer other post-install scripts for grub-password, audit and other post-install guides, scripts and instructions."
```

### Final Hardening

```
# no bash except for sysadmin
sed -i '/^sysadmin/!s#/bin/bash#/sbin/nologin#g' /etc/passwd
```
