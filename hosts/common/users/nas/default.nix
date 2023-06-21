{ pkgs, config, ... }:
{
  # User for the Samba share, don't forget to set a password with `passwd` and `smbpasswd`
  users.users.nas = {
    isNormalUser = true;
    home = "/home/nas";
    description = "Samba user";
  };
}
