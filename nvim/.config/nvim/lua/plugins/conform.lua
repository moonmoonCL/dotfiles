return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {

        lua = { "stylua" },

        python = { "ruff_format" },

        javascript = { "prettier" },
        typescript = { "prettier" },

        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },

        json = { "prettier" },
        jsonc = { "prettier" },

        yaml = { "prettier" },

        markdown = { "prettier" },

        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
      },
    },
  },
}
