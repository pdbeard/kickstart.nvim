-- Syntax highlighting: a stable role -> colour *structure*, per colorscheme.
--
-- Why this exists
-- ---------------
-- Colorschemes disagree about how finely they carve up syntax. Some give
-- control flow (`import` / `from` / `if` / `return`) its own colour, distinct
-- from declarations (`def` / `class`); some make every keyword one shade. Some
-- colour function parameters differently from ordinary variables; some don't.
--
-- `M.groups()` below defines that structure once -- which roles are grouped
-- together and which are held apart -- as a mapping from *palette slot names*
-- (not hex codes) onto highlight groups.
--
-- How a colorscheme opts in
-- -------------------------
-- Register a palette for it in `M.palettes`, keyed by `vim.g.colors_name`. On
-- every `:colorscheme`, this module looks up the new scheme:
--   * palette registered  -> apply the structure using *that scheme's* colours
--   * no palette          -> do nothing, leave the scheme entirely alone
--
-- So this never imposes one theme's palette on another. Most modern
-- colorschemes already define the fine-grained `@...` groups themselves and
-- need no entry here; the ones that need it are older schemes (like chinolor)
-- written before treesitter existed.
--
-- Two families of highlight group are set for each role:
--   * treesitter captures  (`@variable.parameter`) -- priority 100
--   * LSP semantic tokens  (`@lsp.type.parameter`) -- priority 125+
-- The LSP names win wherever a language server is attached, so both are needed.
--
-- Use `:Inspect` on any character to see which group is actually being applied.

local M = {}

-- Palette slots. Every colorscheme entry must define the same slot names; the
-- structure in `M.groups()` refers to slots, never to literal colours.
--
-- chinolor: taken verbatim from the Chinolor VS Code theme at
--   ~/.vscode/extensions/iwyvi.chinolor-0.2.20/themes/Chinolor-color-theme.json
M.palettes = {}

M.palettes.chinolor = {
  grey = '#617172', -- comment
  faint = '#474b4c', -- markdown inline-code punctuation
  cream = '#e4dfd7', -- variable, markdown body text
  red = '#ee3f4d', -- invalid, markup.deleted
  pink = '#d276a3', -- keyword, storage.type (def/class/lambda, and/or/not)
  teal = '#57c3c2', -- keyword.control (from/import/for/return/try), inline code
  blue = '#8abcd1', -- entity.name.function, CSS property names, md headings
  orange = '#fb9968', -- variable.parameter, constant.numeric, constant.language
  yellow = '#f9d367', -- string
  green = '#96c24e', -- support.class, support.type, entity.name.type
  salmon = '#f07c82', -- properties, object-literal keys, HTML/JSX tags
  rose = '#eea6b7', -- variable.language (self/cls), entity.name.module
  jade = '#5dbe8a', -- string.regexp, escapes, #id selectors
  mauve = '#c8adc4', -- HTML attributes, JSON keys, markup.quote
}

--- Build the role -> highlight-group table for a palette.
--- @param p table palette of colour names to hex strings
--- @return table<string, table> groups keyed by highlight group name
function M.groups(p)
  local g = {}
  local function set(names, opts)
    for _, name in ipairs(names) do
      g[name] = opts
    end
  end

  -- ---------------------------------------------------------------- keywords
  -- `keyword.control` is teal in VS Code. Neovim's defaults lump all keywords
  -- together as one colour, which is what makes control flow read as purple.
  set({
    '@keyword.import',
    '@keyword.return',
    '@keyword.repeat',
    '@keyword.conditional',
    '@keyword.conditional.ternary',
    '@keyword.exception',
    '@keyword.coroutine',
    '@keyword.debug',
  }, { fg = p.teal })

  -- Generic `keyword` and `storage.type`: def, class, lambda, and/or/not, const.
  set({
    '@keyword',
    '@keyword.function',
    '@keyword.modifier',
    '@keyword.operator',
    '@keyword.type',
    '@type.qualifier',
  }, { fg = p.pink })

  -- --------------------------------------------------------------- variables
  set({ '@variable', '@lsp.type.variable' }, { fg = p.cream })
  set({ '@variable.parameter', '@lsp.type.parameter' }, { fg = p.orange })
  set({ '@variable.builtin', '@lsp.type.selfParameter', '@lsp.type.clsParameter' }, { fg = p.rose, italic = true })

  -- Properties / members / object-literal keys.
  set({
    '@variable.member',
    '@property',
    '@lsp.type.property',
    '@lsp.type.enumMember',
  }, { fg = p.salmon })

  -- --------------------------------------------------------------- functions
  set({
    '@function',
    '@function.call',
    '@function.method',
    '@function.method.call',
    '@function.builtin',
    '@constructor',
    '@lsp.type.function',
    '@lsp.type.method',
    '@lsp.type.decorator',
  }, { fg = p.blue })

  -- ------------------------------------------------------------------- types
  set({
    '@type',
    '@type.builtin',
    '@lsp.type.class',
    '@lsp.type.type',
    '@lsp.type.struct',
    '@lsp.type.enum',
    '@lsp.type.interface',
    '@lsp.type.typeParameter',
  }, { fg = p.green })

  set({ '@module', '@lsp.type.namespace' }, { fg = p.rose })

  -- --------------------------------------------------------------- literals
  set({
    '@number',
    '@number.float',
    '@boolean',
    '@constant',
    '@constant.builtin',
    '@lsp.type.builtinConstant',
  }, { fg = p.orange })

  set({ '@string' }, { fg = p.yellow })
  set({ '@string.regexp', '@string.escape', '@character.special' }, { fg = p.jade })
  set({ '@comment' }, { fg = p.grey })
  set({ '@punctuation.bracket', '@punctuation.delimiter', '@punctuation.special', '@operator' }, { fg = p.cream })
  set({ '@error' }, { fg = p.red })
  set({ '@lsp.mod.unused' }, { fg = p.grey, italic = true })

  -- ------------------------------------------------------- markup (HTML/JSX)
  -- entity.name.tag
  set({ '@tag', '@tag.builtin' }, { fg = p.salmon })
  -- entity.other.attribute-name
  set({ '@tag.attribute', '@attribute' }, { fg = p.mauve })
  set({ '@tag.delimiter' }, { fg = p.cream })

  -- ---------------------------------------------------------------- CSS
  -- source.css support.type.property-name
  set({ '@property.css', '@attribute.css', '@property.scss', '@property.less' }, { fg = p.blue })
  set({ '@type.css', '@type.tag.css' }, { fg = p.salmon })
  -- entity.other.attribute-name.id
  set({ '@attribute.id.css', '@constant.css' }, { fg = p.jade })
  -- constant.other.color
  set({ '@number.css', '@string.plain.css' }, { fg = p.teal })

  -- --------------------------------------------------------------- JSON
  -- source.json support.type.property-name.json
  set({ '@property.json', '@label.json' }, { fg = p.mauve })

  -- ------------------------------------------------------------- Markdown
  set({ '@markup.heading' }, { fg = p.blue, bold = true })
  for lvl = 1, 6 do
    set({ '@markup.heading.' .. lvl .. '.markdown' }, { fg = p.blue, bold = true })
  end
  set({ '@markup.strong' }, { fg = p.salmon, bold = true })
  set({ '@markup.italic' }, { fg = p.cream, italic = true })
  set({ '@markup.strikethrough' }, { fg = p.grey, strikethrough = true })
  set({ '@markup.underline' }, { fg = p.pink, underline = true })
  set({ '@markup.quote' }, { fg = p.mauve, italic = true })
  -- markup.inline.raw
  set({ '@markup.raw', '@markup.raw.markdown_inline' }, { fg = p.teal })
  set({ '@markup.raw.block' }, { fg = p.mauve })
  set({ '@markup.link', '@markup.link.label' }, { fg = p.mauve })
  set({ '@markup.link.url' }, { fg = p.teal, underline = true })
  set({ '@markup.list' }, { fg = p.cream })
  -- markup.inserted / deleted / changed
  set({ '@diff.plus' }, { fg = p.blue })
  set({ '@diff.minus' }, { fg = p.red })
  set({ '@diff.delta' }, { fg = p.mauve })

  return g
end

--- Apply the overrides for the given palette.
--- Apply the structure for whichever colorscheme is active.
---
--- Does nothing when the active colorscheme has no registered palette -- those
--- schemes define the fine-grained groups themselves, and overwriting them with
--- another theme's colours would be worse than leaving them be.
--- @param name? string colorscheme name; defaults to `vim.g.colors_name`
--- @return boolean applied
function M.apply(name)
  local palette = M.palettes[name or vim.g.colors_name or '']
  if not palette then
    return false
  end
  for group, opts in pairs(M.groups(palette)) do
    vim.api.nvim_set_hl(0, group, opts)
  end
  return true
end

--- Re-apply on every colorscheme change.
---
--- `opts.palettes` registers additional colorschemes, e.g.
---   require('custom.highlights').setup {
---     palettes = { tokyonight = { teal = '#7dcfff', pink = '#bb9af7', ... } },
---   }
--- Any scheme not listed is left untouched.
--- @param opts? { palettes?: table<string, table> }
function M.setup(opts)
  opts = opts or {}
  M.palettes = vim.tbl_extend('force', M.palettes, opts.palettes or {})

  vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    group = vim.api.nvim_create_augroup('custom-highlights', { clear = true }),
    callback = function(ev)
      M.apply(ev.match)
    end,
  })
  M.apply()
end

return M
