#!/usr/bin/env bash

set -oue pipefail

# SELinux Booleans To Turn Off
sebools=(
    abrt_handle_event
    abrt_upload_watch_anon_write
    auditadm_exec_content
    boinc_execmem
    container_use_dri_devices
    container_user_exec_content
    cron_userdomain_transition
    dbadm_exec_content
    domain_kernel_load_modules
    entropyd_use_audio
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
    systemd_socket_proxyd_connect_any
    telepathy_connect_all_ports
    telepathy_tcp_connect_generic_network_ports
    tftp_anon_write
    tomcat_can_network_connect_db
    tor_can_onion_services
    unconfined_chrome_sandbox_transition
    unconfined_dyntrans_all
    #unconfined_login
    unconfined_mozilla_plugin_transition
    usbguard_daemon_write_conf
    use_virtualbox
    varnishd_connect_any
    virt_hooks_unconfined
    virt_qemu_ga_read_nonsecurity_files
    virt_qemu_ga_run_unconfined
    virt_sandbox_share_apache_content
    virt_sandbox_use_all_caps
    virt_sandbox_use_audit
    virt_use_nfs
    virt_use_usb
    virtqemud_use_execmem
    xend_run_blktap
    xend_run_qemu
    xguest_exec_content
    xguest_mount_media
)

for sebool in "${sebools[@]}"; do
        setsebool -P "$sebool" off > /dev/null
done


# SELinux Booleans To Turn On
sebools=(
    deny_bluetooth
    deny_ptrace
    xdm_sysadm_login
    #secure_mode
    secure_mode_policyload
)

for sebool in "${sebools[@]}"; do
        setsebool -P "$sebool" on > /dev/null
done
