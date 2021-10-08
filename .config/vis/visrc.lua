require('vis')
-- https://github.com/martanne/vis/wiki/Plugins

require('plugins/cscope')
-- PKGBUILD is in AUR, upstream is <https://git.sr.ht/~emg/vis-cscope>
--      :cs <letter> <word> for explicit searches of <word>
--      <C-/><letter> to search for the word under the cursor
--      <letter> can be 's', 'g', 'd', 'c', 't', 'e', 'f', 'i', or 'a',
--      which match the 0-9 options in cscope

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

local smart_backspace = require('plugins/vis-smart-backspace')
smart_backspace.tab_width = 4
-- PKGBUILD is in AUR, upstream is <https://github.com/ingolemo/vis-smart-backspace>
--      requires explicit tab width setting (default is 8):
--      smart_backspace = require('plugins/vis-smart-backspace')
--      smart_backspace.tab_width = 4

local fzf_open = require('plugins/fzf-open')
fzf_open.fzf_args = "--height=33%"
-- PKGBUILD is in AUR, upstream is <https://git.sr.ht/~mcepl/vis-fzf-open>
--      :fzf to search all files in the current sub-tree
--      accepts normal fzf arguments, e.g. :fzf -p !.class
--      <Enter> to open file, or <C-s> and <C-v> for horizontal/vertical splits

local fzf_unicode = require('plugins/vis-fzf-unicode')
fzf_unicode.fzf_args = "--height=33%"


vis.events.subscribe(vis.events.INIT, function()
    -- options:
    vis:command('set expandtab on')
    vis:command('set tabwidth 4')
    vis:command('set autoindent on')
    local input = io.popen('printf "%s" "$TERM"')
    local term = input:read()
    if term ~= "linux" then
        do
            vis:command('set theme mellow')
            local input = io.popen('theme -q')
            local theme = input:read()
            if theme == "dark" then
                vis:command('set mellow_dark true')
            else
                vis:command('set mellow_dark false')
            end
        end
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
    vis:map(_insert, '<M-w>', '<Escape><Escape>:w<Enter>i')
    vis:map(_replace, '<M-;>', '<Escape>')
    vis:map(_visual, '<M-;>', '<Escape>')
    vis:map(_vline, '<M-;>', '<Escape>')
    vis:map(_pending, '<M-;>', '<Escape>')
    vis:map(_normal, '<M-j>', '<C-w>j')
    vis:map(_normal, '<M-k>', '<C-w>k')
    vis:map(_normal, '<M-n>', ':set relativenumbers!<Enter>')
    vis:map(_normal, '<M-m>', ':set mellow_dark!<Enter>')
    vis:map(_normal, '<M-f>', ':fzf<Enter>')
    vis:map(_normal, '<M-a>', ':fzf-unicode<Enter>')

    -- whitespace padding/stripping
    vis:map(_normal, ' o', 'o<Escape>') -- TODO: allow repeating
    vis:map(_normal, ' O', 'O<Escape>') -- TODO: allow repeating
    vis:map(_normal, '<Backspace>', "''m:x/ +$/ c//<Enter>M")

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
