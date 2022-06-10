{
  description = "A vim plugin to make project switching easier using fzf.vim";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {

      overlay = final: prev: {

        vimPlugins = prev.vimPlugins // {
          fzf-project = with final; vimUtils.buildVimPlugin {
            name = "fzf-project-${version}";
            src = self;
            dependencies = [
              prev.vimPlugins.fzfWrapper
              prev.vimPlugins.vim-fugitive
            ];
          };
        };

      };

      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system});
          vimPlugins.fzf-project = nixpkgsFor.${system}.vimPlugins.fzf-project;
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.vimPlugins.fzf-project);

    };
}
