return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.markdown = nil
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    -- WHY: the prebuilt macos-arm64 binary from mkdp#util#install() is unsigned and
    -- SIGKILLed by macOS (E903 error -88); run the server via node instead.
    -- build = "cd app && npx --yes yarn install",
    init = function()
      vim.g.mkdp_theme = "light"
      -- vim.g.mkdp_markdown_css = vim.fn.stdpath("config") .. "/assets/tokyonight-markdown.css"
      -- vim.g.mkdp_highlight_css = vim.fn.stdpath("config") .. "/assets/tokyonight-highlight.css"
    end,
  },
}
