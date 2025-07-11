{
  description = "mtrag";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        nativeBuildInputs = with pkgs; [
          go
          gopls
          nodejs
          yarn
          sqlite
          webpack-cli
        ];
        buildInputs = with pkgs; [];
      in {
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs buildInputs;
          name = "mtrag";
          shellHook = ''
            if [ ! -f "AllPrintings.sqlite" ]; then
              echo "Downloading AllPrintings.sqlite.gz from https://mtgjson.com/api/v5/AllPrintings.sqlite.gz"
              curl -O https://mtgjson.com/api/v5/AllPrintings.sqlite.gz
              echo "AllPrintings.sqlite.gz downloaded"
              echo "Unzipping AllPrintings.sqlite.gz"
              gunzip AllPrintings.sqlite.gz
              echo "AllPrintings.sqlite.gz unzipped"
            else
              echo "AllPrintings.sqlite already exists, skipping download"
            fi
            echo "Welcome to the mtrag development environment!"
          '';
        };

        packages.default = pkgs.buildGoModule rec {
          name = "mtrag";
          src = ./.;

          inherit buildInputs;

          vendorHash = null;
        };
      }
    );
}
