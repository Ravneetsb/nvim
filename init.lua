-- ==============================
-- Basic Neovim settings
-- ==============================
vim.g.mapleader = " "          -- Space as leader
vim.opt.number = true          -- Line numbers
vim.opt.relativenumber = false -- Relative numbers
vim.g.riscv_asm_all_enable = true
vim.opt.tabstop = 2            -- Tab size
vim.opt.shiftwidth = 2
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.termguicolors = true   -- True color support
vim.opt.cursorline = true      -- Highlight current line
-- vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
-- enable concealing (global defaults)
vim.opt.conceallevel = 2     -- 0 = disabled, 1/2/3 increases hiding behavior
vim.opt.concealcursor = "nc" -- conceal in Normal and Command modes (not Insert)
vim.opt.scrolloff = 999

vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = vim.api.nvim_create_augroup("ClearSearchHighlightOnSearchEnd", { clear = true }),
  pattern = { "/", "?" },
  callback = function()
    vim.schedule(function()
      vim.cmd("nohlsearch")
    end)
  end,
})

-- ==============================
-- Bootstrap lazy.nvim (plugin manager)

-- ==============================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==============================
-- Plugins
-- ==============================
require("lazy").setup({
  -- Helper library
  "nvim-lua/plenary.nvim",
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = true
  },

  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function() vim.cmd.colorscheme("tokyonight-night") end
  },
  -- Treesitter (better syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },



  -- Telescope (fuzzy finder)
  { "nvim-telescope/telescope.nvim", tag = "0.1.5" },
  { "nvim-java/nvim-java", },

  -- LSP (language server support)
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_enable = {
        exclude = {
          "rust_analyzer",
        },
      },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  "neovim/nvim-lspconfig",
  {
    "mason-org/mason.nvim",
    opts = {}
  },
  { 'nvim-mini/mini.nvim', version = false },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- Your entire configuration table goes here
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
        progress = {
          enabled = false,
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,        -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      win = {
        width = 40,
        height = 20,
        relative = "editor",
        row = 0.95,
        col = 0.95
      }
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>xr",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP List",
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols",
      },
      {
        "<leader>xl",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List",
      },
      {
        "<leader>xq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List",
      },
    },
  },
  {
    "goolord/alpha-nvim",
    -- dependencies = { 'nvim-mini/mini.icons' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local startify = require("alpha.themes.startify")
      -- available: devicons, mini, default is mini
      -- if provider not loaded and enabled is true, it will try to use another provider
      startify.file_icons.provider = "devicons"
      require("alpha").setup(
        startify.config
      )
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        sync_root_with_cwd = true,
        renderer = {
          group_empty = true,
        },
        actions = {
          change_dir = {
            enable = true,
            global = true, -- use :cd instead of :lcd
          },
        },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    version = "*",
    lazy = false,
    config = function()
      require('gitsigns').setup {
        signs                        = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged                 = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged_enable          = true,
        signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir                 = {
          follow_files = true
        },
        auto_attach                  = true,
        attach_to_untracked          = false,
        current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts      = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority                = 6,
        update_debounce              = 100,
        status_formatter             = nil,   -- Use default
        max_file_length              = 40000, -- Disable if file is longer than this (in lines)
        preview_config               = {
          -- Options passed to nvim_open_win
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
      }
    end
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },
  -- lazy.nvim
  {
    "chrisgrieser/nvim-origami",
    event = "VeryLazy",
    opts = {}, -- needed even when using default config

    -- recommended: disable vim's auto-folding
    init = function()
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
    end,
  },
  {
    "purescript-contrib/purescript-vim",
    ft = "purescript",
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,

  },
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        notify_no_formatters = false,
        format_on_save = function(bufnr)
          if vim.bo[bufnr].buftype ~= "" then
            return nil
          end

          return {
            timeout_ms = 1000,
            lsp_format = "fallback",
          }
        end,
        formatters_by_ft = {
          lua = { "stylua", "emmylua-codeformat" },
          -- Conform will run multiple formatters sequentially
          python = { "isort", "black" },
          -- You can customize some of the format options for the filetype (:help conform.format)
          rust = { "rustfmt", lsp_format = "fallback" },
          -- Conform will run the first available formatter
          javascript = { "prettierd", "prettier", stop_after_first = true },
          json = { "biome" },
        },
      })
    end
  },
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        continuous = 1,
        callback = 1,
        executable = "latexmk",
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
        },
      }
    end,
  },
  {
    "nvim-neotest/nvim-nio",
    lazy = false,
  },
  {
    "mfussenegger/nvim-dap",             -- core debug adapter protocol
    dependencies = {
      "rcarriga/nvim-dap-ui",            -- nice floating UI for scopes, stacks, etc.
      "theHamsta/nvim-dap-virtual-text", -- inline variable display
      "nvim-neotest/nvim-nio",           -- async helpers for dap-ui
    },
    config = function()
      local dap = require("dap")
      if not pcall(require, "nio") then
        require("lazy").load({ plugins = { "nvim-nio" } })
      end
      local dapui = require("dapui")
      local ok, err = pcall(dapui.setup)
      if not ok then
        vim.schedule(function()
          vim.notify("nvim-dap-ui setup failed: " .. err, vim.log.levels.ERROR)
        end)
        return
      end
      require("nvim-dap-virtual-text").setup()

      -- open/close UI automatically
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- keymaps
      vim.keymap.set("n", "<leader>b", "<Nop>", { desc = "Debugger" })
      vim.keymap.set("n", "<leader>bc", dap.continue, { desc = "Start/Continue debug" })
      vim.keymap.set("n", "<leader>bv", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<leader>bi", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<leader>bo", dap.step_out, { desc = "Step out" })
      vim.keymap.set("n", "<leader>bb", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>bB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Conditional breakpoint" })
      vim.keymap.set("n", "<leader>br", dap.repl.open, { desc = "Open REPL" })
      vim.keymap.set("n", "<leader>bl", dap.run_last, { desc = "Run last" })
    end,
  },
  {
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require("elixir")
      local elixirls = require("elixir.elixirls")

      elixir.setup({
        nextls = { enable = false }, -- use ElixirLS for now
        credo = {},
        elixirls = {
          enable = true,
          settings = elixirls.settings({
            dialyzerEnabled = false,
            fetchDeps = false,
          }),

          -- optional: debug support
          on_attach = function(client, bufnr)
            require("elixir.elixirls").setup_dap()
          end,
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  -- Lua
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    opts = {
      -- add any custom options here
    }
  },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } }, -- optional: you can also use fzf-lua, snacks, mini-pick instead.
    },
    ft = "python",                                                                                       -- Load when opening Python files
    keys = {
      { ",v", "<cmd>VenvSelect<cr>" },                                                                   -- Open picker on keymap
    },
    opts = {                                                                                             -- this can be an empty lua table - just showing below for clarity.
      search = {},                                                                                       -- if you add your own searches, they go here.
      options = {}}},                                                                                       -- if you add plugin options, they go here.
      {"henry-hsieh/riscv-asm-vim",
    ft = { "riscv_asm" },
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^7",
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    opts = {
      inline_highlight = {
        highlight = "RenderMarkdownInlineHighlight",
      },
    },
    config = function(_, opts)
      local function set_inline_highlight()
        vim.api.nvim_set_hl(0, "RenderMarkdownInlineHighlight", {
          bg = "#d7f3f0",
          fg = "#0f3f3a",
        })
      end

      set_inline_highlight()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_inline_highlight,
      })

      require("render-markdown").setup(opts)
    end,
  },



  -- {
  --   "hrsh7th/nvim-cmp",
  --   event = "InsertEnter",
  --   dependencies = {
  --     { "hrsh7th/cmp-nvim-lsp" },
  --     { "hrsh7th/cmp-vsnip" },
  --     { "hrsh7th/vim-vsnip" }
  --   },
  --   opts = function()
  --     local cmp = require("cmp")
  --     local conf = {
  --       sources = {
  --         { name = "nvim_lsp" },
  --         { name = "vsnip" },
  --       },
  --       snippet = {
  --         expand = function(args)
  --           -- Comes from vsnip
  --           fn["vsnip#anonymous"](args.body)
  --         end,
  --       },
  --       mapping = cmp.mapping.preset.insert({
  --         -- None of this made sense to me when first looking into this since there
  --         -- is no vim docs, but you can't have select = true here _unless_ you are
  --         -- also using the snippet stuff. So keep in mind that if you remove
  --         -- snippets you need to remove this select
  --         ["<CR>"] = cmp.mapping.confirm({ select = true })
  --       })
  --     }
  --     return conf
  --   end
  -- },
  {
    --   "scalameta/nvim-metals",
    --   dependencies = {
    --     {
    --       "j-hui/fidget.nvim",
    --       opts = {},
    --     },
    --     {
    --       "mfussenegger/nvim-dap",
    --       config = function(self, opts)
    --         -- Debug settings if you're using nvim-dap
    --         local dap = require("dap")
    --
    --         dap.configurations.scala = {
    --           {
    --             type = "scala",
    --             request = "launch",
    --             name = "RunOrTest",
    --             metals = {
    --               runType = "runOrTestFile",
    --               --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
    --             },
    --           },
    --           {
    --             type = "scala",
    --             request = "launch",
    --             name = "Test Target",
    --             metals = {
    --               runType = "testTarget",
    --             },
    --           },
    --         }
    --       end
    --     },
    --   },
    --   ft = { "scala", "sbt", "java" },
    --   opts = function()
    --     local metals_config = require("metals").bare_config()
    --
    --     -- Example of settings
    --     metals_config.settings = {
    --       showImplicitArguments = true,
    --       excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
    --     }
    --
    --     -- *READ THIS*
    --     -- I *highly* recommend setting statusBarProvider to either "off" or "on"
    --     --
    --     -- "off" will enable LSP progress notifications by Metals and you'll need
    --     -- to ensure you have a plugin like fidget.nvim installed to handle them.
    --     --
    --     -- "on" will enable the custom Metals status extension and you *have* to have
    --     -- a have settings to capture this in your statusline or else you'll not see
    --     -- any messages from metals. There is more info in the help docs about this
    --     metals_config.init_options.statusBarProvider = "off"
    --
    --     -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
    --     metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
    --
    --     metals_config.on_attach = function(client, bufnr)
    --       require("metals").setup_dap()
    --
    --       -- LSP mappings
    --       map("n", "gD", vim.lsp.buf.definition)
    --       map("n", "K", vim.lsp.buf.hover)
    --       map("n", "gi", vim.lsp.buf.implementation)
    --       map("n", "gr", vim.lsp.buf.references)
    --       map("n", "gds", vim.lsp.buf.document_symbol)
    --       map("n", "gws", vim.lsp.buf.workspace_symbol)
    --       map("n", "<leader>cl", vim.lsp.codelens.run)
    --       map("n", "<leader>sh", vim.lsp.buf.signature_help)
    --       map("n", "<leader>rn", vim.lsp.buf.rename)
    --       map("n", "<leader>f", vim.lsp.buf.format)
    --       map("n", "<leader>ca", vim.lsp.buf.code_action)
    --
    --       map("n", "<leader>ws", function()
    --         require("metals").hover_worksheet()
    --       end)
    --
    --       -- all workspace diagnostics
    --       map("n", "<leader>aa", vim.diagnostic.setqflist)
    --
    --       -- all workspace errors
    --       map("n", "<leader>ae", function()
    --         vim.diagnostic.setqflist({ severity = "E" })
    --       end)
    --
    --       -- all workspace warnings
    --       map("n", "<leader>aw", function()
    --         vim.diagnostic.setqflist({ severity = "W" })
    --       end)
    --
    --       -- buffer diagnostics only
    --       map("n", "<leader>d", vim.diagnostic.setloclist)
    --
    --       map("n", "[c", function()
    --         vim.diagnostic.goto_prev({ wrap = false })
    --       end)
    --
    --       map("n", "]c", function()
    --         vim.diagnostic.goto_next({ wrap = false })
    --       end)
    --
    --       -- Example mappings for usage with nvim-dap. If you don't use that, you can
    --       -- skip these
    --       map("n", "<leader>dc", function()
    --         require("dap").continue()
    --       end)
    --
    --       map("n", "<leader>dr", function()
    --         require("dap").repl.toggle()
    --       end)
    --
    --       map("n", "<leader>dK", function()
    --         require("dap.ui.widgets").hover()
    --       end)
    --
    --       map("n", "<leader>dt", function()
    --         require("dap").toggle_breakpoint()
    --       end)
    --
    --       map("n", "<leader>dso", function()
    --         require("dap").step_over()
    --       end)
    --
    --       map("n", "<leader>dsi", function()
    --         require("dap").step_into()
    --       end)
    --
    --       map("n", "<leader>dl", function()
    --         require("dap").run_last()
    --       end)
    --     end
    --
    --     return metals_config
    --   end,
    --   config = function(self, metals_config)
    --     local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    --     vim.api.nvim_create_autocmd("FileType", {
    --       pattern = self.ft,
    --       callback = function()
    --         require("metals").initialize_or_attach(metals_config)
    --       end,
    --       group = nvim_metals_group,
    --     })
    --   end
    --
    -- }

  }
})
require("minis")
require("core.keymaps")
require("core.lsp")
require("debugger.python")
