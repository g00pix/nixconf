{
  # Desktop at CRI

  imports = [
    ../../common.nix
  ];

  networking.hostName = "callisto";

  networking.interfaces.eno1.useDHCP = true; # TODO: check if name
  networking.interfaces.br0.useDHCP = true;
  networking.bridges = {
    br0 = {
      interfaces = [ "eno1" ];
    };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "dm-mod" "dm-cache" "dm-cache-smq" "dm-thin-pool" "dm-raid" "raid1" "dm-crypt" ];
  boot.kernelModules = [ "kvm-intel" "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" "vfio-pci.ids=10de:1c81,10de:0fb9" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1c81,10de:0fb9
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
      #postOpenCommands = "lvscan"; # TODO: check if necessary
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/9258c3c0-4ae9-4a22-87d8-506b92e91149";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/25E3-2BED";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/397ee699-cd16-48fd-b9ed-d088099501d8"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemuOvmf = true;
  virtualisation.libvirtd.allowedBridges = [ "br0" ];
  virtualisation.libvirtd.qemuVerbatimConfig = ''
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

  virtualisation.docker.enable = true;
}
