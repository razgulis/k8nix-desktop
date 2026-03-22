{ ... }:

{
  # Placeholder generated hardware profile.
  # Replace this file after install with:
  # sudo nixos-generate-config --show-hardware-config > hosts/desktop/hardware-configuration.nix

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "compress=zstd:1" "noatime" "ssd" "discard=async" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];
}
