#!/usr/bin/env bash

set -oue pipefail

dnf5 install --setopt=install_weak_deps=False selinux-policy-devel

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
