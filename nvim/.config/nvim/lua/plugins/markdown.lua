return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.markdown = nil
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    init = function()
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_markdown_css = vim.fn.stdpath("config") .. "/assets/tokyonight-markdown.css"
      vim.g.mkdp_highlight_css = vim.fn.stdpath("config") .. "/assets/tokyonight-highlight.css"
    end,
  },
}
