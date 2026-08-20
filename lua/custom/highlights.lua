-- Syntax highlighting overrides, ported from the Chinolor VS Code theme.
--
-- Why this exists
-- ---------------
-- Colorschemes disagree about which *role* gets which colour: one makes every
-- keyword the same shade, another gives parameters no colour of their own. This
-- module pins that mapping down so it stays consistent no matter which
-- colorscheme is loaded.
--
-- The palette and the scope -> colour assignments are taken verbatim from
--   ~/.vscode/extensions/iwyvi.chinolor-0.2.20/themes/Chinolor-color-theme.json
--
-- Two families of highlight group are set for each role:
--   * treesitter captures  (`@variable.parameter`) -- priority 100
--   * LSP semantic tokens  (`@lsp.type.parameter`) -- priority 125+
-- The LSP names win wherever a language server is attached, so both are needed.
--
-- Use `:Inspect` on any character to see which group is actually being applied.

local M = {}

-- Chinolor palette, with the VS Code scope each colour is used for.
M.palette = {
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
--- @param p? table palette; defaults to `M.palette`
function M.apply(p)
  for name, opts in pairs(M.groups(p or M.palette)) do
    vim.api.nvim_set_hl(0, name, opts)
  end
end

--- Re-apply on every colorscheme change, so these role assignments survive
--- `:colorscheme <anything>`.
---
--- Note the trade-off: this imposes the Chinolor palette on whatever scheme is
--- loaded. To keep it scoped to one colorscheme instead, pass its name as
--- `opts.pattern` (e.g. `{ pattern = 'chinolor' }`).
--- @param opts? { pattern?: string|string[] }
function M.setup(opts)
  opts = opts or {}
  vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = opts.pattern or '*',
    group = vim.api.nvim_create_augroup('custom-highlights', { clear = true }),
    callback = function()
      M.apply()
    end,
  })
  M.apply()
end

return M
