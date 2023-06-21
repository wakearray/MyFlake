{ inputs, outputs, ... }: {
  nix.gc = {
    automatic = true;
    dates = "2d";
    options = "--delete-older-than 2d";
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      # I think sublime was the one causing this error for me.
      permittedInsecurePackages = [
        "openssl-1.1.1u"
      ];
    };
  };
}
