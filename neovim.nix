{pkgs, ...}: let
  gp-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "gp.nvim";
    version = "v3.9.0";
    src = pkgs.fetchFromGitHub {
      owner = "robitx";
      repo = "gp.nvim";
      rev = "e6a01e9788dbc7c09df6ffe47b6d15d1cb455de8"; # <-- pin a known good commit
      sha256 = "sha256-3tfhahQZPBYbAnRQXtMAnfwr4gH7mdjxtB8ZqrU3au4=";
    };
  };
in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = true;
    withNodeJs = true;
    extraPython3Packages = pkgs:
      with pkgs; [
        python-lsp-server
        # Other Python packages for Neovim...
        black
        pyyaml
      ];
    extraPackages = with pkgs; [
      pyright
      lua-language-server
      nodePackages.prettier
    ];
    plugins = with pkgs.vimPlugins; [
      lualine-nvim
      nvim-web-devicons
      {
        plugin = nvim-treesitter.withPlugins (p: [
          p.tree-sitter-nix
          p.tree-sitter-vim
          p.tree-sitter-bash
          p.tree-sitter-lua
          p.tree-sitter-python
          p.tree-sitter-json
        ]);
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/nvim-treesitter.lua}
          '';
      }
      gruvbox-nvim
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/nvim-lspconfig.lua}
          '';
      }
      fugitive
      vim-rhubarb
      {
        plugin = neogit;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/neogit.lua}
          '';
      }
      {
        plugin = gp-nvim;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/gp-nvim.lua}
          '';
      }
      # diffview - optional dependency for neogit
      diffview-nvim
      {
        plugin = oil-nvim;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/oil.lua}
          '';
      }
      nvim-treesitter-textobjects
      gruvbox-material
      vim-code-dark
      mini-nvim
      nvim-web-devicons
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/nvim-tree-lua.lua}
          '';
      }
      vim-tmux-navigator
      vim-tmux-clipboard
      vim-unimpaired

      vim-dadbod
      {
        plugin = vim-dadbod-ui;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/vim-dadbod.lua}
          '';
      }
      vim-dadbod-completion

      nvim-dap
      {
        plugin = nvim-dap-ui;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/nvim-dap-ui.lua}
          '';
      }

      {
        plugin = nvim-dap-python;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/nvim-dap-python.lua}
          '';
      }

      plenary-nvim
      telescope-nvim

      {
        plugin = fzf-lua;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/fzf-lua.lua}
          '';
      }

      {
        plugin = nvim-surround;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/nvim-surround.lua}
          '';
      }

      {
        plugin = lualine-nvim;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/lualine-nvim.lua}
          '';
      }

      {
        plugin = bufferline-nvim;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/bufferline-nvim.lua}
          '';
      }

      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/indent-blankline-nvim.lua}
          '';
      }

      vim-signify

      {
        plugin = aerial-nvim;
        type = "lua";
        config =
          # lua
          ''
            ${builtins.readFile ./nvim/plugin/aerial-nvim.lua}
          '';
      }

      {
        plugin = comment-nvim;
        type = "lua";
        config =
          # lua
          ''
            require('Comment').setup()
          '';
      }
    ];
    extraLuaConfig =
      # lua
      ''
        local black_bin = "${pkgs.python3Packages.black}/bin/black - --quiet"
        -- Set the equalprg option for Python files
        vim.api.nvim_create_augroup("python_format", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "python",
          group = "python_format",
          callback = function()
            vim.bo.equalprg = black_bin
          end,
        })

        ${builtins.readFile ./nvim/options.lua}
      '';
  };
}
