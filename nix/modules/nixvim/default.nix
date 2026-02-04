{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.plugins.pi-agent;
  helpers = lib.nixvim;
in
{
  options.plugins.pi-agent = helpers.neovim-plugin.extraOptionsOptions // {
    enable = lib.mkEnableOption "pi-agent.nvim plugin";

    package = lib.mkPackageOption pkgs.vimPlugins "pi-agent-nvim" {
      default = null;
      nullable = true;
      extraDescription = ''
        If null, uses the bundled plugin from this flake.
      '';
    };

    settings = helpers.mkSettingsOption {
      description = "Settings for pi-agent.nvim";
      options = {
        window = {
          split_ratio = helpers.defaultNullOpts.mkNum 0.3 ''
            Percentage of screen for the terminal window.
          '';

          position = helpers.defaultNullOpts.mkStr "botright" ''
            Position of the window: "botright", "topleft", "vertical", "float".
          '';

          enter_insert = helpers.defaultNullOpts.mkBool true ''
            Whether to enter insert mode when opening Pi Agent.
          '';

          hide_numbers = helpers.defaultNullOpts.mkBool true ''
            Hide line numbers in the terminal window.
          '';

          hide_signcolumn = helpers.defaultNullOpts.mkBool true ''
            Hide the sign column in the terminal window.
          '';

          float = {
            width = helpers.defaultNullOpts.mkStr "80%" ''
              Width of floating window.
            '';

            height = helpers.defaultNullOpts.mkStr "80%" ''
              Height of floating window.
            '';

            row = helpers.defaultNullOpts.mkStr "center" ''
              Row position.
            '';

            col = helpers.defaultNullOpts.mkStr "center" ''
              Column position.
            '';

            relative = helpers.defaultNullOpts.mkStr "editor" ''
              Relative positioning: "editor" or "cursor".
            '';

            border = helpers.defaultNullOpts.mkStr "rounded" ''
              Border style.
            '';
          };
        };

        refresh = {
          enable = helpers.defaultNullOpts.mkBool true ''
            Enable file change detection.
          '';

          updatetime = helpers.defaultNullOpts.mkNum 100 ''
            updatetime when Pi Agent is active (milliseconds).
          '';

          timer_interval = helpers.defaultNullOpts.mkNum 1000 ''
            How often to check for file changes (milliseconds).
          '';

          show_notifications = helpers.defaultNullOpts.mkBool true ''
            Show notification when files are reloaded.
          '';
        };

        git = {
          use_git_root = helpers.defaultNullOpts.mkBool true ''
            Set CWD to git root when opening Pi Agent.
          '';
        };

        command = helpers.defaultNullOpts.mkStr "pi" ''
          Command used to launch Pi Agent.
        '';

        command_variants =
          helpers.defaultNullOpts.mkAttrsOf lib.types.str
            {
              continue = "--continue";
              resume = "--resume";
              verbose = "--verbose";
            }
            ''
              Command variants.
            '';

        keymaps = {
          toggle = {
            normal =
              helpers.defaultNullOpts.mkNullable (lib.types.either lib.types.str lib.types.bool) "<C-,>"
                ''
                  Normal mode keymap for toggling Pi Agent, or false to disable.
                '';

            terminal =
              helpers.defaultNullOpts.mkNullable (lib.types.either lib.types.str lib.types.bool) "<C-,>"
                ''
                  Terminal mode keymap for toggling Pi Agent, or false to disable.
                '';

            variants =
              helpers.defaultNullOpts.mkAttrsOf lib.types.str
                {
                  continue = "<leader>cC";
                  verbose = "<leader>cV";
                }
                ''
                  Variant keymaps.
                '';
          };

          window_navigation = helpers.defaultNullOpts.mkBool true ''
            Enable window navigation keymaps.
          '';

          scrolling = helpers.defaultNullOpts.mkBool true ''
            Enable scrolling keymaps.
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPlugins =
      let
        pkg =
          if cfg.package != null then
            cfg.package
          else
            pkgs.vimUtils.buildVimPlugin {
              pname = "pi-agent-nvim";
              version = "0.1.0";
              src = ../../..;
            };
      in
      [ pkg ];

    extraConfigLua = ''
      require("pi-agent").setup(${helpers.toLuaObject cfg.settings})
    '';
  };
}
