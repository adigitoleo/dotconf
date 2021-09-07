require('vis')
-- https://github.com/martanne/vis/wiki/Plugins

local spellcheck = require('plugins/spellcheck')
-- PKGBUILD is in AUR, upstream is <https://github.com/fischerling/vis-spellcheck>
--      <C-w>e to enable highlighting of bad spelling
--      <C-w>d to disable highlighting of bad spelling
--      <C-w>w to suggest spelling corrections

local pairs = require('plugins/pairs')
pairs.autopairs = false
-- PGKBUILD is in AUR, upstream is <https://repo.or.cz/vis-pairs.git>
--      turn of automatic closing delimiter insertion:
--      pairs = require('plugins/pairs')
--      pairs.autopairs = false

local surround = require('plugins/vis-surround')
-- PKGBUILD is in AUR, upstream is <https://repo.or.cz/vis-surround.git>
--      surround word in brackets: ys]aw
--      change delimiter pair arround word from single quotes to parens: cs')
--      delete pair of braces arround word: ds}

local fzf_open = require('plugins/fzf-open')
-- PKGBUILD is in AUR, upstream is <https://git.sr.ht/~mcepl/vis-fzf-open>
--      :fzf to search all files in the current sub-tree
--      accepts normal fzf arguments, e.g. :fzf -p !.class
--      <Enter> to open file, or <C-s> and <C-v> for horizontal/vertical splits

vis.events.subscribe(vis.events.INIT, function()
    -- options:
    vis:command('set expandtab on')
    vis:command('set tabwidth 4')
    vis:command('set autoindent on')
    vis:command('set theme mellow')
    local handle = io.popen('theme -q')
    local theme = handle:read()
    if theme == "dark" then
        vis:command('set mellow_dark true')
    else
        vis:command('set mellow_dark false')
    end

    local _normal = vis.modes.NORMAL
    local _insert = vis.modes.INSERT
    local _replace = vis.modes.REPLACE
    local _visual = vis.modes.VISUAL
    local _vline = vis.modes.VISUAL_LINE
    local _pending = vis.modes.OPERATOR_PENDING

    -- Meta mappings:
    vis:map(_normal, '<M-;>', '<Escape>')
    vis:map(_insert, '<M-;>', '<Escape><Escape>')
    vis:map(_replace, '<M-;>', '<Escape>')
    vis:map(_visual, '<M-;>', '<Escape>')
    vis:map(_vline, '<M-;>', '<Escape>')
    vis:map(_pending, '<M-;>', '<Escape>')
    vis:map(_insert, '<M-Enter>', '<C-n>')
    vis:map(_normal, '<M-j>', '<C-w>j')
    vis:map(_normal, '<M-k>', '<C-w>k')
    vis:map(_normal, '<M-f>', ':fzf<Enter>')

    -- whitespace padding/stripping
    vis:map(_normal, ' o', 'o<Escape>') -- TODO: allow repeating
    vis:map(_normal, ' O', 'O<Escape>') -- TODO: allow repeating
    vis:map(_normal, '<Backspace>', 'gs:x/ +$/ c//<Enter>g<')
    vis:map(_insert, '<S-Tab>', string.rep('<Backspace>', 4))

    -- quicker clipboard copy/paste
    vis:map(_normal, ' p', '"+p')
    vis:map(_normal, ' y', '"+y')
    vis:map(_visual, ' p', '"+p')
    vis:map(_visual, ' y', '"+y')
    vis:map(_vline, ' p', '"+p')
    vis:map(_vline, ' y', '"+y')
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    vis:command('set show-tabs on')
    vis:command('set relativenumbers on')
    vis:command('set ignorecase on')
    vis:command('set colorcolumn 88')
end)