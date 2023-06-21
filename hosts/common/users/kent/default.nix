{ pkgs, config, ... }:
{
  users.user.kent = {
    isNormalUser = true;
    home = "/home/kent";
    description = "Kent";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  }
}
