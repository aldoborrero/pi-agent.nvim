{ pkgs }:
pkgs.vimUtils.buildVimPlugin {
  pname = "pi-agent-nvim";
  version = "0.1.0";
  src = ../..;
  meta = {
    description = "Pi Agent Neovim plugin";
    homepage = "https://github.com/aldoborrero/pi-agent.nvim";
    license = pkgs.lib.licenses.mit;
  };
}
