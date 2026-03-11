# ublue-custom &nbsp; [![bluebuild build badge](https://github.com/badbl0cks/ublue/actions/workflows/build.yml/badge.svg)](https://github.com/badbl0cks/ublue/actions/workflows/build.yml)

These are customizations of upstream Universal Blue images, which themselves are customizations of Fedora CoreOS.

## Prepare

If you are not yet on an existing atomic Fedora installation, you will first need to install your choice of one normally (e.g. Bazzite via ISO on bare metal).
Once installed, you can use that installation to complete the steps below.

## Installation

To rebase an existing atomic Fedora installation to this build, including any ublue-based installation:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/badbl0cks/bazzite-gnome-badblocks:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/badbl0cks/bazzite-gnome-badblocks:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

## Images

Currently the following images are available:
- bazzite-gnome-badblocks (Desktop gaming)
- ucore-hci-badblocks (Server/NAS-oriented)


## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/badbl0cks/ublue
```
