{ pkgs, lib, nixos-hardware, ... }:

{
  # Desktop at CRI

  imports = [
    ../../profiles/core.nix
    ../../profiles/desktop.nix
    ../../profiles/docker.nix

    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-ssd
  ];

  networking = {
    hostName = "callisto";

    domain = "lab.cri.epita.fr";
    nameservers = [ "91.243.117.210" ];

    bonds = {
      bond0 = {
        interfaces = [ "eno1" "enp3s0" ];
        driverOptions = {
          mode = "802.3ad";
          lacp_rate = "fast";
          xmit_hash_policy = "layer3+4";
        };
      };
    };

    bridges = {
      br0 = {
        interfaces = [ "bond0" ];
      };
    };

    defaultGateway = {
      address = "192.168.240.254";
      interface = "br0";
    };

    interfaces = {
      eno1 = { };
      enp3s0 = { };
      bond0 = { };
      br0 = {
        ipv4 = {
          addresses = [
            {
              address = "192.168.240.26";
              prefixLength = 24;
            }
          ];
        };
      };
    };

    timeServers = [
      "ntp.pie.cri.epita.fr"
    ];
  };

  # commented stuff is for pci passtrough vm, disabled because too many monitors
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "dm-mod" "dm-cache" "dm-cache-smq" "dm-thin-pool" "dm-raid" "raid1" "dm-crypt" ];
  boot.kernelModules = [ "kvm-intel" /*"vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd"*/ ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" /*"vfio-pci.ids=10de:1c81,10de:0fb9"*/ ];
  #options vfio-pci ids=10de:1c81,10de:0fb9
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
  '';
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  boot.initrd.extraUtilsCommands = ''
    for BIN in ${pkgs.thin-provisioning-tools}/{s,}bin/*; do
        copy_bin_and_libs $BIN
    done
  '';
  # Before LVM commands are executed, ensure that LVM knows exactly where our cache and thin provisioning tools are
  boot.initrd.preLVMCommands = ''
    mkdir -p /etc/lvm
    echo "global/thin_check_executable = "$(which thin_check)"" >> /etc/lvm/lvm.conf
    echo "global/cache_check_executable = "$(which cache_check)"" >> /etc/lvm/lvm.conf
    echo "global/cache_dump_executable = "$(which cache_dump)"" >> /etc/lvm/lvm.conf
    echo "global/cache_repair_executable = "$(which cache_repair)"" >> /etc/lvm/lvm.conf
    echo "global/thin_dump_executable = "$(which thin_dump)"" >> /etc/lvm/lvm.conf
    echo "global/thin_repair_executable = "$(which thin_repair)"" >> /etc/lvm/lvm.conf
  '';

  services.lvm.boot.thin.enable = true;

  boot.initrd.luks.devices = {
    cryptlvm = {
      device = "/dev/disk/by-uuid/52194682-fb5b-4ab9-b23c-3486604bdcf9";
      preLVM = false;
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/a20e412a-1cd5-4ce7-bc4f-7f694def134e";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/F337-51EB";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/ea313758-ab4b-45c6-bb88-1a87d7e6b4dc"; }];

  virtualisation.libvirtd.allowedBridges = [ "br0" ];
  virtualisation.libvirtd.qemu.verbatimConfig = ''
    user = "nicolas"
    group = "kvm"
    cgroup_device_acl = [
        "/dev/input/by-id/usb-_USB_Keyboard-event-kbd",
        "/dev/input/by-id/usb-PixArt_USB_Optical_Mouse-event-mouse",
        "/dev/null", "/dev/full", "/dev/zero",
        "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
        "/dev/rtc","/dev/hpet", "/dev/sev"
    ]
  '';

  services.openafsClient = {
    enable = true;
    cellName = "cri.epita.fr";
    cellServDB = [
      { ip = "10.224.21.100"; dnsname = "afs-0.pie.cri.epita.fr"; }
      { ip = "10.224.21.101"; dnsname = "afs-1.pie.cri.epita.fr"; }
      { ip = "10.224.21.102"; dnsname = "afs-2.pie.cri.epita.fr"; }
    ];
    cache = {
      diskless = true;
    };
    fakestat = true;
  };

  system.stateVersion = "21.05";
}
