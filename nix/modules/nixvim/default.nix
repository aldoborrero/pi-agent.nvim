{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.plugins.pi-agent;
  nixvim = lib.nixvim;
in
{
  options.plugins.pi-agent = nixvim.plugins.neovim.extraOptionsOptions // {
    enable = lib.mkEnableOption "pi-agent.nvim plugin";

    package = lib.mkPackageOption pkgs.vimPlugins "pi-agent-nvim" {
      default = null;
      nullable = true;
      extraDescription = ''
        If null, uses the bundled plugin from this flake.
      '';
    };

    settings = nixvim.mkSettingsOption {
      description = "Settings for pi-agent.nvim";
      options = {
        window = {
          split_ratio = nixvim.defaultNullOpts.mkNum 0.3 ''
            Percentage of screen for the terminal window.
          '';

          position = nixvim.defaultNullOpts.mkStr "botright" ''
            Position of the window: "botright", "topleft", "vertical", "float".
          '';

          enter_insert = nixvim.defaultNullOpts.mkBool true ''
            Whether to enter insert mode when opening Pi Agent.
          '';

          hide_numbers = nixvim.defaultNullOpts.mkBool true ''
            Hide line numbers in the terminal window.
          '';

          hide_signcolumn = nixvim.defaultNullOpts.mkBool true ''
            Hide the sign column in the terminal window.
          '';

          float = {
            width = nixvim.defaultNullOpts.mkStr "80%" ''
              Width of floating window.
            '';

            height = nixvim.defaultNullOpts.mkStr "80%" ''
              Height of floating window.
            '';

            row = nixvim.defaultNullOpts.mkStr "center" ''
              Row position.
            '';

            col = nixvim.defaultNullOpts.mkStr "center" ''
              Column position.
            '';

            relative = nixvim.defaultNullOpts.mkStr "editor" ''
              Relative positioning: "editor" or "cursor".
            '';

            border = nixvim.defaultNullOpts.mkStr "rounded" ''
              Border style.
            '';
          };
        };

        refresh = {
          enable = nixvim.defaultNullOpts.mkBool true ''
            Enable file change detection.
          '';

          updatetime = nixvim.defaultNullOpts.mkNum 100 ''
            updatetime when Pi Agent is active (milliseconds).
          '';

          timer_interval = nixvim.defaultNullOpts.mkNum 1000 ''
            How often to check for file changes (milliseconds).
          '';

          show_notifications = nixvim.defaultNullOpts.mkBool true ''
            Show notification when files are reloaded.
          '';
        };

        git = {
          use_git_root = nixvim.defaultNullOpts.mkBool true ''
            Set CWD to git root when opening Pi Agent.
          '';
        };

        command = nixvim.defaultNullOpts.mkStr "pi" ''
          Command used to launch Pi Agent.
        '';

        command_variants =
          nixvim.defaultNullOpts.mkAttrsOf lib.types.str
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
              nixvim.defaultNullOpts.mkNullable (lib.types.either lib.types.str lib.types.bool) "<C-,>"
                ''
                  Normal mode keymap for toggling Pi Agent, or false to disable.
                '';

            terminal =
              nixvim.defaultNullOpts.mkNullable (lib.types.either lib.types.str lib.types.bool) "<C-,>"
                ''
                  Terminal mode keymap for toggling Pi Agent, or false to disable.
                '';

            variants =
              nixvim.defaultNullOpts.mkAttrsOf lib.types.str
                {
                  continue = "<leader>pC";
                  verbose = "<leader>pV";
                }
                ''
                  Variant keymaps.
                '';
          };

          window_navigation = nixvim.defaultNullOpts.mkBool true ''
            Enable window navigation keymaps.
          '';

          scrolling = nixvim.defaultNullOpts.mkBool true ''
            Enable scrolling keymaps.
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPlugins =
      let
        cleanSrc = lib.cleanSourceWith {
          src = ../../..;
          filter =
            path: type:
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
        pkg =
          if cfg.package != null then
            cfg.package
          else
            pkgs.vimUtils.buildVimPlugin {
              pname = "pi-agent-nvim";
              version = "0.1.0";
              src = cleanSrc;
            };
      in
      [ pkg ];

    extraConfigLua = ''
      require("pi-agent").setup(${nixvim.toLuaObject cfg.settings})
    '';
  };
}
