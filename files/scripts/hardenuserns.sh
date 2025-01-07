#!/usr/bin/env bash

set -oue pipefail

rpm-ostree install selinux-policy-devel

cd ./selinux/chromium
bash chromium.sh
cd ../..

cd ./selinux/flatpakfull
bash flatpakfull.sh
cd ../..

cd ./selinux/nautilus
bash nautilus.sh
cd ../..

semodule -i ./selinux/user_namespace/grant_userns.cil
semodule -i ./selinux/user_namespace/harden_userns.cil
semodule -i ./selinux/user_namespace/harden_container_userns.cil
semodule -i ./selinux/flatpakfull/grant_systemd_flatpak_exec.cil
