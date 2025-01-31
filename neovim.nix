{pkgs, ...}:
{
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
      extraPackages = [
        pkgs.pyright
      ];
    #   plugins = with pkgs.vimPlugins; [
    #     {
    #       plugin = nvim-lspconfig;
    #       type = "lua";
    #       config = ''
    #         -- Nil language server setup
    #         local lspconfig = require('lspconfig')
    #         -- Get the Nil binary path from the Nix store
    #         local nil_bin = "${pkgs.nil}/bin/nil"
    #         lspconfig.nil_ls.setup {
    #         cmd = { nil_bin },
    #         on_attach = on_attach,
    #         capabilities = capabilities,
    #         }
    #         local lua_lsp_bin = "${pkgs.lua-language-server}/bin/lua-language-server"
    #         lspconfig.lua_ls.setup {
    #         cmd = { lua_lsp_bin, "-E", "-e", "LANG=en" },
    #         capabilities = capabilities,
    #         on_attach = on_attach,
    #         settings = {
    #           Lua = {
    #             diagnostics = {
    #             globals = { "vim" }
    #             }
    #           }
    #         }
    #        }
    #       '';
    #     }
    #     vim-nix
    #     lush-nvim
    #     zenbones-nvim
    #     tokyonight-nvim
    #     fugitive
    #     vim-rhubarb
    #     vimagit
    #     {
    #       plugin = oil-nvim;
    #       type = "lua";
    #       config = ''
    #         require('oil').setup()
    #         vim.keymap.set("n", "<leader>o", require("oil").open, { desc = "Open parent directory" })
    #       '';
    #     }
    #     {
    #       plugin = nvim-treesitter.withAllGrammars;
    #       type = "lua";
    #       config = ''
    #         require'nvim-treesitter.configs'.setup {
    #           highlight = {
    #             enable = true,
    #             -- You can disable specific languages if needed
    #             -- disable = { "c", "rust" },
    #           },
    #           indent = {
    #             enable = true,
    #             -- You can disable specific languages if needed
    #             -- disable = { "python" },
    #           },
    #           -- Optional: Enable incremental selection
    #           incremental_selection = {
    #             enable = true,
    #             keymaps = {
    #               init_selection = "gnn",
    #               node_incremental = "grn",
    #               scope_incremental = "grc",
    #               node_decremental = "grm",
    #             },
    #           },
    #         }
    #       '';
    #     }
    #     nvim-treesitter-textobjects
    #
    #     gruvbox-material
    #     vim-code-dark
    #     papercolor-theme
    #     mini-nvim
    #     nvim-web-devicons
    #     {
    #       plugin = nvim-tree-lua;
    #       type = "lua";
    #       config = ''
    #         -- disable netrw at the very start of your init.lua
    #         vim.g.loaded_netrw = 1
    #         vim.g.loaded_netrwPlugin = 1
    #         -- optionally enable 24-bit colour
    #         -- vim.opt.termguicolors = true
    #         -- empty setup using defaults
    #         require('nvim-tree').setup()
    #         vim.api.nvim_set_keymap('n', '<leader>\\', [[<cmd>NvimTreeToggle<CR>]], { })
    #         vim.api.nvim_set_keymap('n', '<leader>\\\\', [[<cmd>NvimTreeFindFile<CR>]], { })
    #       '';
    #     }
    #     vim-tmux-navigator
    #     vim-tmux-clipboard
    #     vim-unimpaired
    #     vim-dadbod
    #     vim-dadbod-ui
    #     vim-dadbod-completion
    #
    #     nvim-dap
    #   # nvim-dap-ui
    #   {
    #     plugin = nvim-dap-python;
    #     type = "lua";
    #     config = ''
    #       require('dap-python').setup('python3')
    #     '';
    #   }
    #
    #   plenary-nvim
    #   telescope-nvim
    #   {
    #     plugin = fzf-lua;
    #     type = "lua";
    #     config = ''
    #       vim.keymap.set("n", "<leader>ff", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>tt", "<cmd>lua require('fzf-lua').tabs()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>lg", "<cmd>lua require('fzf-lua').live_grep_glob()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>lG", "<cmd>lua require('fzf-lua').fzf_live('rg --no-ignore-vcs --column --line-number --no-heading --color=always --smart-case', { previewer = 'builtin' })<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>Lg", "<cmd>lua require('fzf-lua').live_grep()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>gg", "<cmd>lua require('fzf-lua').grep()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>gl", "<cmd>lua require('fzf-lua').grep_last()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>gp", "<cmd>lua require('fzf-lua').grep_project()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>gC", "<cmd>lua require('fzf-lua').grep_cword()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>gc", "<cmd>lua require('fzf-lua').grep_cWORD()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>gb", "<cmd>lua require('fzf-lua').lgrep_curbuf()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>jj", "<cmd>lua require('fzf-lua').jumps()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>rr", "<cmd>lua require('fzf-lua').registers()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>cc", "<cmd>lua require('fzf-lua').changes()<CR>", { silent = true })
    #       vim.keymap.set("n", "<leader>bb", "<cmd>lua require('fzf-lua').buffers()<CR>", { silent = true })
    #
    #       local actions = require "fzf-lua.actions"
    #
    #       require'fzf-lua'.setup{
    #         files = {
    #           toggle_ignore_flag = "--no-ignore-vcs",
    #           actions = {
    #             ["ctrl-i"] = { actions.toggle_ignore },
    #           },
    #         },
    #       }
    #     '';
    #   }
    #
    #   {
    #     plugin = nvim-surround;
    #     type = "lua";
    #     config = ''
    #       require('nvim-surround').setup()
    #     '';
    #   }
    #
    #   {
    #     plugin = lualine-nvim;
    #     type = "lua";
    #     config = ''
    #       require('lualine').setup({
    #         extensions = { "fugitive", "fzf", "quickfix" },
    #         options = {
    #           icons_enabled = true,
    #           theme = 'auto',
    #         },
    #         tabline = {},
    #       })
    #     '';
    #   }
    #
    #   {
    #     plugin = bufferline-nvim;
    #     type = "lua";
    #     config = ''
    #       require('bufferline').setup({
    #         options = {
    #           mode = "tabs",
    #           numbers = "ordinal",
    #         },
    #       })
    #       vim.keymap.set("n", "<leader>1", "<cmd>BufferLineGoToBuffer 1<CR>")
    #       vim.keymap.set("n", "<leader>2", "<cmd>BufferLineGoToBuffer 2<CR>")
    #       vim.keymap.set("n", "<leader>3", "<cmd>BufferLineGoToBuffer 3<CR>")
    #       vim.keymap.set("n", "<leader>4", "<cmd>BufferLineGoToBuffer 4<CR>")
    #       vim.keymap.set("n", "<leader>5", "<cmd>BufferLineGoToBuffer 5<CR>")
    #       vim.keymap.set("n", "<leader>6", "<cmd>BufferLineGoToBuffer 6<CR>")
    #       vim.keymap.set("n", "<leader>7", "<cmd>BufferLineGoToBuffer 7<CR>")
    #       vim.keymap.set("n", "<leader>8", "<cmd>BufferLineGoToBuffer 8<CR>")
    #       vim.keymap.set("n", "<leader>9", "<cmd>BufferLineGoToBuffer 9<CR>")
    #     '';
    #   }
    #
    #   {
    #     plugin = comment-nvim;
    #     type = "lua";
    #     config = ''
    #       require('Comment').setup()
    #     '';
    #   }
    #
    #   {
    #     plugin = indent-blankline-nvim;
    #     type = "lua";
    #     config = ''
    #       require('ibl').setup()
    #     '';
    #   }
    #
    #   vim-signify
    #
    #   {
    #     plugin = aerial-nvim;
    #     type = "lua";
    #     config = ''
    #       require("aerial").setup({
    #         on_attach = function(bufnr)
    #           vim.api.nvim_buf_set_keymap(bufnr, 'n', '{', '<cmd>AerialPrev<CR>', {})
    #           vim.api.nvim_buf_set_keymap(bufnr, 'n', '}', '<cmd>AerialNext<CR>', {})
    #         end,
    #       })
    #       vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
    #     '';
    #   }
    # ];
    # extraConfig = ''
    #   " colorscheme PaperColor
    #   set termguicolors
    #   " set background=light " or dark
    #   set background=dark " or dark
    #   " colorscheme zenbones
    #   " colorscheme tokyobones
    #   colorscheme tokyonight
    #   " Highlight on yank
    #   augroup YankHighlight
    #   autocmd!
    #   autocmd TextYankPost * silent! lua vim.highlight.on_yank()
    #   augroup end
    #   " au FileType python setlocal equalprg=black\ -\ 2>/dev/null
    #   " au FileType nix setlocal equalprg=nixpkgs-fmt
    #   " set clipboard+=unnamedplus
    #   " set clipboard^=unnamed,unnamedplus
    #   let g:db_ui_use_nerd_fonts = 1
    #   " Zooming Vim Window Splits like a Pro
    #   noremap Zz <c-w>_ \| <c-w>\|
    #   noremap Zo <c-w>=
    # '';
    # extraLuaConfig = ''
    #   --Configure black as the formatter for Python files
    #   local black_bin = "${pkgs.python3Packages.black}/bin/black - --quiet"
    #   -- Set the equalprg option for Python files
    #   vim.api.nvim_create_augroup("python_format", { clear = true })
    #   vim.api.nvim_create_autocmd("FileType", {
    #     pattern = "python",
    #     group = "python_format",
    #     callback = function()
    #       vim.bo.equalprg = black_bin
    #     end,
    #   })
    #   --Same for nix files
    #   -- Get the path to the nix executable
    #   --local nix_bin = "${pkgs.nix}/bin/nix"
    #   -- Set the equalprg option for Nix files
    #   -- vim.api.nvim_create_augroup("nix_format", { clear = true })
    #   --vim.api.nvim_create_autocmd("FileType", {
    #   --  pattern = "nix",
    #   --  group = "nix_format",
    #   --  callback = function()
    #   --  vim.bo.equalprg = string.format("%s fmt", nix_bin)
    #   --  end,
    #   --})
    #
    #   --Remap space as leader key
    #   vim.g.mapleader = ' '
    #   vim.g.maplocalleader = ','
    #   vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
    #   vim.keymap.set("n", "<leader>fs", "<cmd>w<cr>")
    #   vim.keymap.set("n", "<leader><Tab>", "<cmd>b#<cr>")
    # '';
  };
}
