local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local dap = require("dap")

telescope.load_extension("dap")

local function dap_commands()
  local excluded = { attach = true, run = true, launch = true }
  local results = {}

  for name, fn in pairs(dap) do
    if type(fn) == "function" and not excluded[name] then
      table.insert(results, name)
    end
  end

  pickers
    .new({}, {
      prompt_title = "DAP Commands",
      finder = finders.new_table({ results = results }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          local ok, err = pcall(dap[selection.value])
          if not ok then
            vim.notify(("DAP command failed: %s"):format(err), vim.log.levels.ERROR)
          end
        end)
        return true
      end,
    })
    :find()
end

vim.keymap.set("n", "<leader>dc", dap_commands, { silent = true, desc = "DAP commands" })
vim.keymap.set("n", "<leader>dC", "<cmd>Telescope dap configurations<CR>", { silent = true, desc = "DAP configurations" })
vim.keymap.set("n", "<leader>db", "<cmd>Telescope dap list_breakpoints<CR>", { silent = true, desc = "DAP breakpoints" })
vim.keymap.set("n", "<leader>dv", "<cmd>Telescope dap variables<CR>", { silent = true, desc = "DAP variables" })
vim.keymap.set("n", "<leader>df", "<cmd>Telescope dap frames<CR>", { silent = true, desc = "DAP frames" })
