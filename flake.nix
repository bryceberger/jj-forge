{
  description = "A translation layer between Jujutsu (jj) and code forges like GitHub.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system: function nixpkgs.legacyPackages.${system});
  in {
    overlays.default = final: prev: {
      jujutsu = self.packages.${final.system}.jujutsu;
    };

    packages = forAllSystems (pkgs: {
      jj-forge = pkgs.buildGoModule {
        pname = "jj-forge";
        version = "0.0.0";
        src = ./.;
      };
      nativeBuildInputs = [pkgs.installShellFiles];

      postInstall = ''
        installShellCompletion --cmd jj-forge \
          --bash <($out/bin/jj-forge completion bash) \
          --fish <($out/bin/jj-forge completion fish) \
          --zsh <($out/bin/jj-forge completion zsh)
      '';

      meta = {
        description = "A translation layer between Jujutsu (jj) and code forges like GitHub.";
        homepage = "https://github.com/msuozzo/jj-forge";
        mainProgram = "jj-forge";
      };
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          go
          golangci-lint
          golangci-lint-langserver
          gopls
        ];
      };
    });
  };
}
