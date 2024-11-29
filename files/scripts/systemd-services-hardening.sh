#!/usr/bin/env bash

set -oue pipefail

services=(
    ModemManager
    abrt-journal-core.service
    abrt-oops.service
    abrt-pstoreoops.service
    abrt-vmcore.service
    abrt-xorg.service
    abrtd.service
    alsa-state
    atd.service
    avahi-daemon.service
    avahi-daemon.socket
    cups
    geoclue
    gssproxy
    httpd
    iscsi-init.service
    iscsi.service
    iscsid.service
    iscsid.socket
    iscsiuio.service
    iscsiuio.socket
    livesys-late.service
    livesys.service
    mcelog.service
    multipathd.service
    multipathd.socket
    network-online.target
    nfs-idmapd
    nfs-mountd
    debug-shell.service
    kdump.service
    nfs-server
    nfsdcld
    passim.service
    pcscd.service
    pcscd.socket
    remote-fs.target
    rpc-gssd
    rpc-statd
    rpc-statd-notify
    rpcbind
    rpm-ostree-countme.service
    rpm-ostree-countme.timer
    smartd.service
    sshd
    sssd
    sssd-kcm
    tailscaled
    vboxservice.service
    vmtoolsd.service
)

for service in "${services[@]}"; do
        systemctl disable "$service" > /dev/null
        systemctl mask "$service" > /dev/null
done

systemctl --global enable quern-user-maintenance

services=(
    fstrim.timer
    rpm-ostreed-automatic.timer
    quern-capabilities
    quern-cleaner
    quern-remount
    tlp
)

for service in "${services[@]}"; do
        systemctl enable "$service" > /dev/null
done
