{
  pkgs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages = [
    # neovim with plenary for tests
    perSystem.self.neovim-test

    # tools
    pkgs.luaPackages.luacheck
    pkgs.just

    # formatter
    perSystem.self.formatter
  ];
}
