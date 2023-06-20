# MyFlake
My NixOS system configurations as a flake

### Current Folder Structure:
Inside the `hosts` folder are the host specific configuration files sorted by `hostname_processorArchitecture` naming to allow for aarch64 servers like raspberryPis to be included in the same hosts folder, allowing me to update the main `flake.nix` file as infrequently as possible.
```
hosts/
  laptop1_x86_64/
    configuration.nix
    hardware-configuration.nix
  laptop2_x86_64/
    configuration.nix
    hardware-configuration.nix
  fileserver_aarch64/
    configuration.nix
    hardware-configuration.nix
```
