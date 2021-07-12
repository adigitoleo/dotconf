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
    vis:command('set theme mellow')
    local handle = io.popen('theme -q')
    local theme = handle:read()
    if theme == "dark" then
        vis:command('set mellow_dark true')
    else
        vis:command('set mellow_dark false')
    end

    -- mappings:
    vis:command('map normal <M-;> <Escape>')
    vis:command('map insert <M-;> <Escape>')
    vis:command('map replace <M-;> <Escape>')
    vis:command('map visual <M-;> <Escape>')
    vis:command('map visual-line <M-;> <Escape>')
    vis:command('map operator-pending <M-;> <Escape>')
    vis:command('map insert <M-Enter> <C-n>')
    vis:command('map normal <M-j> <C-w>j')
    vis:command('map normal <M-k> <C-w>k')
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    vis:command('set show-tabs on')
    vis:command('set relativenumbers on')
    vis:command('set colorcolumn 88')
end)
