vim.lsp.config('hls', {
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
  cmd = { "haskell-language-server-wrapper", "--lsp" },
  haskell = {
    cabalFormattingProvider = "cabalfmt",
    formattingProvider = "stylish-haskell",
  }
})

require('haskell-tools').project.root_dir = function(_) return vim.fn.getcwd() end
require('haskell-tools.config.internal').hls.default_settings.haskell.formattingProvider = 'stylish-haskell'
require('haskell-tools.config.internal').hls.default_settings.haskell.plugin = {
    semanticTokens = { globalOn = true }
}

-- Run HLS inside the project's nix environment (flake devShell, or shell.nix)
-- so it picks up the project's GHC and dependencies. Falls back to the HLS on
-- PATH for non-nix projects. The root is cwd, matching project.root_dir above.
require('haskell-tools.config.internal').hls.cmd = function()
  local HTConfig = require('haskell-tools.config.internal')
  local root = vim.fn.getcwd()
  local hls = { 'haskell-language-server-wrapper', '--lsp', '--logfile', HTConfig.hls.logfile }
  if HTConfig.hls.debug then
    table.insert(hls, '--debug')
  end
  if vim.uv.fs_stat(root .. '/flake.nix') then
    return vim.list_extend({ 'nix', 'develop', root, '--command' }, hls)
  elseif vim.uv.fs_stat(root .. '/shell.nix') then
    local escaped = vim.tbl_map(vim.fn.shellescape, hls)
    return { 'nix-shell', root .. '/shell.nix', '--run', table.concat(escaped, ' ') }
  end
  return hls
end

local ht = require('haskell-tools')
local opts = { noremap = true, silent = true }
-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
vim.keymap.set('n', '<space>cl', vim.lsp.codelens.run, opts)
-- Hoogle search for the type signature of the definition under the cursor
vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
-- Evaluate all code snippets
vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, opts)
-- Toggle a GHCi repl for the current package
vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
-- Toggle a GHCi repl for the current buffer
vim.keymap.set('n', '<leader>rf', function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, opts)
vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)

-- Open the Hackage source browser for the symbol under the cursor, at the
-- exact definition (via the anchor Haddock's hyperlinked source generates).
-- For symbols HLS can't jump-to-def into (e.g. GHC boot packages like
-- `base`/`ghc-prim`/`template-haskell`, whose .hs source isn't shipped
-- locally), this is the next best thing to <LocalLeader>j.
local function open_hackage_source()
  local params = vim.lsp.util.make_position_params()
  local cword = vim.fn.expand('<cword>')
  vim.lsp.buf_request(0, 'textDocument/hover', params, function(err, result)
    if err or not result or not result.contents then
      vim.notify('open_hackage_source: no hover info under cursor', vim.log.levels.WARN)
      return
    end
    local text = result.contents.value or result.contents
    if type(text) == 'table' then text = text.value end

    local symbol = text:match('```haskell\n([%w_\']+)') or cword
    -- the quotes here are the literal 3-byte UTF-8 curly quotes ‘ ’ HLS uses
    -- in "Defined in ‘Module’" -- not a character class (Lua [...] matches
    -- single bytes, not multi-byte UTF-8 sequences).
    local module = text:match("Defined%s+in%s+\226\128\152([%w%.]+)\226\128\153")
    local pkg = text:match('%(([%w%-]+%-[%d%.]+)%)')

    if not (module and pkg) then
      vim.notify(
        'open_hackage_source: could not parse module/package from hover '
          .. '(symbol may be workspace-local, or hover format changed)',
        vim.log.levels.WARN
      )
      return
    end

    local url = ('https://hackage.haskell.org/package/%s/docs/src/%s.html#%s'):format(pkg, module, symbol)
    vim.ui.open(url)
  end)
end

vim.keymap.set('n', '<LocalLeader>s', open_hackage_source, { desc = 'Open Hackage source for symbol under cursor' })
