# ublue-custom &nbsp; [![bluebuild build badge](https://github.com/badbl0cks/ublue/actions/workflows/build.yml/badge.svg)](https://github.com/badbl0cks/ublue/actions/workflows/build.yml)

These are customizations of upstream Universal Blue images, which themselves are customizations of Fedora CoreOS and Silverblue.

## Prepare

These are atomic, ostree-based Fedora OCI images. ISO/LiveCD-packaged builds are not provided, so you will 
need to install by rebasing from an existing installation. If you do not yet have an existing system to 
rebase from, you will first need to install your choice of one normally (e.g. Silverblue/Bazzite/CoreOS/etc)
before continuing. After completing the installation, you can complete the steps below.

> [!CAUTION]
> If you are installing uCore (which is based off of Fedora CoreOS), rebasing from Fedora IoT or any of the 
> Atomic Desktops (e.g. Silverblue) is NOT supported! You MUST only rebase from CoreOS or CoreOS-based images. 
> CoreOS must be provisioned with an [ignition config](https://docs.fedoraproject.org/en-US/fedora-coreos/producing-ign/) 
> and does not offer a GUI installer. If ignition doesn't provide a desired feature, then CoreOS doesn't support that 
> feature, and subsequently uCore won't either. Rebasing from a non CoreOS-based system, indirectly or not, to gain a  
> filesystem feature or GUI installation is very likely to cause problems later on.

## Images

Currently the following custom images are available:
- bazzite-gnome-badblocks (desktop/gaming-oriented)
  > Based on Bazzite, a custom Fedora Atomic Desktop image built with cloud-native technology that brings the best of Linux gaming to all of your devices - including your favorite handheld!
- ucore-hci-badblocks (server/NAS-oriented; REQUIRES IGNITION)
  > Based on uCore, an opinionated, lightweight, server-oriented CoreOS-based image with "batteries included". It's secure by default, auto-updating, and includes commonly used services, tools, and the building blocks needed to host them.  
  
> [!TIP]
> If installing uCore on a VPS, try using BIOS instead of UEFI, or you may encouter problems if SecureBoot or TPM2 is misconfigured on the physical server hosting the VPS.

## Rebasing

Rebasing is the only supported installation method for these custom images. To rebase an existing atomic Fedora 
installation to one of these custom builds, follow the steps below.

> [!NOTE]
> Be sure to replace &lt;IMAGE-NAME&gt; in the commands below with the actual image name you want to use.

- First rebase to the unsigned image, in order to properly import this repository's signing keys and policies:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/badbl0cks/<IMAGE_NAME>:latest
  ```
- Reboot to complete the initial rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/badbl0cks/<IMAGE_NAME>:latest
  ```
- Reboot again to complete the signed rebase:
  ```
  systemctl reboot
  ```

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/badbl0cks/ublue
```
