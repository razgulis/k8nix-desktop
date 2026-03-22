# k8nix-desktop

NixOS flake for a desktop machine, including:
- a bootable graphical USB installer image
- a permanent installed system configuration that can be rebuilt from this repo

## What this repo provides
- `desktop` host config for the installed machine.
- `desktop-installer` live image config for creating a bootable USB installer.
- Shared base module with desktop-safe defaults, common tooling, and weekly nix store cleanup.
- Plasma desktop + NVIDIA driver defaults + Brave browser.
- btrfs-oriented root filesystem placeholder for NVMe installs.

## Layout
- `flake.nix`: flake entrypoint and outputs.
- `modules/common.nix`: shared settings, user defaults, CLI tools, weekly cleanup.
- `modules/desktop.nix`: non-headless desktop services and UI stack.
- `modules/installer-iso.nix`: live installer image customizations.
- `hosts/desktop/default.nix`: installed desktop system config.
- `hosts/desktop/hardware-configuration.nix`: placeholder; replace after first install.

## Build A Bootable Installer ISO
```bash
nix build .#installerIso
```

Built image path:
```bash
./result/iso/*.iso
```

## Flash ISO To USB (example)
```bash
lsblk
sudo dd if=./result/iso/<image-name>.iso of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

Use the whole target device (`/dev/sdX`), not a partition (`/dev/sdX1`).

## Install NixOS From Live USB
1. Boot the USB.
2. Partition/format/mount target disk (for example mount root at `/mnt` and ESP at `/mnt/boot`).
3. Clone this repo in the live environment.
4. Install with flake target:

```bash
sudo nixos-install --flake .#desktop
```

After first boot on the installed system, regenerate hardware config in this repo and commit it:
```bash
sudo nixos-generate-config --show-hardware-config > hosts/desktop/hardware-configuration.nix
```

## Rebuild After Install
From the installed machine, inside this repo:
```bash
git pull --ff-only
sudo nixos-rebuild switch --flake .#desktop
```

## Defaults You Should Review
- `flake.nix`: `username` and `hostname`.
- `modules/common.nix`: git name/email, timezone, shell defaults, and SSH policy.
- `modules/desktop.nix`: Plasma/NVIDIA/browser defaults.
- `hosts/desktop/hardware-configuration.nix`: placeholder currently assumes btrfs-on-NVMe style mount options; replace with generated output.

## Weekly Nix Store Cleanup
Configured in `modules/common.nix`:
- `nix.gc.automatic = true` with `dates = "weekly"` and `--delete-older-than 14d`.
- `nix.optimise.automatic = true` with `dates = "weekly"`.
