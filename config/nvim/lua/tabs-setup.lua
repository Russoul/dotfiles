-- One tab per project: tab-local working directories, named tabs, a tab picker,
-- and sessions that remember all of it.
--
--   :TabOpen {dir}       go to the tab whose directory is {dir}, or open a new tab
--                        there (sets the tab-local cwd with :tcd)
--   :TabRename [name]    name the current tab; no argument goes back to the default
--                        (the tab's directory name)
--   <C-x>t               pick a tab by name with fzf-lua
--   <leader>1 .. <leader>9   go to tab 1..9 (the numbers bufferline shows)
--
--   :SessionSave [name]  save tabs, windows, buffers, tab directories and tab names
--                        (default name: "last")
--   :SessionLoad [name]  restore a saved session (default: "last")
--   Once a session has been saved or loaded, it is saved again automatically
--   when Neovim exits.
--
-- Shell windows from shpool-setup.lua (shpool://name) reattach when a session loads.

local api = vim.api
local M = {}

---------------------------------------------------------------- tab names

-- Name of a tab (handle; nil or 0 = current): its t:name, or else the name of its
-- working directory. t:name is the same variable :BufferLineTabRename sets.
function M.name(tab)
  if tab == nil or tab == 0 then
    tab = api.nvim_get_current_tabpage()
  end
  local ok, name = pcall(api.nvim_tabpage_get_var, tab, 'name')
  if ok and type(name) == 'string' and name ~= '' then
    return name
  end
  return vim.fn.fnamemodify(vim.fn.getcwd(-1, api.nvim_tabpage_get_number(tab)), ':t')
end

local function tab_dir(tab)
  return vim.fn.getcwd(-1, api.nvim_tabpage_get_number(tab))
end

api.nvim_create_user_command('TabRename', function(opts)
  if opts.args == '' then
    pcall(api.nvim_tabpage_del_var, 0, 'name')
  else
    api.nvim_tabpage_set_var(0, 'name', opts.args)
  end
  vim.cmd.redrawtabline()
end, { nargs = '?', desc = 'Name the current tab (no argument: use its directory name)' })

function M.open(dir)
  dir = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(dir), ':p'))
  if vim.fn.isdirectory(dir) == 0 then
    vim.notify('TabOpen: not a directory: ' .. dir, vim.log.levels.ERROR)
    return
  end
  for _, tab in ipairs(api.nvim_list_tabpages()) do
    if tab_dir(tab) == dir then
      api.nvim_set_current_tabpage(tab)
      return
    end
  end
  vim.cmd('tabnew')
  vim.cmd.tcd(vim.fn.fnameescape(dir))
end

api.nvim_create_user_command('TabOpen', function(opts)
  M.open(opts.args)
end, { nargs = 1, complete = 'dir', desc = 'Go to the tab for a directory, or open one' })

-- Directory changes can change a tab's default name.
api.nvim_create_autocmd('DirChanged', {
  callback = function()
    vim.cmd.redrawtabline()
  end,
})

---------------------------------------------------------------- tab picker

function M.pick()
  local current = api.nvim_get_current_tabpage()
  local entries = {}
  for _, tab in ipairs(api.nvim_list_tabpages()) do
    local nr = api.nvim_tabpage_get_number(tab)
    local mark = tab == current and '*' or ' '
    -- "<nr>\t<mark> <name>\t<dir>"; the number column is hidden in the list.
    entries[#entries + 1] = string.format('%d\t%s %s\t%s', nr, mark, M.name(tab), vim.fn.fnamemodify(tab_dir(tab), ':~'))
  end
  require('fzf-lua').fzf_exec(entries, {
    prompt = 'Tabs> ',
    fzf_opts = { ['--delimiter'] = '\t', ['--with-nth'] = '2..', ['--tabstop'] = '4' },
    actions = {
      ['enter'] = function(selected)
        local nr = selected and selected[1] and tonumber(selected[1]:match('^(%d+)'))
        if nr then
          vim.cmd(nr .. 'tabnext')
        end
      end,
    },
  })
end

vim.keymap.set('n', '<C-x>t', M.pick, { silent = true, desc = 'Pick a tab by name' })
vim.keymap.set('t', '<C-x>t', function()
  vim.cmd.stopinsert()
  M.pick()
end, { silent = true, desc = 'Pick a tab by name' })

-- <leader>N: jump to tab N.
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, function()
    if i <= vim.fn.tabpagenr('$') then
      vim.cmd(i .. 'tabnext')
    end
  end, { silent = true, desc = 'Go to tab ' .. i })
end

---------------------------------------------------------------- sessions

local session_dir = vim.fn.stdpath('state') .. '/sessions'

-- 'blank' is needed for oil: its windows are saved as named placeholders that oil
-- refills after loading. It also saves neo-tree's sidebar as an empty placeholder
-- named like "neo-tree filesystem [2]"; after loading, each placeholder is replaced
-- by a real neo-tree showing the same source, in the same tab (below).
-- 'globals' carries the tab names; 'terminal' keeps shpool:// shell windows.
vim.opt.sessionoptions = { 'blank', 'buffers', 'curdir', 'folds', 'globals', 'help', 'tabpages', 'winsize', 'terminal' }

local function session_path(name)
  return session_dir .. '/' .. ((name and name ~= '') and name or 'last') .. '.vim'
end

local function save(path)
  vim.fn.mkdir(session_dir, 'p')
  -- Sessions don't store tab variables, but they do store global variables whose
  -- names start with an uppercase letter. Stash explicit tab names there.
  local names = {}
  for _, tab in ipairs(api.nvim_list_tabpages()) do
    local ok, name = pcall(api.nvim_tabpage_get_var, tab, 'name')
    if ok and type(name) == 'string' and name ~= '' then
      names[tostring(api.nvim_tabpage_get_number(tab))] = name
    end
  end
  vim.g.TabNames = vim.json.encode(names)
  vim.cmd('mksession! ' .. vim.fn.fnameescape(path))
end

local function restore_tab_names()
  local ok, names = pcall(vim.json.decode, vim.g.TabNames or '{}')
  if not ok or type(names) ~= 'table' then
    return
  end
  local tabs = api.nvim_list_tabpages()
  for nr, name in pairs(names) do
    local tab = tabs[tonumber(nr)]
    if tab then
      api.nvim_tabpage_set_var(tab, 'name', name)
    end
  end
end

-- Find neo-tree placeholders left by the session, close them, and return
-- { [tabpage] = source } for the tabs that had a sidebar.
local function take_neotree_placeholders()
  local trees = {}
  for _, buf in ipairs(api.nvim_list_bufs()) do
    local tail = vim.fn.fnamemodify(api.nvim_buf_get_name(buf), ':t')
    local source = tail:match('^neo%-tree (%S+) %[')
    if source and vim.bo[buf].filetype ~= 'neo-tree' then
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        trees[api.nvim_win_get_tabpage(win)] = source
        pcall(api.nvim_win_close, win, true)
      end
      -- Wipe it so the real neo-tree can use the same buffer name.
      pcall(api.nvim_buf_delete, buf, { force = true })
    end
  end
  return trees
end

-- Open neo-tree (without focusing it) in each tab that had it.
local function reopen_neotree(trees)
  if vim.tbl_isempty(trees) then
    return
  end
  local has_neotree, command = pcall(require, 'neo-tree.command')
  if not has_neotree then
    return
  end
  -- neo-tree's "show" opens the tree asynchronously and, once it has rendered, jumps
  -- back to the window that was current when it was called. Open one tab at a time,
  -- waiting for each tree to render, so those jumps land in the right tab; then
  -- return to the window the session selected.
  local return_win = api.nvim_get_current_win()
  local function tree_rendered(tab)
    for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
      local buf = api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'neo-tree' and api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= '' then
        return true
      end
    end
    return false
  end
  for tab, source in pairs(trees) do
    if api.nvim_tabpage_is_valid(tab) then
      api.nvim_set_current_tabpage(tab)
      if pcall(command.execute, { action = 'show', source = source }) then
        vim.wait(2000, function()
          return tree_rendered(tab)
        end, 10)
        vim.wait(20) -- let neo-tree's post-render jump run while we are still in this tab
      end
    end
  end
  if api.nvim_win_is_valid(return_win) then
    api.nvim_set_current_win(return_win)
  end
end

-- SessionLoadPost fires once per buffer (the session runs :doautoall); do the work once.
local pending = false
api.nvim_create_autocmd('SessionLoadPost', {
  desc = 'Restore tab names and tidy up after loading a session',
  callback = function()
    if pending then
      return
    end
    pending = true
    vim.schedule(function()
      pending = false
      restore_tab_names()
      reopen_neotree(take_neotree_placeholders())
      vim.cmd.redrawtabline()
    end)
  end,
})

local function complete_sessions()
  return vim.tbl_map(function(f)
    return vim.fn.fnamemodify(f, ':t:r')
  end, vim.fn.glob(session_dir .. '/*.vim', false, true))
end

api.nvim_create_user_command('SessionSave', function(opts)
  local path = session_path(opts.args)
  save(path)
  vim.notify('Session saved: ' .. vim.fn.fnamemodify(path, ':t:r'))
end, { nargs = '?', complete = complete_sessions, desc = 'Save tabs, windows and buffers' })

api.nvim_create_user_command('SessionLoad', function(opts)
  local path = session_path(opts.args)
  if vim.fn.filereadable(path) == 0 then
    vim.notify('No session: ' .. vim.fn.fnamemodify(path, ':t:r'), vim.log.levels.ERROR)
    return
  end
  -- silent: placeholder windows otherwise print "[Not edited]" notices (errors still show).
  vim.cmd('silent source ' .. vim.fn.fnameescape(path))
end, { nargs = '?', complete = complete_sessions, desc = 'Restore a saved session' })

-- Keep the active session up to date: v:this_session is set by :mksession and by
-- loading a session, so a plain `nvim somefile` never overwrites a saved workspace.
api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    local path = vim.v.this_session
    if path ~= '' and vim.startswith(path, session_dir) then
      save(path)
    end
  end,
})

return M
