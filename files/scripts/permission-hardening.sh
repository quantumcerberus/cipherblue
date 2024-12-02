#!/usr/bin/env bash

set -oue pipefail

chmod 700 /usr/bin/cipher-capabilities
chmod 755 /etc/profile.d/cipherblue_umask.sh
mkdir -p /var/log/usbguard

echo "" > /etc/securetty
echo 'UriSchemes=file;https' | tee -a /etc/fwupd/fwupd.conf

umask 077
sed -i 's/^UMASK.*/UMASK 077/g' /etc/login.defs
sed -i 's/^HOME_MODE/#HOME_MODE/g' /etc/login.defs
sed -i 's/umask 022/umask 077/g' /etc/bashrc
sed -i 's/\s+nullok//g' /etc/pam.d/system-auth

sed -i 's@DefaultZone=FedoraWorkstation@DefaultZone=drop@g' /etc/firewalld/firewalld.conf
