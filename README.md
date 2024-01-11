# exodriver-flake

Porting [exodriver](https://labjack.com/pages/support/?doc=%2Fsoftware-driver%2Finstaller-downloads%2Fexodriver%2F)
to nixpkg on linux-x86_64
(for using on NixOS or installed by nix or Nix flakes).

I only ported to linux-x86_64 because I cannot test other platforms.
Pull requests are welcome.

## Installation

### NixOS system configuration

```nix
{pkgs, ...}: let
  exodriver = import (builtins.fetchTarball "https://github.com/UlyssesZh/exodriver-flake/archive/master.tar.gz");
in {
  # ...
  environment.systemPackages = [ # or home.packages
    exodriver.packages.exodriver
  ];
}
```

### Flake

Add this repo's GitHub URL to one of the inputs.

## Usage

Just try compiling C/C++ codes with `-llabjackusb`.

To use without installing, you can use [`nix develop`](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html):

```shell
nix develop github:UlyssesZh/exodriver-flake
```

or [`nix-shell`](https://nixos.org/manual/nix/stable/command-ref/nix-shell.html):

```shell
nix-shell https://github.com/UlyssesZh/exodriver-flake/archive/master.tar.gz
```

## License

MIT.

The upstream exodriver is also MIT.
See its source codes [here](https://github.com/labjack/exodriver).
