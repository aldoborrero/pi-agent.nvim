{ pkgs }:
pkgs.neovim.override {
  configure = {
    packages.test = {
      start = [ pkgs.vimPlugins.plenary-nvim ];
    };
  };
}
