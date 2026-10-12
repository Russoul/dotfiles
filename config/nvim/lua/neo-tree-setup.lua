-- neo-tree: a sidebar tree for project overview. File operations are oil's job (`-`).
--
-- Keys inside the tree (? lists them all):
--   <CR>  open / expand            <BS>  go up a directory      .   make this the root
--   s     open in vsplit           S     open in split          t   open in new tab
--   a     add file (end with / for a dir)    r rename    d delete    m move    c copy
--   H     toggle hidden files      /     fuzzy-filter the tree  P   toggle preview
--   <     previous source          >     next source (filesystem, buffers, git status, symbols)
--   I     file details (moved from `i`, which stays your "up")
--   <C-b> or q   close the sidebar

require('neo-tree').setup({
  -- document_symbols: the current buffer's outline, from its language server
  -- (for .nspec, sections and rules; `:Neotree document_symbols`).
  sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
  -- Close Neovim's last window cleanly instead of leaving only the tree open.
  close_if_last_window = true,
  window = {
    mappings = {
      -- `i` is "up" in your movement layout; neo-tree uses it for file details by default.
      ['i'] = 'none',
      ['I'] = 'show_file_details',
      -- <C-b> toggles the sidebar everywhere, including from inside it
      -- (neo-tree's default here is "scroll preview up").
      ['<C-b>'] = 'close_window',
      -- Toggle at once: the global <Space>… maps (Spider motions, join, jumps,
      -- haskell-tools) mean nothing in the tree, so <Space> need not wait for them.
      ['<space>'] = { 'toggle_node', nowait = true },
    },
  },
  filesystem = {
    -- oil.nvim owns directory buffers (`nvim .`, `:e dir`); neo-tree stays a sidebar.
    hijack_netrw_behavior = 'disabled',
    -- Highlight and reveal the current file as you move between buffers.
    follow_current_file = { enabled = true },
    -- Refresh on filesystem changes (e.g. edits made through oil or a shell).
    use_libuv_file_watcher = true,
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = true,
    },
  },
  document_symbols = {
    -- Highlight the symbol under the cursor in the source buffer.
    follow_cursor = true,
  },
})

-- Same key nvim-tree used.
vim.keymap.set('n', '<C-b>', '<Cmd>Neotree toggle<CR>', { silent = true, desc = 'Neo-tree: toggle sidebar' })
