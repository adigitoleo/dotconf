-- CONFIGURATION FILE FOR THE VIS EDITOR
-- <https://github.com/martanne/vis>

-- https://github.com/martanne/vis/wiki/Plugins
require('vis')

-- <https://git.sr.ht/~emg/vis-jumplist>
require('plugins/vis-jumplist')
-- <https://git.sr.ht/~emg/vis-cscope>
-- Currently testing the 'jumplist' branch for inverse :cs pop command.
require('plugins/vis-cscope')
-- <https://github.com/fischerling/vis-spellcheck>
require('plugins/vis-spellcheck')
-- <https://github.com/erf/vis-cursors>
require('plugins/vis-cursors')
-- <https://gitlab.com/mcepl/vis-jump>
require('plugins/vis-jump')
-- <https://repo.or.cz/vis-pairs.git>
local pairs = require('plugins/vis-pairs')
pairs.autopairs = false
-- <https://repo.or.cz/vis-surround.git>
require('plugins/vis-surround')
-- <https://github.com/ingolemo/vis-smart-backspace>
local smart_backspace = require('plugins/vis-smart-backspace')
smart_backspace.tab_width = 4
-- <https://git.sr.ht/~mcepl/vis-fzf-open>
local fzf_open = require('plugins/vis-fzf-open')
fzf_open.fzf_args = "--height=33%"
-- <https://git.sr.ht/~adigitoleo/vis-fzf-unicode>
local fzf_unicode = require('plugins/vis-fzf-unicode')
fzf_unicode.fzf_args = "--height=33%"


-- Set theme (dark/light) based on external command.
function set_theme()
    local term = os.getenv("TERM")
    local has_theme = os.execute("command -v theme")
    if term ~= "linux" and has_theme then
        do
            vis:command('set theme mellow')
            local theme = io.popen('theme -q')
            if theme:read() == "dark" then
                vis:command('set mellow_dark true')
            else
                vis:command('set mellow_dark false')
            end
            theme:close()
        end
    end
end


------ Startup settings ------
vis.events.subscribe(vis.events.INIT, function()
    -- Options:
    vis:command('set expandtab on')
    vis:command('set tabwidth 4')
    vis:command('set autoindent on')
    set_theme()

    -- Mapping modes:
    local _normal = vis.modes.NORMAL
    local _insert = vis.modes.INSERT
    local _replace = vis.modes.REPLACE
    local _visual = vis.modes.VISUAL
    local _vline = vis.modes.VISUAL_LINE
    local _pending = vis.modes.OPERATOR_PENDING

    -- Meta mappings:
    vis:map(_normal, '¶', '<vis-mode-normal-escape>')
    vis:map(_insert, '¶', '<vis-mode-normal>')
    vis:map(_insert, '<C-c>', '<Escape><Escape>')
    vis:map(_replace, '¶', '<vis-mode-normal>')
    vis:map(_visual, '¶', '<vis-mode-normal>')
    vis:map(_vline, '¶', '<vis-mode-normal>')
    vis:map(_pending, '¶', '<vis-mode-normal-escape>')
    vis:map(_normal, 'ï', '<vis-window-next>')
    vis:map(_normal, 'œ', '<vis-window-prev>')

    -- Command mappings:
    vis:map(_normal, ' w', ':w<Enter>')
    vis:map(_normal, ' n', ':set relativenumbers!<Enter>')
    vis:map(_normal, ' d', ':set mellow_dark!<Enter>')
    vis:map(_normal, ' f', ':fzf<Enter>')
    vis:map(_normal, ' u', ':fzf-unicode<Enter>')
    vis:map(_normal, ' c', ':set ignorecase!<Enter>')
    vis:map(_normal, ' x', function(keys)
        local word = vis.win.file:text_object_word(vis.win.selection.pos)
        if word then
            vis:feedkeys(":x/\\<" .. vis.win.file:content(word) .. "\\>")
        end
    end, "Pre-fill command prompt with pattern to select all matches of word under cursor")

    -- Quicker clipboard copy/paste:
    vis:map(_normal, ' p', '"+p')
    vis:map(_normal, ' y', '"+y')
    vis:map(_visual, ' p', '"+p')
    vis:map(_visual, ' y', '"+y')
    vis:map(_vline, ' p', '"+p')
    vis:map(_vline, ' y', '"+y')
    -- Alternative jumplist navigation:
    vis:map(_normal, 'H', '<vis-jumplist-prev>')
    vis:map(_normal, 'L', '<vis-jumplist-next>')
    -- Navigating to sentence clause punctuation:
    vis:map(_normal, 'g(', '?[.,;:!?]( |\n)<Enter>')
    vis:map(_normal, 'g)', '/[.,;:!?]( |\n)<Enter>')
    vis:map(_visual, 'g(', '?[.,;:!?]( |\n)<Enter>')
    vis:map(_visual, 'g)', '/[.,;:!?]( |\n)<Enter>')
    -- Whitespace padding/stripping:
    vis:map(_normal, '<Backspace>', "''m:x/ +$/ c//<Enter>M")
    -- Reload current file from disk:
    vis:map(_normal, 'gr', ':e!<Enter>')
end)


------ Default window settings ------
vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    vis:command('set show-tabs on')
    vis:command('set relativenumbers on')
    vis:command('set ignorecase on')
    vis:command('set colorcolumn 88')
end)
