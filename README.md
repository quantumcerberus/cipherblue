# CipherBlue &nbsp; 

[![build-cipherblue](https://github.com/quantumcerberus/cipherblue/actions/workflows/build.yml/badge.svg)](https://github.com/quantumcerberus/cipherblue/actions/workflows/build.yml)

## CipherBlue Pre-Install Scripts

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
