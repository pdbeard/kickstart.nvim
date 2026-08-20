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

  -- Editor chrome, from the theme's `colors` block. Key names below are the
  -- VS Code setting each value comes from.
  ui = {
    bg = '#2b312c', -- editor.background
    fg = '#e4dfd7', -- editor.foreground
    line_highlight = '#1a241e', -- editor.lineHighlightBackground
    selection = '#474b4c', -- editor.selectionBackground
    word_highlight = '#474b4c', -- editor.wordHighlightBackground
    cursor = '#e4dfd7', -- editorCursor.foreground
    indent_guide = '#617172', -- editorIndentGuide.activeBackground1
    bracket = '#87cefa', -- editorBracketHighlight.foreground3
    bracket_bad = '#ee3f4d', -- editorBracketHighlight.unexpectedBracket.foreground
    sidebar_bg = '#1e201f', -- sideBar.background
    sidebar_fg = '#e4dfd7', -- sideBarTitle.foreground
    statusbar_bg = '#134857', -- statusBar.background
    tab_inactive_bg = '#2a2a2a', -- tab.inactiveBackground
    border = '#575b5c', -- tab.activeBorderTop
    blame = '#474b4c', -- git.blame.editorDecorationForeground
    linked_edit = '#c1651a', -- editor.linkedEditingBackground
  },

  -- terminal.ansi* -- used for `:terminal` via vim.g.terminal_color_0..15.
  terminal = {
    [0] = '#000000', -- ansiBlack
    [1] = '#ee3f4d', -- ansiRed
    [2] = '#96c24e', -- ansiGreen
    [3] = '#f9d367', -- ansiYellow
    [4] = '#619ac3', -- ansiBlue
    [5] = '#d276a3', -- ansiMagenta
    [6] = '#57c3c2', -- ansiCyan
    [7] = '#e4dfd7', -- ansiWhite
    [8] = '#8a988e', -- ansiBrightBlack
    [9] = '#ee3f4d', -- ansiBrightRed
    [10] = '#41ae3c', -- ansiBrightGreen
    [11] = '#b78d12', -- ansiBrightYellow
    [12] = '#619ac3', -- ansiBrightBlue
    [13] = '#cc5595', -- ansiBrightMagenta
    [14] = '#12aa9c', -- ansiBrightCyan
    [15] = '#f8f4ed', -- ansiBrightWhite
  },
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
--- Editor chrome groups, from the theme's `colors` block.
---
--- VS Code and Neovim don't carve the UI up identically, so these fall into two
--- kinds, marked below: a *direct* mapping where the theme names the exact
--- thing, and a *derived* one where Neovim has a group VS Code has no setting
--- for and the closest theme colour is used.
--- @param u table the `ui` sub-table of a palette
--- @return table<string, table>
function M.ui_groups(u)
  return {
    -- direct
    Normal = { fg = u.fg, bg = u.bg },
    NormalNC = { fg = u.fg, bg = u.bg },
    CursorLine = { bg = u.line_highlight },
    Visual = { bg = u.selection },
    Cursor = { fg = u.bg, bg = u.cursor },
    MatchParen = { fg = u.bracket, bold = true },
    StatusLine = { fg = u.fg, bg = u.statusbar_bg },
    TabLine = { fg = u.fg, bg = u.tab_inactive_bg },
    TabLineFill = { bg = u.tab_inactive_bg },
    TabLineSel = { fg = u.fg, bg = u.bg },

    -- editor.wordHighlightBackground -- the highlight-references-under-cursor
    -- behaviour kickstart wires up on CursorHold.
    LspReferenceText = { bg = u.word_highlight },
    LspReferenceRead = { bg = u.word_highlight },
    LspReferenceWrite = { bg = u.word_highlight },

    -- editorIndentGuide -- indent-blankline
    IblIndent = { fg = u.border },
    IblScope = { fg = u.indent_guide },

    -- sideBar.* -- neo-tree
    NeoTreeNormal = { fg = u.fg, bg = u.sidebar_bg },
    NeoTreeNormalNC = { fg = u.fg, bg = u.sidebar_bg },
    NeoTreeEndOfBuffer = { fg = u.sidebar_bg, bg = u.sidebar_bg },
    NeoTreeRootName = { fg = u.sidebar_fg, bold = true },

    -- git.blame.editorDecorationForeground -- gitsigns inline blame
    GitSignsCurrentLineBlame = { fg = u.blame },

    -- editor.linkedEditingBackground -- rename preview
    Substitute = { bg = u.linked_edit, fg = u.fg },

    -- derived: Neovim needs these; VS Code has no direct equivalent setting.
    NormalFloat = { fg = u.fg, bg = u.bg },
    FloatBorder = { fg = u.border, bg = u.bg },
    WinSeparator = { fg = u.border },
    StatusLineNC = { fg = u.indent_guide, bg = u.tab_inactive_bg },
    CursorLineNr = { fg = u.fg, bold = true },
    LineNr = { fg = u.indent_guide },
    ColorColumn = { bg = u.line_highlight },
    SignColumn = { bg = u.bg },
    EndOfBuffer = { fg = u.bg },
    Folded = { fg = u.indent_guide, bg = u.line_highlight },
    WinBar = { fg = u.fg, bg = u.bg },
    WinBarNC = { fg = u.indent_guide, bg = u.bg },
  }
end

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

  if palette.ui then
    for group, opts in pairs(M.ui_groups(palette.ui)) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  end

  -- terminal.ansi* -> `:terminal` colours.
  if palette.terminal then
    for i = 0, 15 do
      if palette.terminal[i] then
        vim.g['terminal_color_' .. i] = palette.terminal[i]
      end
    end
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
