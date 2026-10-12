-- Persistent shells via shpool, shown as Neovim terminal buffers named shpool://<session>.
--
--   :Sh [name]         open (or focus) a shell in a bottom split.
--                      No name: use the current tab's name (see tabs-setup.lua).
--                      A new session starts in the tab's working directory.
--   :e shpool://name   the same, in the current window.
--
-- Any buffer named shpool://... attaches to its shpool session when it is loaded.
-- So when a saved Neovim session is restored, its shell windows reattach, and the
-- processes in them have kept running inside shpool the whole time.

local api = vim.api
local PREFIX = 'shpool://'

local M = {}

local function find_buf(bufname)
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_get_name(buf) == bufname then
      return buf
    end
  end
end

local function job_alive(buf)
  local chan = vim.bo[buf].channel
  return chan > 0 and vim.fn.jobwait({ chan }, 0)[1] == -1
end

-- Turn the (empty) buffer `buf` into a terminal attached to shpool session `name`.
local function attach(buf, name)
  -- The rename below would make the throwaway term:// name the window's alternate
  -- file (and that buffer is wiped), losing the file you came from. Keep it.
  local alt = api.nvim_get_current_buf() == buf and vim.fn.bufnr('#') or -1
  api.nvim_buf_call(buf, function()
    vim.fn.jobstart({ 'shpool', 'attach', '-d', '.', name }, { term = true, cwd = vim.fn.getcwd() })
  end)
  -- Starting a terminal renames the buffer to term://...; put the stable name back.
  local term_name = api.nvim_buf_get_name(buf)
  api.nvim_buf_set_name(buf, PREFIX .. name)
  -- Renaming leaves the old term:// name behind as an empty unlisted buffer; wipe it.
  local leftover = find_buf(term_name)
  if leftover and leftover ~= buf and not api.nvim_buf_is_loaded(leftover) then
    api.nvim_buf_delete(leftover, { force = true })
  end
  if alt > 0 and alt ~= buf and api.nvim_buf_is_valid(alt) and api.nvim_get_current_buf() == buf then
    vim.fn.setreg('#', alt)
  end
  vim.b[buf].shpool_session = name -- handy for statusline components
end

api.nvim_create_autocmd('BufReadCmd', {
  pattern = PREFIX .. '*',
  desc = 'Attach shpool://<name> buffers to their shpool session',
  callback = function(args)
    local name = args.match:sub(#PREFIX + 1)
    if name ~= '' then
      attach(args.buf, name)
    end
  end,
})

local function default_name()
  local ok, tabs = pcall(require, 'tabs-setup')
  local name = ok and tabs.name() or vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
  return (name:gsub('%s+', '-'))
end

function M.open(name)
  if not name or name == '' then
    name = default_name()
  end
  local bufname = PREFIX .. name
  local buf = find_buf(bufname)

  if buf and api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == 'terminal' then
    if job_alive(buf) then
      -- Already attached: focus its window, or show it in a split.
      local win = vim.fn.bufwinid(buf)
      if win ~= -1 then
        api.nvim_set_current_win(win)
      else
        vim.cmd('botright sbuffer ' .. buf)
      end
      return
    end
    -- The client exited (e.g. you detached with shpool's keybinding): drop the stale buffer.
    api.nvim_buf_delete(buf, { force = true })
  end

  -- Not open, or listed but not yet loaded (e.g. restored from a session): loading attaches it.
  vim.cmd('botright split')
  vim.cmd.edit(vim.fn.fnameescape(bufname))
end

api.nvim_create_user_command('Sh', function(opts)
  M.open(opts.args)
end, { nargs = '?', desc = 'Open a persistent shpool shell (default: named after the tab)' })

return M
