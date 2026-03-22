{ pkgs, ... }:

{
  isoImage.edition = "k8nix-desktop";

  environment.systemPackages = with pkgs; [
    git
  ];
}
