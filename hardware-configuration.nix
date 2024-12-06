
# Example hardware configuration
{ config, pkgs, ... }: {
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "firewire_ohci" "firewire_sbp2" "usb_storage" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.initrd.kernelModules = [ "nvme" "xhci_hcd" ];
}
