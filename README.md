<p align="center">
  <a href="https://github.com/quantumcerberus/cipherblue">
    <img src="https://github.com/quantumcerberus/cipherblue/blob/main/cipherblue.png" href="https://github.com/quantumcerberus/cipherblue" width=180 />
  </a>
</p>

<h1 align="center">CipherBlue</h1>

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

### Flatpak Hardening

```
flatpak remote-delete --system --force fedora
flatpak remote-delete --system --force fedora-testing
flatpak remote-delete --user --force fedora
flatpak remote-delete --user --force fedora-testing
flatpak remote-delete --system --force flathub
flatpak remote-delete --user --force flathub
flatpak uninstall --delete-data --all -y
```

```
rm -rf /var/lib/flatpak/.removed
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

## CipherBlue Post-Install Scripts

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

# GRUB Hardening
grub2-setpassword

echo "Hardening complete."
```

### flathub-verified-floss repository

```
flatpak remote-add --if-not-exists --system --subset=verified_floss flathub-verified-floss https://flathub.org/repo/flathub.flatpakrepo
```

### SELinux Confined Users (Experimental)

```
semanage login -a -s user_u -r s0 gdm
semanage login -m -s user_u -r s0 __default__
semanage login -m -s sysadm_u -r s0 root
semanage login -a -s sysadm_u -r s0 sysadmin
```
