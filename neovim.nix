{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = true;
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
    ];
    plugins = with pkgs.vimPlugins; [
      # {
      #   plugin = lazy-nvim;
      #   type = "lua";
      #   config =
      #     # lua
      #     ''
      #       ${builtins.readFile ./nvim/plugin/lazy.lua}
      #     '';
      # }
      # lazydev-nvim
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
            -- Nil language server setup
            local lspconfig = require('lspconfig')
            -- Get the Nil binary path from the Nix store
            local nil_bin = "${pkgs.nil}/bin/nil"
            lspconfig.nil_ls.setup {
              cmd = { nil_bin },
              on_attach = on_attach,
              capabilities = capabilities,
            }
            local lua_lsp_bin = "${pkgs.lua-language-server}/bin/lua-language-server"
            lspconfig.lua_ls.setup {
              cmd = { lua_lsp_bin, "-E", "-e", "LANG=en" },
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { "vim" }
                  }
                }
              }
            }
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
      nvim-dap-ui

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
