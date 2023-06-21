# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
    ../common/users/kent
    ../common/users/nas

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      #outputs.overlays.additions
      #outputs.overlays.modifications
      #outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  networking.hostName = "Delaware";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" "ext4" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "80d54bee";

  # System wide packages, not tied to a user.
  environment.systemPackages = with pkgs; [
    zfs
    jq
    nfs-utils
    git
    wget
    nnn
    mc
    parted
  ];

  # Enable the NFS daemon.
  services.nfs.server.enable = true;
  services.nfs.server.exportOn = {
    "/tank" = {
      clients = "*";
      options = [ "rw" "no_subtree_check" ];
    };
  };

  # Enable the Samba daemon.
  services.samba.enable = true;
  services.samba.configFile = pkgs.writeText "smb.conf" ''
    [global]
    workgroup = WORKGROUP
    security = user
    log file = /var/log/samba/%m
    max log size = 50
  
    [public]
    path = /tank
    writable = yes
    valid users = nas
  '';
  
  # Initialize the ZFS filesystem.
  fileSystems = {
    "/tank" = {
      device = "tank";
      fsType = "zfs";
    };
  };
  
  # Optionally, add your ZIL cache and other ZFS options.
  hardware.zfs.cache.diskDevices = [ "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S6S2NS0T502342K" ];

  # Enable SSH server
  services.openssh = {
    enable = true;
    # Forbid root login through SSH.
    permitRootLogin = "no";
    # Use keys only. Remove if you want to SSH using password (not recommended)
    #passwordAuthentication = false;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
