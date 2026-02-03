{
  pkgs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages = [
    # neovim with plenary for tests
    perSystem.self.nvim-test

    # tools
    pkgs.luaPackages.luacheck
    pkgs.just

    # formatter
    perSystem.self.formatter
  ];
}
