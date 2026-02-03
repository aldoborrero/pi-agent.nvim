{ pkgs }:
pkgs.symlinkJoin {
  name = "nvim-test";
  paths = [ pkgs.neovim ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/nvim \
      --add-flags "--cmd 'set rtp+=${pkgs.vimPlugins.plenary-nvim}'"
  '';
}
