require('vis')
-- https://github.com/martanne/vis/wiki/Plugins

local spellcheck = require('plugins/spellcheck')
-- PKGBUILD is in AUR, upstream is <https://github.com/fischerling/vis-spellcheck>
--      <C-w>e to enable highlighting of bad spelling
--      <C-w>d to disable highlighting of bad spelling
--      <C-w>w to suggest spelling corrections

local pairs = require('plugins/pairs')
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

    -- mappings:
    vis:map(vis.modes.NORMAL, '<M-;>', '<Escape>')
    vis:map(vis.modes.INSERT, '<M-;>', '<Escape><Escape>')
    vis:map(vis.modes.REPLACE, '<M-;>', '<Escape>')
    vis:map(vis.modes.VISUAL, '<M-;>', '<Escape>')
    vis:map(vis.modes.VISUAL_LINE, '<M-;>', '<Escape>')
    vis:map(vis.modes.OPERATOR_PENDING, '<M-;>', '<Escape>')
    vis:map(vis.modes.INSERT, '<M-Enter>', '<C-n>')
    vis:map(vis.modes.NORMAL, '<M-j>', '<C-w>j')
    vis:map(vis.modes.NORMAL, '<M-k>', '<C-w>k')

    -- TODO: Make these robust (allow repeating with . or a count, etc.)
    vis:map(vis.modes.NORMAL, ' o', 'o<Escape>')
    vis:map(vis.modes.NORMAL, ' O', 'O<Escape>')
    vis:map(vis.modes.NORMAL, '<M-f>', ':fzf<Enter>')

    vis:map(vis.modes.NORMAL, ' p', '"+p')
    vis:map(vis.modes.NORMAL, ' y', '"+y')
    vis:map(vis.modes.VISUAL, ' p', '"+p')
    vis:map(vis.modes.VISUAL, ' y', '"+y')
    vis:map(vis.modes.VISUAL_LINE, ' p', '"+p')
    vis:map(vis.modes.VISUAL_LINE, ' y', '"+y')
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    vis:command('set show-tabs on')
    vis:command('set relativenumbers on')
    vis:command('set ignorecase on')
    vis:command('set colorcolumn 88')
end)
