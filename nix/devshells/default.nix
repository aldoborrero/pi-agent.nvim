{
  pkgs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages = [
    # lua
    pkgs.lua-language-server
    pkgs.luaPackages.ldoc
    pkgs.luaPackages.luacheck

    # neovim with plenary for tests
    perSystem.self.neovim-test

    # other
    pkgs.just

    # formatter
    perSystem.self.formatter
  ];
  shellHook = ''
    export PRJ_ROOT=$PWD
  '';
}
