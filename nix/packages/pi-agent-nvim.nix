{ pkgs }:
let
  inherit (pkgs) lib;
  src = lib.cleanSourceWith {
    src = ../..;
    filter =
      path: _type:
      let
        baseName = baseNameOf path;
      in
      !(
        baseName == ".direnv"
        || baseName == ".ai"
        || baseName == ".git"
        || baseName == "result"
        || lib.hasSuffix ".qcow2" baseName
      );
  };
in
pkgs.vimUtils.buildVimPlugin {
  pname = "pi-agent-nvim";
  version = "0.1.0";
  inherit src;
  meta = {
    description = "Pi Agent Neovim plugin";
    homepage = "https://github.com/aldoborrero/pi-agent.nvim";
    license = pkgs.lib.licenses.mit;
  };
}
