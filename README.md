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
    slub_debug=ZF
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
semanage login -m -s guest_u -r s0 root
semanage login -a -s xguest_u gdm
semanage login -m -s user_u -r s0 __default__
semanage login -a -s unconfined_u sysadmin
```

### Flatpak Hardening

```
flatpak remote-delete --system --force fedora
flatpak remote-delete --system --force fedora-testing
flatpak remote-delete --user --force fedora
flatpak remote-delete --user --force fedora-testing
flatpak remote-delete --system --force flathub
flatpak remote-delete --user --force flathub
flatpak uninstall --delete-data --noninteractive --all
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

```
cosign verify --key cosign.pub ghcr.io/quantumcerberus/cipherblue
```

## CipherBlue Post-Install Scripts

### Additional Hardening

```
# Fstab Hardening
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

# Firewall Hardening
systemctl enable --now firewalld
firewall-cmd --lockdown-on

echo "firewall hardening complete."

# Coredump Cleanup
ulimit -c 0
systemd-tmpfiles --clean 2> /dev/null
systemctl daemon-reload

echo "coredump cleanup complete."

# Disable System-Tracking
hostnamectl set-hostname host
new_machine_id="b08dfa6083e7567a1921a715000001fb"
echo "$new_machine_id" | tee /etc/machine-id > /dev/null
echo "$new_machine_id" | tee /var/lib/dbus/machine-id > /dev/null

echo "system tracking disabled."

# Enable USBGuard
systemctl enable --now usbguard.service

echo "usbguard enabled."

# Home Hardening
chmod 700 /home/*

echo "Home hardening complete."

# Block Wireless Devices
rfkill block all
rfkill unblock wifi

# Lockdown Root
passwd -l root

# GNOME Hardening
dconf update

echo "Hardening complete. Now head to secureblue page to refer other post-install scripts for grub-password, auditing and other post-install guides, scripts and instructions."
```

### Adding flathub-verified-floss for users

```
flatpak remote-add --if-not-exists --user --subset=verified_floss flathub-verified-floss https://flathub.org/repo/flathub.flatpakrepo
```
