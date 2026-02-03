{ pkgs, inputs, ... }:
inputs.treefmt-nix.lib.mkWrapper pkgs {
  projectRootFile = "flake.nix";
  programs = {
    # nix
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;

    # lua
    stylua.enable = true;
    stylua.settings = {
      column_width = 120;
      line_endings = "Unix";
      indent_type = "Spaces";
      indent_width = 2;
      quote_style = "AutoPreferSingle";
      call_parentheses = "Input";
    };

    # markdown
    mdformat.enable = true;

    # yaml
    yamlfmt.enable = true;
    yamllint.enable = true;
    yamlfmt.settings = {
      formatter = {
        type = "basic";
        indent = 2;
        max_line_length = 0;
        retain_line_breaks = true;
      };
    };
    yamllint.settings = {
      rules = {
        line-length = "disable";
        document-start = "disable";
        truthy = "disable";
      };
    };
  };
  settings.formatter = {
    deadnix.pipeline = "nix";
    deadnix.priority = 1;

    statix.pipeline = "nix";
    statix.priority = 2;

    nixfmt.pipeline = "nix";
    nixfmt.priority = 3;

    yamllint.pipeline = "yaml";
    yamllint.priority = 1;

    yamlfmt.pipeline = "yaml";
    yamlfmt.priority = 2;
  };
}
