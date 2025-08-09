require("avante_lib").load()
require("avante").setup({
  provider = "openai",
  openai = {
    endpoint = "https://api.openai.com/v1",
    model = "gpt-4o", -- Changed from gpt-5 to gpt-4o
    stream = true,
    timeout = 30000, -- Timeout in milliseconds
    temperature = 1,
    max_completion_tokens = 4096,
  },
})
