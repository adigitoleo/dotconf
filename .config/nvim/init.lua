-- *** NeoVim 0.8+ configuration file ***
local api = vim.api
local opt = vim.opt
local fn = vim.fn
local command = api.nvim_create_user_command
local bindkey = vim.keymap.set
local system = vim.loop.os_uname().sysname
if system == "Windows_NT" then
    vim.o.shell = "pwsh"
    _lsep = [[`n]]
    _printf = "pwsh.exe -c echo" -- Extra pwsh.exe nesting ensures laziness?
    _preview = false
else
    _lsep = [[\n]]
    _printf = "printf"
    _preview = true
end

local function warn(msg) api.nvim_err_writeln("init.lua: " .. msg) end

-- Enable unicode input and markdown fenced block highlighting for:
local freqlangs = {
    "c", "cpp", "python", "julia", "nim", "sh", "conf", "css", "go", "json",
    "lua", "rust", "strace", "toml", "yaml", "openscad", "tex", "hare",
    "racket", "pollen", "html", "txr", "tl"
} -- Unicode input will additionally be enabled in the "markdown" filetype.

-- Turn off optional Python, Ruby, Perl and NodeJS support for faster startup.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Get list of open ("listed", or "loaded" if all is true) buffer IDs.
function list_bufs(all)
    local bufs = {}
    for i, buf in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_is_loaded(buf) then
            if all then
                bufs[i] = buf
            else
                if vim.bo[buf].buflisted then
                    table.insert(bufs, buf)
                end
            end
        end
    end
    return bufs
end

-- Get list of open ("listed", or "loaded" if all is true) buffer names.
function list_buf_names(all)
    local buffer_names = {}
    for _, buf in pairs(list_bufs(all)) do
        table.insert(buffer_names, api.nvim_buf_get_name(buf))
    end
    return buffer_names
end

-- Generate filtered list of file names from given sources, omitting current file name.
function list_files(sources, mods, sep)
    -- source: table of sources, each field is a sub-table of file names.
    -- mods: string of filters to use, see :h filename-modifiers and :h fnamemodify().
    -- sep: string, separator to insert between file names.

    local ignore = { vim.env.VIMRUNTIME }            -- Ignore internal (neo)vim files.
    table.insert(ignore, "/nvim/runtime/doc/")       -- Ignore neovim helpfiles.
    for _, pattern in pairs(opt.wildignore:get()) do -- Respect 'wildignore'.
        pattern, _ = string.gsub(pattern, "*", "")   -- Remove glob signs, not used here.
        table.insert(ignore, pattern)
    end
    local thisfilename = fn.expand("%" .. mods) -- Ignore current file name if any.
    if fn.strchars(thisfilename) > 0 then table.insert(ignore, thisfilename) end

    local files = {} -- Deduplicated list of files from given sources.
    for _, source in pairs(sources) do
        for _, file in pairs(source) do
            file = fn.fnamemodify(file, mods)
            if fn.strchars(file) > 0 and fn.filereadable(file) > 0 then
                local match = false
                for _, pattern in pairs(ignore) do
                    if file:match(pattern) then
                        match = true
                        break
                    end
                end
                if not match and fn.count(files, file) == 0 then
                    table.insert(files, file)
                end
            end
        end
    end
    return table.concat(files, sep)
end

-- Generate list of open terminals, omitting focused terminal.
function list_terminals(sep)
    -- sep: string, separator to insert between file names.
    if system == "Windows_NT" then return "" end -- FIXME: Broken on Win11, needs more work.
    local terminals = {}
    -- Ignore current (focused) terminal buffer if any.
    local thisfilename = fn.expand("%")
    for _, name in pairs(list_buf_names(true)) do
        if name:match("term://", 1, true) then
            if name:match(thisfilename) then break end
            table.insert(terminals, name)
        end
    end
    return table.concat(terminals, sep)
end

-- Generate list of (most?) builtin and user/plugin-defined commands.
function list_commands(sep)
    -- sep: string, separator to insert between file names.
    local cmdlist = {}
    for _, line in pairs(fn.readfile(fn.expand("$VIMRUNTIME/doc/index.txt", 1))) do
        local match = line:match("^|:(%w+)|")
        if match then table.insert(cmdlist, match) end
    end

    -- Get user/plugin defined commands from `:command`.
    local com = fn.split(fn.execute("command"), [[\n]])
    for i, line in pairs(com) do
        repeat
            if i == 1 then break end -- First element is 'Name' from :command header.
            local match = line:match("^%W%W%W%W(%w+)%s")
            if match then table.insert(cmdlist, match) end
            break
        until true
    end
    return table.concat(cmdlist, sep)
end

function list_filetypes() -- List all known filetypes.
    filetypes = {}
    for _, ft in pairs(fn.split(fn.expand("$VIMRUNTIME/ftplugin/*.vim"))) do
        table.insert(filetypes, fn.fnamemodify(ft, ":t:r"))
    end
    return filetypes
end

function list_syntax() -- List all known syntax files.
    syntax = {}
    for _, sx in pairs(fn.split(fn.expand("$VIMRUNTIME/syntax/*.vim"))) do
        table.insert(syntax, fn.fnamemodify(sx, ":t:r"))
    end
    return syntax
end

function neat_foldtext() -- Simplified, cleaner foldtext.
    local patterns = {
        "%s?{{{%d?",     -- Remove default fold markers, see :h foldmarker.
        '"""',           -- Remove triple-quotes (Python docstring syntax).
    }
    -- Make 'commentstring' into a more robust pattern and remove comment characters.
    local commentstring = string.gsub(opt.commentstring:get(), "%s", "%s?%%s")
    for _, v in pairs(fn.split(commentstring, "%s")) do
        table.insert(patterns, v)
    end
    local headerline = fn.getline(vim.v.foldstart)
    for _, pattern in pairs(patterns) do
        headerline = headerline:gsub(pattern, "")
    end
    -- Add a space at the end before optional fill chars.
    local foldtext = { string.rep("+ ", fn.foldlevel(vim.v.foldstart)), headerline, " " }
    return table.concat(foldtext)
end

-- Allow continuous horizontal scrolling with 'z' + {'h', 'l', 'H' or 'L'}.
local function horizontal_scroll_mode(scrolltype)
    -- scrolltype: string, a letter (as above), see `:h scroll-horizontal`.
    -- <https://stackoverflow.com/a/59950870/12519962>
    if vim.wo.wrap then
        return
    end

    vim.cmd("echohl Title")
    local key = scrolltype
    while fn.index({ "h", "l", "H", "L" }, key) >= 0 do
        vim.cmd("normal! z" .. key)
        vim.cmd("redrawstatus")
        vim.cmd("echon '" .. "-- Horizontal scrolling mode (h/l/H/L)'")
        key = fn.nr2char(fn.getchar())
    end
    vim.cmd("echohl None|echo ''|redrawstatus")
end

-- Open new split and choose vertical or horizontal layout automatically.
local function smart_split(opts)
    local bufname = opts.args
    prefix = ""
    if fn.winwidth(0) > 160 then prefix = "vert" end
    vim.cmd(prefix .. " sbuffer " .. bufname)
end

-- Convert line or range to Title Case or Sentence case.
local function convert_case(opts)
    local range = "." -- Current line by default.
    local cmdparts = { ":silent! keeppatterns " }
    if opts.range == 2 then range = opts.line1 .. "," .. opts.line2 end
    table.insert(cmdparts, range)

    if opts.name == "TitleCase" then
        table.insert(cmdparts, [[s/\v(.*)/\L\1/|]])
        table.insert(cmdparts, range)
        table.insert(cmdparts, [[s/\v<(\a)(\a{3,})/\u\1\L\2/g]])
    elseif opts.name == "SentenceCase" then
        table.insert(cmdparts, [[s/\v(.*)/\L\1/|]])
        table.insert(cmdparts, range)
        table.insert(cmdparts, [[s/\v<(\a)(\a*)/\u\1\L\2/]])
    end
    table.insert(cmdparts, "|nohlsearch")
    vim.cmd(table.concat(cmdparts))
end

-- Copy file contents, name, path or directory to clipboard.
local function copy_file()
    local msg = "Copy to clipboard:"
    local prompt = "&Contents\n&Path\n&File name\n&Directory\n&Quit"
    local choice = fn.confirm(msg, prompt)

    if choice == 1 then
        vim.cmd [[silent call execute('%yank "')]]
    elseif choice == 2 then
        vim.cmd [[let @+=expand('%:p')]]
    elseif choice == 3 then
        vim.cmd [[let @+=expand('%:t')]]
    elseif choice == 4 then
        vim.cmd [[let @+=expand('%:p:h')]]
    end
    vim.print(fn.getreg())
end

local function rename_file() -- Rename current buffer and associated file.
    local old_name = fn.expand("%")
    local new_name = fn.input("New file name: ", old_name)
    if new_name ~= "" and new_name ~= old_name then
        vim.cmd.saveas(new_name)
        vim.cmd("silent !rm " .. old_name)
        vim.cmd("silent bdelete " .. old_name)
        vim.cmd [[redraw!]]
    end
end

-- Open or focus floating window and set {buf|file}type.
local function floating(buf, win, bt, ft)
    -- buf: possibly existing buffer
    -- win: possibly existing window
    -- bt: desired buftype
    -- ft: desired filetype
    local wc = vim.o.columns
    local wl = vim.o.lines
    local width = math.ceil(wc * 0.8)
    local height = math.ceil(wl * 0.8 - 4)
    if not api.nvim_buf_is_valid(buf) then
        buf = api.nvim_create_buf(true, false)
    end
    api.nvim_buf_set_option(buf, "buftype", bt)
    api.nvim_buf_set_option(buf, "filetype", ft)
    if not api.nvim_win_is_valid(win) then
        win = api.nvim_open_win(buf, true, {
            border = "single",
            relative = "editor",
            style = "minimal",
            width = width,
            height = height,
            col = math.ceil((wc - width) * 0.5),
            row = math.ceil((wl - height) * 0.5 - 1)
        })
    end
    return buf, win
end

-- Global booleans.
opt.confirm = true
opt.ignorecase = true
opt.incsearch = false
opt.infercase = true
opt.linebreak = true
opt.list = true
opt.showmode = false
opt.signcolumn = "yes"
opt.smartcase = true
opt.splitbelow = true
opt.splitright = true
opt.wrap = false

-- Global configs.
opt.tabstop = 4                -- Set indent size.
opt.softtabstop = -1           -- Use tabstop value to insert indents with <Tab>.
opt.shiftwidth = 0             -- Use tabstop value to shift indent level with '<<','>>'.
opt.shiftround = true          -- Round all indentation to multiples of tabstop value.
opt.expandtab = true           -- Use spaces for indentation by default.
opt.foldenable = false         -- Don't enable folding by default.
opt.foldclose = "all"          -- Allow all motions to automatically close folds.
opt.foldopen:remove("block")   -- Don't allow 'block' motions, e.g. '{','}' to open folds.
opt.fillchars = { fold = " " } -- Remove excessive fillchars for folds.
opt.foldtext = "v:lua.neat_foldtext()"
opt.spelllang = "en_au"
opt.spellfile = "~./config/nvim/after/spell/extras.en.utf-8.add"
opt.timeoutlen = 500
opt.clipboard:append("unnamedplus")
opt.matchpairs:append("<:>")
opt.shortmess:append({ c = true, I = true })
opt.shortmess:remove("F")
opt.formatoptions:remove("t")
opt.listchars:append({ trail = " ", precedes = "<", extends = ">" })
opt.pumheight = 15
opt.completeopt = { "menu", "noselect", "preview" }
opt.helpheight = 0
opt.synmaxcol = 200
opt.scrolloff = 3
opt.showbreak = "> "

-- Direct integration with external executables.
if fn.executable("rg") > 0 then opt.grepprg = "rg --vimgrep --smart-case --follow" end
if system == "Linux" then
    if fn.executable("wl-copy") > 0 and fn.executable("wl-paste") > 0 then
        vim.g.clipboard = {
            name = "Wayland primary selection",
            copy = { ["+"] = "wl-copy --type text/plain", ["*"] = "wl-copy --primary --type text/plain" },
            paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-copy --primary --no-newline" },
            cache_enabled = true,
        }
    else
        warn("could not set up system clipboard integration with wl-clipboard")
    end
end

-- Integration with fzf, <https://github.com/junegunn/fzf/blob/master/README-VIM.md>.
if fn.executable("fzf") > 0 and fn.exists(":FZF") then
    vim.g.fzf_layout = {
        window =
        { width = 0.9, height = 0.6, border = "sharp", highlight = "StatusLine" }
    }
    -- Generate spec for custom fuzzy finders.
    local function FZFspecgen(source, dir, preview, prompt)
        -- source: string, command to be executed as a source to FZF
        -- dir: string, if #dir > 0 this sets the directory in which to start FZF
        -- preview: bool, toggle file preview window (currently only works on Linux)
        -- prompt: FZF prompt message
        local options = { '--multi' }
        if preview then
            options = vim.list_extend(options, {
                '--preview',
                'case $(file {}) in *"text"*) head -200 {} ;; *) echo "Preview unavailable" ;; esac',
                '--preview-window',
                vim.o.columns > 120 and 'right:60%:sharp' or 'down:60%:sharp'
            })
        end
        table.insert(options, '--prompt')
        if prompt ~= nil then table.insert(options, prompt) else table.insert(options, dir .. ' ') end
        return {
            source = source,
            sink = 'e',
            dir = fn.substitute(fn.fnamemodify(dir, ':~'), '/*$', '/', ''),
            options = options
        }
    end

    local function _fuzzy_recent()
        local source = table.concat({
            _printf, ' "', list_files({ vim.v.oldfiles, list_buf_names(false) }, ":~:.", _lsep), '"'
        })
        fn["fzf#run"](fn["fzf#wrap"](FZFspecgen(source, "", _preview, "Recent files: ")))
    end
    command("FuzzyRecent", _fuzzy_recent, { desc = "Open recent files (v:oldfiles) or listed buffers" })

    if fn.executable("rg") > 0 then
        local function _fuzzy_find(opts)
            fn["fzf#run"](fn["fzf#wrap"](FZFspecgen('rg --files --hidden --no-messages', opts.args, _preview)))
        end
        command("FuzzyFind", _fuzzy_find,
            { nargs = "?", complete = "file", desc = "Open files from <dir> (or :pwd by default)" })
    else
        warn("ripgrep executable ('rg') not found, ripgrep features disabled")
    end

    local function _fuzzy_switch()
        local files = list_files({ list_buf_names(false) }, ":~:.", _lsep)
        local terms = list_terminals(_lsep)
        local source = nil
        if #files > 0 and #terms > 0 then
            source = table.concat({ _printf, ' "', files .. _lsep .. terms, '"' })
        elseif #files > 0 then
            source = table.concat({ _printf, ' "', files, '"' })
        elseif #terms > 0 then
            source = table.concat({ _printf, ' "', terms, '"' })
        end
        if source ~= nil then
            fn["fzf#run"](fn["fzf#wrap"](FZFspecgen(source, "", _preview, "Open buffers: ")))
        else
            warn("no buffers available")
        end
    end
    command("FuzzySwitch", _fuzzy_switch, { desc = "Switch between listed buffers or loaded `:terminal`s" })

    local function _fuzzy_cmd()
        local spec = {
            source = _printf .. ' "' .. list_commands(_lsep) .. '"',
            window = { width = 1, height = 0.4, xoffset = 0, yoffset = 1, border = 'top', highlight = 'StatusLine' },
            options = {
                '--no-multi',
                '--print-query',
                '--prompt', ':',
                '--color', 'prompt:-1',
                '--expect', ';,space,|,!', -- NOTE: --expect='!' broken on Win11, fzf 0.46.1
                '--layout', 'reverse-list'
            }
        }
        spec["sink*"] = function(fzf_out)
            if #fzf_out < 2 then return end
            local query = fzf_out[1]
            local key = fzf_out[2]
            local completion = fzf_out[3] ~= nil and fzf_out[3] or ''

            if #key == 0 then -- <Cr> pressed => execute completion
                -- NOTE: vim.cmd(completion) doesn't trigger TermOpen and swallows paged output from e.g. ':ls'.
                api.nvim_input(':' .. completion .. '<Cr>')
            elseif key == ';' then     -- ';' pressed => cancel completion
                api.nvim_input(':' .. query)
            elseif key == 'space' then -- '<space>' pressed => append space to completion
                api.nvim_input(':' .. completion .. ' ')
            else                       -- '!' or '|' pressed => append to completion, append trailing space
                api.nvim_input(':' .. completion .. key .. ' ')
            end
        end
        fn["fzf#run"](spec)
    end
    command("FuzzyCmd", _fuzzy_cmd, { desc = "Search for cmdline mode commands" })
else
    warn("fuzzy finder ('fzf') not found, disabling fzf features")
end

if fn.executable("theme") > 0 then
    command("ToggleTheme",
        [[silent! exec '!theme -t'|let &background = get(systemlist('theme -q'), 0, 'light')]],
        { desc = "Toggle global TUI theme using `!theme`" })
    command("SyncTheme", [[silent! let &background = get(systemlist('theme -q'), 0, 'light')]],
        { desc = "Sync to global TUI theme using `!theme`" })
end

-- User commands.
command("TitleCase", convert_case, { range = true, desc = "Change line/range to title case" })
command("SentenceCase", convert_case, { range = true, desc = "Change line/range to sentence case" })
command("StripTrails", [[silent! keeppatterns %s/\s\+$//e]], { desc = "Strip trailing whitespace" })
command("InsertDate", [[silent! exec 'normal! a' .. strftime('%Y-%m-%d') .. '<Esc>']],
    { desc = "Insert current date (ISO YYYY-MM-DD format)" })
command("SmartSplit", smart_split,
    { nargs = "?", bar = true, complete = "buffer", desc = "Smart buffer split based on terminal width" })
command("Vresize", [[exec 'vert resize' .. <q-args>]], { nargs = 1, desc = "Resize window vertically" })
command("CountWord", [[<line1>,<line2>s/\<<args>\>//gn]],
    { nargs = 1, range = "%", desc = "Count occurances of a word without moving cursor (supports `n`/`N`)" })
command("Grep", [[exec 'silent grep! <q-args>' | copen]],
    { nargs = "+", desc = "Like :grep but open quickfix list for match selection" })
command("BufGrep", [[exec 'silent grep! <q-args> ' .. join(v:lua.list_buf_names(v:false), ' ') | copen]],
    { nargs = "+", desc = "Like grep but search only in open buffers" })
command("Rename", rename_file, { desc = "Rename current buffer and associated file" })

-- Autocommands for terminal buffers and basic filetype settings.
vim.cmd [[augroup terminal_buffer_rules
    autocmd!
    autocmd TermOpen * setlocal nonumber norelativenumber signcolumn=no
    autocmd TermOpen * startinsert
    autocmd TermEnter * setlocal scrolloff=0
    autocmd BufEnter,WinEnter term://* startinsert | setlocal nobuflisted
augroup END]]

vim.filetype.add({ extension = { tikzstyles = "tex" } })
vim.filetype.add({ extension = { txr = "txr" } })
vim.filetype.add({ extension = { tl = "tl" } })

local filetype_rules = api.nvim_create_augroup("filetype_rules", { clear = true })
local function setl_ft_autocmd(filetypes, options)
    cmdparts = {}
    for k, v in pairs(options) do
        if type(v) == "boolean" then
            if v then table.insert(cmdparts, k) else table.insert(cmdparts, "no" .. k) end
        else
            table.insert(cmdparts, k .. "=" .. v)
        end
    end
    api.nvim_create_autocmd({ "FileType" }, {
        pattern = table.concat(filetypes, ","),
        group = filetype_rules,
        command = "setlocal " .. table.concat(cmdparts, " "),
    })
end
setl_ft_autocmd({ "bash", "sh" }, { foldmethod = "marker", textwidth = 100 })
setl_ft_autocmd({ "bib" }, { expandtab = false })
setl_ft_autocmd({ "cpp" }, { tabstop = 2, textwidth = 100 })
setl_ft_autocmd({ "css" }, { tabstop = 2 })
setl_ft_autocmd({ "desktop" }, { commentstring = "#\\ %s" })
setl_ft_autocmd({ "enaml" }, { textwidth = 88, filetype = "python.enaml" })
setl_ft_autocmd({ "fortran" }, { textwidth = 92 })
setl_ft_autocmd({ "gitconfig" }, { expandtab = false })
setl_ft_autocmd({ "help" }, { signcolumn = "no" })
setl_ft_autocmd({ "julia" }, { textwidth = 92 })
setl_ft_autocmd({ "make" }, { expandtab = false, textwidth = 79 })
setl_ft_autocmd({ "markdown" }, { textwidth = 79, foldlevel = 1, conceallevel = 2, synmaxcol = 500 })
setl_ft_autocmd({ "nim" }, { softtabstop = -1, shiftwidth = 0, commentstring = "#\\ %s", textwidth = 100 })
setl_ft_autocmd({ "openscad" }, { commentstring = "//\\ %s" })
setl_ft_autocmd({ "plaintex" }, { filetype = "tex" })
setl_ft_autocmd({ "pollen" }, { commentstring = "◊;\\ %s" })
setl_ft_autocmd({ "python" }, { textwidth = 88, foldmethod = "syntax" })
setl_ft_autocmd({ "qf" }, { number = true, relativenumber = false, cursorline = true, textwidth = 0 })
setl_ft_autocmd({ "sh", "zsh" }, { textwidth = 79 })
setl_ft_autocmd({ "tex" }, { textwidth = 0, wrap = true })
setl_ft_autocmd({ "txr" }, { commentstring = "@;\\ %s" })
setl_ft_autocmd({ "vim" }, { textwidth = 78, foldmethod = "marker", foldenable = true })
setl_ft_autocmd({ "xml", "html" }, { tabstop = 2, foldmethod = "indent" })
setl_ft_autocmd({ "yaml" }, { tabstop = 2 })

-- Miscellaneous autocommands.
vim.cmd [[augroup misc
    autocmd!
    autocmd BufWritePost * exec "normal! " .. &foldenable ? "zx" : ""
    autocmd VimEnter,BufWinEnter,FileType * let &colorcolumn = "+" .. join(range(&columns)[1:], ",+")
    autocmd InsertLeave,CompleteDone * silent! pclose
    autocmd VimResized * wincmd =
    autocmd TabEnter * stopinsert
    autocmd ColorScheme mellow hi link NormalFloat Normal
    autocmd ColorScheme mellow hi link FloatTitle FloatBorder
augroup END]]

-- Mappings. De gustibus: general fixes and tweaks.
-- Ergonomic, smart mode switches, with variants for us/intl-altgr keyboard.
bindkey("i", [[¶]], [[<Esc>]])
bindkey("i", [[<M-;>]], [[<Esc>]])
bindkey("n", [[;]], [[<Cmd>FuzzyCmd<Cr>]])
bindkey("x", [[;]], [[:]])
bindkey("x", [[¶]], [[<Esc>]])
bindkey("x", [[<M-;>]], [[<Esc>]])
bindkey("c", [[¶]], [[<C-c>]])
bindkey("c", [[<M-;>]], [[<C-c>]])
bindkey("t", [[°]], [[<C-\><C-n>]])
bindkey("t", [[<M-S-;>]], [[<C-\><C-n>]])
bindkey("n", [[q;]], [[q:]])
bindkey("n", [[Q]], [[<Nop>]])
-- Some shell-style improvements to command mode mappings.
bindkey("c", [[<C-p>]], [[<Up>]])
bindkey("c", [[<C-n>]], [[<Up>]])
bindkey("c", [[<C-a>]], [[<C-b>]])      -- Shadow default c_CTRL-A.
bindkey("n", [[Y]], [[y$]])             -- Make Y consistent with D and C.
bindkey("x", [[/]], [[<Esc>/\%V]], { desc = "Search in selection" })
bindkey("n", [[yu]], [[<Cmd>redo<Cr>]]) -- Redo (can't use U, see :h U).
-- Make CTRL-L also clear search highlighting.
bindkey("n", [[<C-l>]], [[<Cmd>nohlsearch<Cr><C-l>]], { silent = true })
-- Tap space to clear messages.
bindkey("n", [[<Space>]], [[<Cmd>mode<Cr>]], { silent = true })
-- Disable middle mouse paste.
bindkey("n", [[<MiddleMouse>]], [[<Nop>]])
bindkey("n", [[<2-MiddleMouse>]], [[<Nop>]])
bindkey("n", [[<3-MiddleMouse>]], [[<Nop>]])
bindkey("n", [[<4-MiddleMouse>]], [[<Nop>]])
-- HorizontalScrollMode allows continuous scrolling with the indicated char.
bindkey("n", [[zh]], function() horizontal_scroll_mode('h') end, { silent = true })
bindkey("n", [[zl]], function() horizontal_scroll_mode('l') end, { silent = true })
bindkey("n", [[zH]], function() horizontal_scroll_mode('H') end, { silent = true })
bindkey("n", [[zL]], function() horizontal_scroll_mode('L') end, { silent = true })

-- Meta mappings: buffer navigation and control.
-- Window navigation and relocation, with variants for us/intl-altgr keyboard.
bindkey("n", [[ï]], [[<Cmd>wincmd w<Cr>]])
bindkey("n", [[<M-j>]], [[<Cmd>wincmd w<Cr>]])
bindkey("n", [[œ]], [[<Cmd>wincmd W<Cr>]])
bindkey("n", [[<M-k>]], [[<Cmd>wincmd W<Cr>]])
bindkey("n", [[ñ]], [[<Cmd>wincmd n<Cr>]])
bindkey("n", [[<M-n>]], [[<Cmd>wincmd n<Cr>]])
bindkey("n", [[ö]], [[<Cmd>wincmd p<Cr>]])
bindkey("n", [[<M-p>]], [[<Cmd>wincmd p<Cr>]])
-- Tab navigation, ditto.
bindkey("n", [[Ï]], [[<Cmd>tabnext<Cr>]])
bindkey("t", [[Ï]], [[<Cmd>tabnext<Cr>]])
bindkey("n", [[<M-J>]], [[<Cmd>tabnext<Cr>]])
bindkey("t", [[<M-J>]], [[<Cmd>tabnext<Cr>]])
bindkey("n", [[Œ]], [[<Cmd>tabprev<Cr>]])
bindkey("t", [[Œ]], [[<Cmd>tabprev<Cr>]])
bindkey("n", [[<M-K>]], [[<Cmd>tabprev<Cr>]])
bindkey("t", [[<M-K>]], [[<Cmd>tabprev<Cr>]])
-- Fold navigation improvement.
bindkey("n", [[zj]], [[zjzt]])
bindkey("n", [[zk]], [[zkzb]])
-- Quicker history jumps (consistent with qutebrowser, etc.).
bindkey("n", [[H]], [[<C-o>]])
bindkey("n", [[L]], [[<C-i>]])
-- Coarse scrolling, also inspired by web browsers.
bindkey("n", [[[<Space>]], [[<C-u>]])
bindkey("n", [[]<Space>]], [[<C-d>]])
-- Better mapping for :tjump, clobbers :tselect.
bindkey("n", "g]", [[g<C-]>]])
-- Jump to first/last character of current line.
bindkey("", "]l", [[g_]])
bindkey("", "[l", [[^]])

-- Leader mappings: run commands and call functions.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

bindkey("n", [[<Leader>b]], [[<Cmd>FuzzySwitch<Cr>]], { desc = "Launch buffer switcher" })
bindkey("n", [[<Leader>c]], [[<Cmd>set cursorcolumn!<Cr>]], { desc = "Toggle cursorcolumn" })
bindkey("n", [[<Leader>f]], [[<Cmd>FuzzyFind<Cr>]], { desc = "Launch file browser" })
bindkey("n", [[<Leader>h]], [[<Cmd>setlocal foldenable!<Cr>]], { desc = "Toggle folding (buffer-local)" })
bindkey("n", [[<Leader>l]], [[<Cmd>set cursorline!<Cr>]], { desc = "Toggle cursorline" })
bindkey("n", [[<Leader>m]], [[<Cmd>make!<Cr>]], { desc = "Run make! (doesn't jump to errorfile)" })
-- Toggle line numbers for focused buffer.
bindkey("n", [[<Leader>n]], [[<Cmd>set number! relativenumber!<Cr>]], { silent = true })
-- Paste last yanked text ignoring cut text.
bindkey("", [[<Leader>p]], [["0p]])
bindkey("", [[<Leader>P]], [["0P]])
bindkey("n", [[<Leader>r]], [[<Cmd>FuzzyRecent<Cr>]], { desc = "Launch recent file browser" })
-- Toggle spell checking in current buffer.
bindkey("n", [[<Leader>s]], [[<Cmd>setlocal spell!<Cr>]], { silent = true })
-- Sync theme to system, using `theme -q` (Linux only).
bindkey("n", [[<Leader>t]], [[<Cmd>SyncTheme<Cr>]], { silent = true })
-- Write focused buffer if modified.
bindkey("n", [[<Leader>w]], [[<Cmd>up<Cr>]], { silent = true })
-- Copy file contents, name or path to clipboard.
bindkey("n", [[<Leader>y]], function() copy_file() end, { silent = true })
-- Toggle soft-wrapping of long lines to the view width.
bindkey("n", [[<Leader>z]], [[<Cmd>setlocal wrap!<Cr>]], { silent = true })
-- Attempt to autoformat focused paragraph/selection.
bindkey("n", [[<Leader>\]], [[gwip]], { silent = true })
bindkey("x", [[<Leader>\]], [[gw]], { silent = true })
-- Convenient cmdline mode prefixes.
bindkey("n", [[<Leader>/]], [[:%s/<C-r><C-w>/]])
bindkey("x", [[<Leader>/]], [[:s/]])
bindkey("n", [[<Leader>;]], [[:!]])

-- Plugin setup and configuration.
if system ~= "Windows_NT" then vim.g.markdown_fenced_languages = freqlangs end
vim.g.markdown_folding = 1
vim.g.rst_use_emphasis_colors = 1
vim.g.rst_fold_enabled = 1
vim.g.fortran_more_precise = 1
vim.g.fortran_free_source = 1

local function load(plugin)
    local has_plugin, out = pcall(require, plugin)
    if has_plugin then
        return out
    else
        warn("failed to load plugin '" .. plugin .. "'")
        return nil
    end
end

local function bootstrap()
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end
local packer_bootstrap = bootstrap()

require("packer").startup(function(use)
    use "wbthomason/packer.nvim"              -- Neovim plugin manager, uses :h packages.
    use "neovim/nvim-lsp"                     -- Community configs for :h lsp.
    use "numToStr/Comment.nvim"               -- Quickly comment/uncomment code.
    use "kylechui/nvim-surround"              -- Quoting/parenthesizing made simple.
    use "nvim-lua/plenary.nvim"               -- Lua functions/plugin dev library.
    use "whiteinge/diffconflicts"             -- 2-way vimdiff for merge conflicts (VimL).
    use "echasnovski/mini.map"                -- A code minimap, like what cool Atom kids have.
    use "lukas-reineke/indent-blankline.nvim" -- Visual indentation guides.
    use "folke/todo-comments.nvim"            -- Track TODO/FIXME comments.
    use "lewis6991/gitsigns.nvim"             -- Git status in sign column and statusbar.
    use "SidOfc/carbon.nvim"                  -- Replacement for :h netrw, directory viewer.
    use "ggandor/leap.nvim"                   -- Alternative to '/' for quick search/motions.
    use "numToStr/FTerm.nvim"                 -- Floating terminal using :h job-control.
    use "farmergreg/vim-lastplace"            -- Open files at the last viewed location (VimL).
    use "AndrewRadev/inline_edit.vim"         -- Edit embedded code in a temporary buffer with a different filetype
    -- Follow symlinks when opening files (Linux, VimL).
    use { "aymericbeaumet/vim-symlink", requires = { "moll/vim-bbye" } }

    use "dhruvasagar/vim-open-url"   -- Open URL's in browser without :h netrw (VimL).
    use "alvan/vim-closetag"         -- Auto-close (x|ht)ml tags (VimL).
    use "vim-python/python-syntax"   -- Improved Python syntax highlighting (VimL).
    use "hattya/python-indent.vim"   -- PEP8 auto-indenting for Python (VimL).
    use "euclidianAce/BetterLua.vim" -- Improved Lua syntax highlighting (VimL).
    use "jakemason/ouroboros"        -- Switch between .c/.cpp and header files.
    use "adigitoleo/vim-mellow"
    use "adigitoleo/vim-mellow-statusline"
    use "https://git.sr.ht/~adigitoleo/overview.nvim"

    if fn.executable("latex") > 0 then
        use "lervag/vimtex" -- Comprehensive LaTeX integration.
    end
    if fn.executable("julia") > 0 then
        use "JuliaEditorSupport/julia-vim" -- Improved Julia syntax highlighting, unicode input.
    end
    if fn.executable("racket") > 0 then
        use "otherjoel/vim-pollen" -- Syntax highlighting for #lang pollen
    end
    if system == "Windows_NT" or fn.executable("apt") then
        use "junegunn/fzf" -- Provides the basic fzf.vim file.
    end
    if packer_bootstrap then
        require("packer").sync()
    end
end)

local lsp = load("lspconfig")
if lsp then
    -- LSP mappings and autocommands.
    bindkey("n", "gl", vim.diagnostic.setloclist, { silent = true, desc = "Open LSP loclist" })
    bindkey("n", "]d", vim.diagnostic.goto_next, { silent = true, desc = "Go to next LSP hint" })
    bindkey("n", "[d", vim.diagnostic.goto_prev, { silent = true, desc = "Go to previous LSP hint" })
    -- To focus the hover buffer, press K a second time.
    api.nvim_create_autocmd("LspAttach", {
        group = api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
            vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
            bindkey("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Show LSP hover info" })
            bindkey("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Show LSP signature help" })
            bindkey("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
            bindkey("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
            bindkey("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "Find references to symbol" })
            bindkey("n", "gR", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })
            bindkey("n", "gf", function()
                vim.lsp.buf.format { async = true }
            end, { buffer = ev.buf, desc = "Run LSP formatter" })
        end,
    })
    -- Borders for LSP popup windows.
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
    vim.diagnostic.config { float = { border = "single" } }
    -- Requires pip install python-lsp-server (NOT python-language-server!).
    if fn.executable('pylsp') > 0 then
        lsp.pylsp.setup {
            settings = {
                pylsp = { plugins = { pycodestyle = { maxLineLength = 88 } } }
            }
        }
    end

    -- https://github.com/LuaLS/lua-language-server
    if fn.executable('lua-language-server') > 0 then
        lsp.lua_ls.setup {
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    diagnostics = {
                        globals = { 'vim' }, -- Recognize 'vim' global.
                        disable = { "lowercase-global" },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file("", true),
                        -- Silence weird luassert message,
                        -- https://github.com/LuaLS/lua-language-server/discussions/1688
                        checkThirdParty = false,
                    },
                    -- Do not send telemetry data!
                    telemetry = { enable = false },
                },
            },
        }
    end
end

-- Toggle comments and add/change/delete surrouning delimiters.
local comment = load("Comment")
if comment then comment.setup() end
local surround = load("nvim-surround")
if surround then surround.setup() end

-- Git signs and minimap.
local gitsigns = load("gitsigns")
if gitsigns then gitsigns.setup() end
local minimap = load("mini.map")
if minimap then
    minimap.setup({
        symbols = { encode = minimap.gen_encode_symbols.dot("3x2") },
        integrations = { minimap.gen_integration.gitsigns() },
        window = { width = 15, show_integration_count = false },
    })
    bindkey("n", "mf", minimap.toggle_focus, { desc = "Toggle minimap focus" })
    bindkey("n", "mr", minimap.refresh, { desc = "Refresh minimap" })
    bindkey("n", "gm", minimap.toggle, { desc = "Toggle minimap" })
end

-- TODO/FIXME comment tracker setup.
local todo_comments = load('todo-comments')
if todo_comments then
    todo_comments.setup({
        signs = false,
        colors = { error = { "DiagnosticWarn" } },
        highlight = { before = "bg", after = "" }
    })
    bindkey("n", "]t", function() todo_comments.jump_next() end, { desc = "Next todo comment" })
    bindkey("n", "[t", function() todo_comments.jump_prev() end, { desc = "Previous todo comment" })
end

-- Replacement for buggy netrw (vim8 directory viewer).
local carbon = load("carbon")
if carbon then
    carbon.setup()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
end

-- Floating windows/terminals.
local fterm = load("FTerm")
if fterm then
    fterm.setup({ blend = 30 })
    command("Term", function(opts)
        if opts.args ~= "" then
            ---@diagnostic disable-next-line missing-fields
            require("FTerm").scratch({ cmd = { opts.args } })
        else
            require("FTerm").toggle()
        end
    end, { nargs = "?", complete = "file", desc = "Toggle floating terminal or open scratch term and run command" })
end
local helpbuf = -1
local helpwin = -1
command("H", function(opts)
        local arg = fn.expand("<cword>")
        if opts.args ~= "" then arg = opts.args end
        helpbuf, helpwin = floating(helpbuf, helpwin, "help", "help")
        local cmdparts = {
            "try|help ",
            arg,
            "|catch /^Vim(help):E149/|call nvim_win_close(",
            helpwin,
            ", v:false)|echoerr v:exception|endtry",
        }
        vim.cmd(table.concat(cmdparts))
        api.nvim_buf_set_option(helpbuf, "filetype", "help") -- Set ft again to redraw conceal formatting.
    end,
    { nargs = "?", complete = "help", desc = "Open neovim help of argument or word under cursor in floating window" }
)
local manbuf = -1
local manwin = -1
command("M", function(opts)
    local arg = fn.expand("<cword>")
    if opts.args ~= "" then arg = opts.args end
    manbuf, manwin = floating(manbuf, manwin, "nofile", "man")
    local cmdparts = {
        "try|Man ",
        arg,
        '|catch /^Vim:man.lua: "no manual entry for/|call nvim_win_close(',
        manwin,
        ", v:false)|echoerr v:exception|endtry",
    }
    vim.cmd(table.concat(cmdparts))
end, { nargs = "?", desc = "Show man page of argument or word under cursor in floating window" }
)

-- Better jumping and motions.
-- TODO: Add repeat.vim optional dependency for leap.nvim?
local leap = load("leap")
if leap then leap.add_default_mappings() end

-- LaTeX/VimTeX setup.
vim.g.tex_flavor = "latex"
vim.g.vimtex_fold_enabled = 1
vim.g.vimtex_quickfix_mode = 0 -- See #1595
vim.g.vimtex_matchparen_enabled = 1
-- vim.gvimtex_view_method = "zathura"
vim.g.vimtex_fold_types = {
    cmd_single = { enabled = 0 },
    cmd_multi = { enabled = 0 },
    items = { enabled = 0 },
    envs = {
        blacklist = { 'equation', 'align', 'figure', 'enumerate', 'split',
            'equation*', 'align*', 'figure*', 'itemize',
            'pmatrix', 'bmatrix', 'vmatrix', 'Bmatrix', 'Vmatrix',
            'scope', 'displayquote', 'verbatim',
        },
    },
}
vim.g.vimtex_indent_lists = {
    'itemize',
    'description',
    'enumerate',
    'thebibliography',
    'compactitem',
}
vim.g.vimtex_quickfix_ignore_filters = { 'underfull', 'moderncv' }

-- Python syntax/filetype settings.
vim.g.python_highlight_all = 1
vim.g.python_highlight_builtin_types = 0
vim.g.python_highlight_space_errors = 0
vim.g.python_highlight_indent_errors = 0

-- Julia settings.
vim.g.julia_indent_align_brackets = 0
-- Use the latex to unicode converter provided by julia.vim for other filetypes.
table.insert(freqlangs, "markdown")
vim.g.latex_to_unicode_file_types = freqlangs

-- Don't open folds when restoring cursor position.
vim.g.lastplace_open_folds = 0

-- Overview.nvim bindings.
overview = load("overview")
if overview then
    bindkey("n", "gO", overview.toggle, { desc = "Toggle Overview sidebar for current buffer" })
    bindkey("n", "go", overview.focus, { desc = "Toggle focus between Overview sidebar and source buffer" })
end

-- Mellow theme setup.
system = vim.loop.os_uname().sysname
vim.g.mellow_show_bufnr = 0
if vim.env.COLORTERM == "truecolor" or system ~= "Linux" then
    opt.termguicolors = true
    -- Inherit 'background' (dark/light mode) from terminal emulator.
    if fn.executable('theme') > 0 then
        vim.o.background = fn.get(fn.systemlist('theme -q'), 0)
    else
        local hour24 = nil
        if system ~= "Linux" and vim.o.shell == "pwsh" then
            hour24 = tonumber(fn.system('Get-Date -Format HH'))
            if hour24 == nil then
                hour24 = 0
            end
        else
            hour24 = tonumber(fn.system('date +%H'))
        end
        if hour24 > 20 or hour24 < 9 then
            opt.background = "dark"
        else
            opt.background = "light"
        end
    end
    vim.g.mellow_user_colors = 1
    vim.cmd [[colorscheme mellow]]
else -- Minimal fallback color settings for vconsole.
    vim.cmd [[colorscheme pablo]]
    opt.background = "dark"
    vim.cmd [[
    hi! link ColorColumn Normal
    hi! link Statusline NonText
    hi! link TabLineFill NonText
    hi! link TabLineSel NonText
    hi! link VertSplit NonText
    hi! link StatusLineNC NonText
    ]]
end
