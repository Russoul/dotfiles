-- oil.nvim: a directory is a buffer. Edit the listing like text, then :w to apply.
--   rename: change the line     delete: dd     create: new line (end with / for a dir)
--   move: dd here, p in another oil buffer
--
-- Default keys inside an oil buffer (g? lists them all):
--   <CR>   open file / enter dir      -     parent dir       _   open nvim's cwd
--   <C-s>  open in vsplit             <C-h> open in split    <C-t> open in tab
--   <C-p>  preview                    <C-c> close oil        <C-l> refresh
--   g.     toggle hidden files        gx    open externally  gs  change sort
--   `      :cd to this dir            ~     :tcd to this dir (sets this tab's project root)
--
-- Note: oil's buffer-local `gs` (sort) shadows leap's `gs` inside oil buffers only.

require('oil').setup({
  -- Take over directory buffers (`nvim .`, `:e some/dir`) instead of netrw / nvim-tree.
  default_file_explorer = true,
  -- Ask before deleting, but apply plain renames/creates without a confirmation popup.
  skip_confirm_for_simple_edits = true,
  -- Send deletions to the macOS Trash instead of removing them for good.
  delete_to_trash = true,
  view_options = {
    show_hidden = true,
  },
})

-- `-` from any file opens its directory, with the cursor on that file.
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Oil: open parent directory' })
