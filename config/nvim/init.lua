----------- NVIM CONFIG (ver 0.10.0) ------------

local g = vim.g
local o = vim.o
local fn = vim.fn

------------- Basic options --------------

-- A keymap for openning the init.lua file from anywhere
vim.cmd [[nnoremap <C-x>cf :e $MYVIMRC<CR>]]

g.mapleader = '|'
g.main_config_file_dir = os.getenv("HOME") .. "/.config/nvim"
g.python3_host_prog = '/usr/bin/python3'
-- disable netrw at the very start of your init.lua
g.loaded_netrwPlugin = 1

-- This setting helps to avoid encoding issues when
-- writing unicode to clipboard (the `+` register)
vim.env.LANG = 'en_US.UTF-8'

o.virtualedit = 'block'
o.shiftwidth = 2
o.tabstop = 2
-- Tabs are not present in source, always expanded to spaces
o.expandtab = true
o.smartcase = true
o.ignorecase = true
o.maxfuncdepth = 10000
-- Tell Vim to wait indefinitely for further input when pressing a prefix key
o.timeout = false
-- Enables mouse in all modes
o.mouse = 'a'
o.wildmenu = true
o.wildmode = 'list'
o.history = 200
o.scrollback = 100000
-- Set path to your preferred shell here
o.shell = '/opt/homebrew/bin/fish'
-- Time period at the end of which the swap file is being writen to disk.
o.updatetime = 100
-- Previews changes done in interactive commands
o.inccommand = 'nosplit'
-- Allow up to 3 signs to be rendered simultaneously
o.signcolumn = 'auto:3'

if vim.g.neovide then
  vim.keymap.set({'i', 'c'}, '<D-v>', '<C-r>+')
  vim.keymap.set({'t'}, '<D-v>', '<C-\\><C-n>"+pa')
  vim.keymap.set({'n', 'v'}, '<D-v>', '"+p')
  vim.g.neovide_no_idle = false
  vim.g.neovide_refresh_rate_idle = 0

  -- Zoom in/out/reset with Cmd+= / Cmd+- / Cmd+0
  vim.g.neovide_scale_factor = 1.0
  local function zoom(factor)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * factor
  end
  vim.keymap.set({'n', 'v', 'i', 't'}, '<D-=>', function() zoom(1.1) end)
  vim.keymap.set({'n', 'v', 'i', 't'}, '<D-->', function() zoom(1 / 1.1) end)
  vim.keymap.set({'n', 'v', 'i', 't'}, '<D-0>', function() vim.g.neovide_scale_factor = 1.0 end)
end

-- Ignore left and right mouse/trackpad movements
vim.keymap.set('', '<ScrollWheelLeft>', '<Nop>', { silent = true })
vim.keymap.set('', '<ScrollWheelRight>', '<Nop>', { silent = true })

----------------- Lazy package manager --------------

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Draws a box over the outline of the selection
    { 'jbyuki/venn.nvim',                commit = '71856b548e3206e33bad10acea294ca8b44327ee' },
    {'sindrets/diffview.nvim',
       commit = "4516612fe98ff56ae0415a259ff6361a89419b0a",
       config = function ()
         require('diffview-setup')
       end
    },
    -- A UI for git
    require('neogit-plugin'),
    -- Surrounding text with delimiters
    { 'https://tpope.io/vim/surround.git',              commit = 'bf3480dc9ae7bea34c78fbba4c65b4548b5b1fea' },
    -- Repeating complex commands; often plugins require
    -- this as a dependency in order for the repeat (.) to work properly
    { 'https://tpope.io/vim/repeat.git',                commit = '24afe922e6a05891756ecf331f39a1f6743d3d5a' },
    -- Nice directory tree view (switched off in favour of neo-tree; set enabled = true to bring it back)
    { 'kyazdani42/nvim-tree.lua',                       commit = '478c69c0fe253caea88de9c5e138bfa77395a59a', enabled = false },
    -- Sidebar file tree: project overview, git status, follows the current file
    {
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'main',
      dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim', 'nvim-tree/nvim-web-devicons' },
      lazy = false,
      config = function()
        require('neo-tree-setup')
      end,
    },
    -- Directories as editable buffers: rename, move, create, delete by editing text, then :w
    {
      'stevearc/oil.nvim',
      -- Not lazy-loaded: it has to be ready to take over `nvim <dir>` at startup.
      lazy = false,
      config = function()
        require('oil-setup')
      end,
    },
    -- The best theme ever (subjectively of course) !
    { 'https://github.com/joshdick/onedark.vim.git',    commit = '7db2ed5b825a311d0f6d12694d4738cf60106dc8' },
    -- Renders a special line at the bottom of each window that reflects user info
    { 'nvim-lualine/lualine.nvim',                      dependencies = { 'nvim-tree/nvim-web-devicons' }, commit = "221ce6b2d999187044529f49da6554a92f740a96" },
    -- Nice when you can't keep up with your cursor movements all around the frame
    -- (Dims all windows except the one the cursor is currently in)
    { 'https://github.com/blueyed/vim-diminactive.git', commit = '6f2e14e6ff6a038285937c378ec3685e6ff7ee36' },
    -- LSP configs
    { 'neovim/nvim-lspconfig',                          commit = '046b1a797af1effe8e0474b9af9657a3761ec58a' },
    -- Used by many plugins
    { 'nvim-lua/plenary.nvim',                          commit = 'a3e3bc82a3f95c5ed0d7201546d5d2c19b20d683' },
    -- Icons
    { 'kyazdani42/nvim-web-devicons',                   commit = 'c0cfc1738361b5da1cd0a962dd6f774cc444f856' },
    -- Manage git workflow
    { 'pwntester/octo.nvim',                            commit = 'b51e528' },
    -- Successor of Signify for Neovim, Lua
    { 'lewis6991/gitsigns.nvim',                        commit = '070a5d7b985546cc57e1fc61e5bc507fecac6045' },
    -- Stand-in for VimSneak (works differently)
    { url = "https://codeberg.org/andyg/leap.nvim" },
    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate'
    },
    -- Nova's own spec format (.nspec): the plugin lives in the Nova repo.
    { dir = '~/Projects/Nova/dev/tools/nvim', name = 'nspec' },
    -- Highlights in colour special symbols like:
    --   * TODO:
    --   * NOTE:
    --   * FIX:
    --   * PERF:
    --   * HACK:
    --   * IDEA:
    --   * REFACTOR:
    --   and additionally marks lines with signs
    { 'folke/todo-comments.nvim',                       commit = '98b1ebf198836bdc226c0562b9f906584e6c400e' },
    -- Idris 2 LSP client
    { 'Russoul/idris2-nvim',                            commit = '67d0bf98f5c59b3e1e3b66325d30d6302071cc20', opts = {} },
    -- UI component library
    { 'MunifTanjim/nui.nvim',                           commit = '322978c734866996274467de084a95e4f9b5e0b1' },
    -- Terminal
    { 'akinsho/toggleterm.nvim',                        commit = '9a88eae817ef395952e08650b3283726786fb5fb' },
    -- Buffers that contain past searches and cmds
    { 'notomo/cmdbuf.nvim',                             commit = 'e6b37e80cab18368d64184557c3a956cafa4ced7' },
    -- Tabs at the top of the screen
    { 'akinsho/bufferline.nvim',                        commit = '81820cac7c85e51e4cf179f8a66d13dbf7b032d9' },
    -- Metals LSP client for scala lang
    require('metals-plugin'),
    -- A buffer for showing diagnostics, references, telescope results, quickfix and location lists
    require('trouble-plugin'),
    -- Show git blame
    { 'FabijanZulj/blame.nvim',              commit = '3e6b2ef4905982cd7d26eb5b18b0e761138eb5ab' },
    { "Russoul/abbrev-expand.nvim", lazy = false },
    { "Russoul/window-manip.nvim", lazy = false },
    { "Russoul/block-move.nvim",   lazy = false, commit = "f404e3f8f28d9e3a2ad9b7e78e138a2c69720162" },
    -- Notifications as self-dismissing toasts (replaces vim.notify, so multi-line
    -- messages no longer block on a hit-enter prompt). Also LSP progress for metals.
    {
      "j-hui/fidget.nvim",
      lazy = false,
      opts = {
        notification = { override_vim_notify = true },
      },
    },
    -- Send `@claude:` comment instructions to a running Claude Code session
    {
      dir = "~/Projects/claude-send.nvim",
      cmd = { "ClaudeSend", "ClaudeSendAll", "ClaudeSendCancel", "ClaudeTarget", "ClaudeSendLog" },
      keys = {
        { "<leader>aa", "<cmd>ClaudeSend<cr>",       desc = "Claude: send instruction under cursor" },
        { "<leader>aA", "<cmd>ClaudeSendAll<cr>",    desc = "Claude: send all instructions in buffer" },
        { "<leader>ax", "<cmd>ClaudeSendCancel<cr>", desc = "Claude: cancel queued instruction" },
        { "<leader>at", "<cmd>ClaudeTarget<cr>",     desc = "Claude: choose session for this tab" },
        { "<leader>al", "<cmd>ClaudeSendLog<cr>",    desc = "Claude: list sent instructions" },
      },
      opts = {},
    },
    -- Helpful for finding out what keys are mapped to interatively
    require('which-key-plugin'),
    -- Typescript LSP
    {
      "pmizio/typescript-tools.nvim",
      dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
      opts = {},
    },
    -- Subword textobj and more
    {
      "chrisgrieser/nvim-various-textobjs",
      keys = {},
    },
    -- Motions defined for moving around camel-case words
    { "chrisgrieser/nvim-spider" },
    -- Pick a window by letter: |wj jumps to one; neo-tree's `w` opens a file in one
    {
      's1n7ax/nvim-window-picker',
      name = 'window-picker',
      event = 'VeryLazy',
      version = '2.*',
      keys = {
        {
          "<leader>wj",
          function()
            -- Unlike the defaults (kept for neo-tree), jumping may target the
            -- file tree and terminals too.
            local win = require('window-picker').pick_window({
              filter_rules = { bo = { filetype = { 'notify', 'snacks_notif' }, buftype = {} } },
            })
            if win then
              vim.api.nvim_set_current_win(win)
            end
          end,
          desc = "window-picker: Jump to window",
        },
      },
      config = function()
        require('window-picker').setup()
      end,
    },
    require('fzf-lua-plugin'),
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/nvim-cmp' },
    {
      'mrcjkb/haskell-tools.nvim',
      version = '^7', -- Recommended
      lazy = false, -- This plugin is already lazy
    }

  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
  rocks = {
    enabled = true,
    hererocks = true, -- you should enable this to get hererocks support
  }
})

---------- Persistent undo ----------
if fn.has('persistent_undo') == 1 then
  o.undofile = true
  o.undodir = os.getenv("HOME") .. "/.config/nvim/undo"
end

---------- Enable line numbers for particular file types -------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "vim,idris2,python,javascript,lua,c,hott,nova,txt,agda,scala,cpp,h,haskell",
  callback = function(_)
    vim.o.number = true
  end,
  desc = "Shows a numeration column on the left edge of the window",
})


---------- Toggle latest search highlight ---------
vim.api.nvim_set_keymap(
  'n',
  '<Leader><Space>',
  '', {
    callback = function() vim.o.hlsearch = not vim.o.hlsearch end,
    noremap = true,
    silent = true
  }
)

----------------- Execute selection ----------------

-- execute visually selected code block (vimL)
vim.api.nvim_set_keymap(
  'v',
  '<C-x><C-e>v',
  '"xy:@x<CR>',
  { noremap = false, silent = true }
)

-- execute visually selected code block (Lua)
vim.api.nvim_set_keymap(
  'v',
  '<C-x><C-e>l',
  '"xy:execute(":lua " . @x)<CR>',
  { noremap = false, silent = true }
)

-------- Highlight on yank (vanity) ----------
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function(_)
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 100, on_visual = true }
  end,
  desc = "Briefly highlights yanked text.",
})

-------- Cursor shape/colour, colour theme, colour palette --------
-- Set theme and cursor shape/color
if vim.fn.has("termguicolors") == 1 then
  vim.o.termguicolors = true
end

vim.cmd [[colorscheme onedark]]
o.guicursor = 'n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor'

-- Colour palette setup
vim.cmd [[hi Error ctermfg=204 guifg=#FF0000]]
vim.cmd [[hi Conceal guifg=#FBAB00]]
vim.cmd [[hi todo guifg=#CCCC00]]
vim.cmd [[hi ColorColumn guibg=#303541]]
vim.cmd [[hi Search guifg=black guibg=orange4]]
vim.cmd [[hi @variable ctermfg=59 guifg=#5c6370]]
vim.cmd [[hi Comment ctermfg=59 guifg=#99ccff]]

------------------ Fundamental motions ----------------
--   Main movement remaps
--                 i
--                 ^
--   I use         |
--           j <--- --->  l
--                 |
--   For           v
--    movement     k
--

vim.cmd [[map <S-l> <nop>]]
vim.cmd [[noremap <S-j> ^]]
vim.cmd [[noremap <S-l> g_]]
vim.cmd [[nnoremap k <Down>]]
vim.cmd [[nnoremap j <Left>]]
vim.cmd [[nnoremap i <Up>]]
vim.cmd [[vnoremap k <Down>]]
vim.cmd [[vnoremap j <Left>]]
vim.cmd [[vnoremap i <Up>]]
vim.cmd [[vnoremap I i]]
vim.cmd [[nnoremap h i]]
vim.cmd [[vnoremap h i]]
vim.cmd [[nnoremap H I]]
vim.cmd [[vnoremap H I]]
vim.cmd [[nnoremap <C-P> <C-I>]]
vim.cmd [[nnoremap I <nop>]]

-- Jump to the start/end of a line in insert/cmd modes
vim.cmd [[inoremap <C-j> <C-o>^]]
vim.cmd [[inoremap <C-l> <C-o>$]]
vim.cmd [[cnoremap <C-j> <C-b>]]
vim.cmd [[cnoremap <C-l> <C-e>]]

-- terminal escape sequence
-- I'm ok with <C-v> because I'm on Mac (<D-v> is used for pasting)
vim.api.nvim_set_keymap(
  't',
  '<C-v><Esc>',
  '<C-\\><C-n>',
  { noremap = true, silent = true }
)

-- remap of join
vim.api.nvim_set_keymap(
  'n',
  '<Space>j',
  ':join<CR>',
  { noremap = true, silent = true }
)

-- unmap this built-in command, else it messes up with the commands below
vim.api.nvim_set_keymap(
  '',
  '<C-x>',
  '',
  { noremap = true, silent = true }
)


---------- Trailing whitespace cleanup ------------
function StripTrailingWhitespace()
  local l = fn.line(".")
  local c = fn.col(".")
  vim.cmd [[%s/\s\+$//e]]
  fn.cursor(l, c)
end

-- Creating a custom user command in 0.7
vim.api.nvim_create_user_command("StripTrailingWhitespace", function(_)
  StripTrailingWhitespace()
end, {
  nargs = "?",
  desc = "Strips trailing whitespace.",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(_) StripTrailingWhitespace() end,
  desc = "Strips whitespace on file writes.",
})

------------------ Buffers -------------------

-- Close all buffers except this one (caveat: doesn't keep the cursor position)
vim.cmd [[nnoremap <silent> <C-x>qab :%bd\|e#<CR>]]
vim.cmd [[nnoremap <silent> <C-x>qb :b#<bar>bd#<CR>]]

-- Switch to the alternate buffer
vim.cmd [[nnoremap <C-u> <C-^>]]

------------------ Window manipulation interface (custom plugin) -----------------
local win_manip = require("window-manip")
win_manip.setup({})

-- Start window manipulation session
vim.keymap.set("n", "<C-w>w", function() win_manip.start("focus", false) end)

-- Switching between windows (j=left, i=up, k=down, l=right)
vim.keymap.set("n", "<C-w>i", function() vim.cmd.wincmd("k") end)
vim.keymap.set("n", "<C-w>k", function() vim.cmd.wincmd("j") end)
vim.keymap.set("n", "<C-w>j", function() vim.cmd.wincmd("h") end)
vim.keymap.set("n", "<C-w>l", function() vim.cmd.wincmd("l") end)

-- Switching between windows from terminal mode
vim.keymap.set("t", "<C-w>i", function() vim.cmd.wincmd("k") end)
vim.keymap.set("t", "<C-w>j", function() vim.cmd.wincmd("h") end)
vim.keymap.set("t", "<C-w>k", function() vim.cmd.wincmd("j") end)
vim.keymap.set("t", "<C-w>l", function() vim.cmd.wincmd("l") end)

-- Push current window to screen edge
vim.keymap.set("n", "<C-w>I", function() vim.cmd.wincmd("K") end)
vim.keymap.set("n", "<C-w>K", function() vim.cmd.wincmd("J") end)
vim.keymap.set("n", "<C-w>J", function() vim.cmd.wincmd("H") end)
vim.keymap.set("n", "<C-w>L", function() vim.cmd.wincmd("L") end)
vim.keymap.set("t", "<C-w>I", function() vim.cmd.wincmd("K") end)
vim.keymap.set("t", "<C-w>K", function() vim.cmd.wincmd("J") end)
vim.keymap.set("t", "<C-w>J", function() vim.cmd.wincmd("H") end)
vim.keymap.set("t", "<C-w>L", function() vim.cmd.wincmd("L") end)

-------------- Jumping inside buffer only (custom plugin) ----------------
vim.cmd [[execute("source " . g:main_config_file_dir . "/config/jumping.vim")]]

-- Those two commands allow one to jump back and forth
-- the jump list but only moving along the lines in the current buffer
vim.cmd [[nnoremap <silent> <Space><C-I> :call JumpNextInBuf()<CR>]]
vim.cmd [[nnoremap <silent> <Space><C-O> :call JumpPrevInBuf()<CR>]]

----------------- Git Signs ----------------
require('gitsigns-setup')

---------- abbrev-expand ----------
-- TODO: make this work in terminals and popup windows, like one found in telescope
require('abbrev-expand').setup(require('abbrev-expand-setup'))

------------------- Octo --------------------
require('octo-setup')

---------------- TODO comments ---------------
require('todo-comments-setup')

------------------ Dev Icons -------------------
require("nvim-web-devicons").setup { default = true }

------------------ Lua Line --------------------
require("lualine-setup")

------------------ Yaml LSP --------------------
vim.lsp.enable('yamlls')

-------------- Moving selection around (custom plugin) -------------
vim.api.nvim_set_keymap('v', '<C-k>', ":lua require('block-move').moveSelectionDown()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-i>', ":lua require('block-move').moveSelectionUp()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-l>', ":lua require('block-move').moveSelectionRight()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-j>', ":lua require('block-move').moveSelectionLeft()<CR>", { noremap = true, silent = true })

--------------- CmdBuf ---------------
vim.cmd [[noremap q: <Cmd>lua require('cmdbuf').split_open(vim.o.cmdwinheight)<CR>]]
vim.cmd [[cnoremap <C-f> <Cmd>lua require('cmdbuf').split_open(vim.o.cmdwinheight, {line = vim.fn.getcmdline(), column = vim.fn.getcmdpos()})<CR><C-c>]]

-- open lua command-line window
vim.cmd [[nnoremap ql <Cmd>lua require('cmdbuf').split_open( vim.o.cmdwinheight, {type = "lua/cmd"})<CR>]]

vim.cmd [[nnoremap <C-x>x <Cmd>lua require('cmdbuf').execute()<CR>]]

-- q/, q? alternative
vim.cmd [[nnoremap q/ <Cmd>lua require('cmdbuf').split_open(
  \ vim.o.cmdwinheight,
  \ {type = "vim/search/forward"}
  \ )<CR>]]
vim.cmd [[nnoremap q? <Cmd>lua require('cmdbuf').split_open(
  \ vim.o.cmdwinheight,
  \ {type = "vim/search/backward"}
  \ )<CR>]]

-------------- ToggleTerm -------------
require('toggleterm').setup {
  shade_terminals = false,
  start_in_insert = false,
  auto_scroll = false,
}

vim.cmd [[nnoremap <silent> <C-w>t :ToggleTerm<CR>]]

-- Open an existing terminal instance in the current window.
vim.cmd [[nnoremap <silent> <C-w>t :ToggleTerm<CR>]]

------------  Nvim Tree ---------------
-- Switched off (see the plugin spec); neo-tree replaces it, configured in lua/neo-tree-setup.lua.
-- require('nvim-tree-setup')

------------ LEAP -------------
require('leap-setup')

------------- Buffer Line -------------
require('bufferline').setup {
  options = {
    mode = "tabs",
    numbers = "ordinal",
    -- Label each tab with its name (t:name, or its directory); see lua/tabs-setup.lua
    name_formatter = function(buf)
      if buf.tabnr then return require('tabs-setup').name(buf.tabnr) end
    end,
  }
}

-- These commands will navigate through buffers in order regardless of which mode you are using
-- e.g. if you change the order of buffers :bnext and :bprevious will not respect the custom ordering
vim.cmd [[nnoremap <silent>]b :BufferLineCycleNext<CR>]]
vim.cmd [[nnoremap <silent>[b :BufferLineCyclePrev<CR>]]

----------------- General LSP mappings ------------------
vim.api.nvim_set_keymap('n', '<LocalLeader>j', ':lua vim.lsp.buf.definition()<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '<LocalLeader>h', ':lua vim.lsp.buf.hover()<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '<LocalLeader>a', ':FzfLua lsp_code_actions<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '<LocalLeader>d', ':lua vim.lsp.buf.signature_help()<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '<LocalLeader>f', ':lua vim.lsp.buf.format()<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '<LocalLeader>i', ':lua vim.lsp.buf.implementation()<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '<LocalLeader>r', ':lua vim.lsp.buf.references()<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '<LocalLeader>w', ':lua vim.lsp.buf.rename()<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', ']d', ':lua vim.diagnostic.goto_next()<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '[d', ':lua vim.diagnostic.goto_prev()<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', ']e', ':lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '[e', ':lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', ']w', ':lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '[w', ':lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', ']i', ':lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.INFO})<CR>',
  { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '[i', ':lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.INFO})<CR>',
  { noremap = true, silent = false })


-------------- Lua LSP ----------------
require('lua-setup')

------------- C/C++ LSP ---------------
vim.lsp.enable('clangd')

----------- Type Script -----------
vim.lsp.enable('ts_ls')

--------------- JSON ----------------
vim.lsp.enable('jsonls')

--------------- OCaml ---------------
-- ocamllsp must match the compiler that built _build/, so take it from the
-- project's nix dev shell rather than a global install.
vim.lsp.config('ocamllsp', {
  cmd = { 'nix', 'develop', '--command', 'ocamllsp' },
})
vim.lsp.enable('ocamllsp')

--------------- Idris2 --------------
require('idris2-setup')

----------------- Nova ----------------
-- The plugin lives in the Nova repo and is installed with
-- `nix run .#install-nvim-plugin`; it carries the nova-lsp it was built
-- against, starts it for .nova buffers, and renders nova/elabTime.
-- Semantic highlighting is neovim's native support, so the server's
-- legend maps onto @lsp.type.* with nothing to keep in sync here.
--
-- `nix run .#install-nvim-plugin` links it to the path below. Neovim
-- would normally load that from pack/*/start on its own, but lazy.nvim
-- resets 'packpath', so the directory is added explicitly. The link is
-- stable across reinstalls; only its target moves.
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site/pack/nova/start/nova")
require("nova").setup()

-- Carried over from the old nova-setup.lua, which was otherwise
-- redundant. Delete these two if you would rather take the
-- colourscheme's defaults.
vim.api.nvim_set_hl(0, "@lsp.type.keyword.nova", { link = "Structure" })
vim.api.nvim_set_hl(0, "@lsp.type.comment.nova", { fg = "#99ccff" })

----------------- Massimult ----------------
require("massimult-setup")

----------------- Homotopy Objective Type Theory ----------------
require("hott-setup")

----------------- nvim-various-textojbs ----------------
require('various-textobjs-setup')

---------------- nvim-spider --------------
require('spider-setup')

----------------- nvim-cmp --------------
require('cmp-setup')

----------------- Haskell-tools ----------------
require('haskell-tools-setup')

----------------- venn-setup ----------------
require('venn-setup')

------------------  MISC  ----------------------

vim.api.nvim_create_user_command(
  'Browse',
  function (opts)
    vim.fn.system { 'open', opts.fargs[1] }
  end,
  { nargs = 1 }
)

----------------  Tabs as projects, sessions ----------------------
-- Named tabs with tab-local cwd, <C-x>t tab picker, :SessionSave / :SessionLoad
require('tabs-setup')

----------------  Persistent shells ----------------------
-- :Sh [name] and shpool://name buffers that reattach (also after :SessionLoad)
require('shpool-setup')
