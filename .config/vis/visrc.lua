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
-- <https://github.com/lutobler/vis-commentary>
require('plugins/vis-commentary')
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
    local truecolor = os.getenv("COLORTERM")
    local nvim = os.getenv("NVIM")
    local has_theme = os.execute("command -v theme")
    if has_theme then
        do
            local theme = io.popen('theme -q')
            if term ~= "linux" and truecolor == "truecolor" and nvim == nil then
                vis:command('set theme mellow')
                if theme:read() == "dark" then
                    vis:command('set mellow_dark true')
                else
                    vis:command('set mellow_dark false')
                end
            elseif theme:read() == "light" then
                vis:command('set theme light-16')
            else
                vis:command('set theme default-16')
            end
            theme:close()
        end
    else
        vis:command('set theme default-16')
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
    vis:map(_normal, '<M-;>', '<vis-mode-normal-escape>')
    vis:map(_insert, '¶', '<vis-mode-normal>')
    vis:map(_insert, '<M-;>', '<vis-mode-normal>')
    vis:map(_insert, '<C-c>', '<Escape><Escape>')
    vis:map(_replace, '¶', '<vis-mode-normal>')
    vis:map(_replace, '<M-;>', '<vis-mode-normal>')
    vis:map(_visual, '¶', '<vis-mode-normal>')
    vis:map(_visual, '<M-;>', '<vis-mode-normal>')
    vis:map(_vline, '¶', '<vis-mode-normal>')
    vis:map(_vline, '<M-;>', '<vis-mode-normal>')
    vis:map(_pending, '¶', '<vis-mode-normal-escape>')
    vis:map(_pending, '<M-;>', '<vis-mode-normal-escape>')
    vis:map(_normal, 'ï', '<vis-window-next>')
    vis:map(_normal, '<M-j>', '<vis-window-next>')
    vis:map(_normal, 'œ', '<vis-window-prev>')
    vis:map(_normal, '<M-k>', '<vis-window-prev>')

    -- Better command mode and jump repeat mappings.
    vis:map(_normal, ';', '<vis-prompt-show>')
    vis:map(_normal, 's', '<vis-motion-totill-repeat>')

    -- Leave a few lines buffer after zb or zt, #999:
    vis:map(_normal, 'gb', 'zb3<C-e>')
    vis:map(_normal, 'gt', 'zt3<C-y>')

    -- Insert-mode macros:
    vis:map(_insert, '<C-f>', fzf_unicode.action)

    -- Command mappings:
    vis:map(_normal, ' w', ':w<Enter>')
    vis:map(_normal, ' n', ':set relativenumbers!<Enter>')
    vis:map(_normal, ' t', ':set mellow_dark!<Enter>')
    vis:map(_normal, ' f', ':fzf<Enter>')
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
    -- Navigating to sentence clause punctuation:
    vis:map(_normal, 'g(', '?[.,;:!?]( |\n)<Enter>')
    vis:map(_normal, 'g)', '/[.,;:!?]( |\n)<Enter>')
    vis:map(_visual, 'g(', '?[.,;:!?]( |\n)<Enter>')
    vis:map(_visual, 'g)', '/[.,;:!?]( |\n)<Enter>')
    -- Whitespace stripping:
    vis:map(_normal, '<Backspace>', "''m:x/ +$/ c//<Enter>M")
    -- Reload current file from disk:
    vis:map(_normal, 'gr', ':e!<Enter>')
    -- Open URL in browser:
    vis:map(_normal, 'gx', function()
        local pos = vis.win.selection.col
        local str = vis.win.file.lines[vis.win.selection.line]
        local len = string.len(str)
        local URLchars = '[^a-zA-Z0-9%?._=+;&/:@#-]'
        local to = str:find(URLchars, pos)
        if to == nil then to = len else to = to - 1 end
        local from = str:reverse():find(URLchars, len - pos + 1)
        if from == nil then from = 1 else from = len - from + 2 end
        local URL = str:sub(from, to)
        os.execute("setsid xdg-open '" .. URL .. "'")
        vis:redraw()
    end, "Open URL under cursor in browser")

    -- Fat finger command aliases:
    vis:command_register("New", function(argv, force, win, selection, range)
        vis:command('new')
    end, "Alias for :new")
    vis:command_register("Vnew", function(argv, force, win, selection, range)
        vis:command('vnew')
    end, "Alias for :vnew")
    vis:command_register("Split", function(argv, force, win, selection, range)
        vis:command('split ' .. table.concat(argv, ' '))
    end, "Alias for :split")
    vis:command_register("Vsplit", function(argv, force, win, selection, range)
        vis:command('vsplit ' .. table.concat(argv, ' '))
    end, "Alias for :vsplit")
end)


------ Default window settings ------
vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    vis:command('set show-tabs on')
    vis:command('set relativenumbers on')
    vis:command('set ignorecase on')
    vis:command('set colorcolumn 88')
end)
