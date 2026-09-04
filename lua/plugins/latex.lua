return {
  {
    "micangl/cmp-vimtex",
    ft = "tex",
    config = function()
      require("cmp_vimtex").setup {}
    end,
  },

  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_imaps_enabled = 0
      -- Keep K on hover.nvim. Doc lookup stays available as :VimtexDocPackage.
      vim.g.vimtex_mappings_disable = { n = { "K" } }

      vim.g.vimtex_compiler_latexmk = {
        build_dir = "build",
      }
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_quickfix_ignore_filters = {
        "Underfull",
        "Overfull",
        "LaTeX Warning: .\\+ float specifier changed to",
        "Package hyperref Warning: Token not allowed in a PDF string",
      }

      -- \bm and \mathbf are built in, \boldsymbol is not.
      vim.g.vimtex_syntax_custom_cmds = {
        { name = "boldsymbol", mathmode = 1, conceal = 1, argstyle = "bold" },
      }

      -- Conceal comes from vimtex's syntax plugin: installing the treesitter
      -- latex parser would take over tex highlighting and break it.
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        cites = 1,
        fancy = 1,
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }

      -- Window-local: globally this would hide json quotes and markdown links.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserVimtexConceal", { clear = true }),
        pattern = { "tex", "plaintex" },
        callback = function()
          vim.opt_local.conceallevel = 2
        end,
      })
    end,
  },
}
