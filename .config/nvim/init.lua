-- *** NeoVim 0.8+ configuration file ***
local api = vim.api
local opt = vim.opt
local fn = vim.fn
local command = api.nvim_create_user_command
local bindkey = vim.keymap.set
local system = vim.loop.os_uname().sysname

local function is_executable(cmd) if fn.executable(cmd) > 0 then return true else return false end end
local function warn(msg) api.nvim_err_writeln("init.lua: " .. msg) end

-- Enable unicode input and markdown fenced block highlighting for:
local freqlangs = {
    "c", "cpp", "python", "nim", "sh", "conf", "css", "go", "json", "lua",
    "rust", "strace", "toml", "yaml", "openscad", "tex", "hare", "html",
} -- Unicode input will additionally be enabled in the "markdown" filetype.
if system == "Windows_NT" and is_executable("pwsh.exe") then opt.shell = "pwsh.exe" end

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
    if vim.wo.wrap then return end
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

-- Rename current buffer and associated file.
local function rename_file()
    local old_name = fn.expand("%")
    local new_name = fn.input("New file name: ", old_name)
    if new_name ~= "" and new_name ~= old_name then
        vim.cmd.saveas(new_name)
        vim.cmd("silent !rm " .. old_name)
        vim.cmd("silent bdelete " .. old_name)
        vim.cmd [[redraw!]]
    end
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
opt.completeopt = { "menu", "noselect" }
opt.helpheight = 0
opt.synmaxcol = 200
opt.scrolloff = 3
opt.showbreak = "> "

-- Direct integration with external executables.
if is_executable("rg") then opt.grepprg = "rg --vimgrep --smart-case --follow" end
if system == "Linux" and vim.env.WAYLAND_DISPLAY ~= nil then
    if is_executable("wl-copy") and is_executable("wl-paste") then
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

if is_executable("theme") then -- Use `theme` executable to manage global dark/light TUI theme.
    command("SyncTheme", [[silent! let &background = get(systemlist('theme -q'), 0, 'light')]],
        { desc = "Sync to global TUI theme using `!theme`" })
end
command("ToggleTheme", function()
        if is_executable("theme") then
            vim.cmd [[silent! exec '!theme -t'|let &background = get(systemlist('theme -q'), 0, 'light')]]
        else
            if vim.o.background == "light" then opt.background = "dark" else opt.background = "light" end
        end
    end,
    { desc = "Toggle global TUI theme using `!theme`, if available; also toggle neovim &background setting" })

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
command("CDHere", function() vim.cmd("tcd " .. fn.expand("%:p:h")) end,
    { desc = "Change directory to the parent directory of the current buffer" })

-- Autocommands for terminal buffers and basic filetype settings.
vim.cmd [[augroup terminal_buffer_rules
    autocmd!
    autocmd TermOpen * setlocal nonumber norelativenumber signcolumn=no
    autocmd TermOpen * startinsert
    autocmd TermEnter * setlocal scrolloff=0
    autocmd BufEnter,WinEnter term://* startinsert | setlocal nobuflisted
augroup END]]

vim.filetype.add({ extension = { tikzstyles = "tex" } })
if is_executable("txr") then
    vim.list_extend(freqlangs, { "txr", "tl" })
    vim.filetype.add({ extension = { txr = "txr" } })
    vim.filetype.add({ extension = { tl = "tl" } })
end

local filetype_rules = api.nvim_create_augroup("filetype_rules", { clear = true })
local function setl_ft_autocmd(filetypes, options)
    local cmdparts = {}
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
setl_ft_autocmd({ "bash", "sh", "zsh" }, { foldmethod = "marker", textwidth = 100 })
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
    autocmd ColorScheme mellow hi link FloatTitle CursorLineNr
    autocmd ColorScheme mellow hi link @string.documentation.python Comment
augroup END]]

-- Mappings. De gustibus: general fixes and tweaks.
-- Ergonomic, smart mode switches, with variants for us/intl-altgr keyboard.
bindkey("i", [[¶]], [[<Esc>]])
bindkey("i", [[<M-;>]], [[<Esc>]])
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

bindkey("n", [[<Leader>c]], [[<Cmd>set cursorcolumn!<Cr>]], { desc = "Toggle cursorcolumn" })
bindkey("n", [[<Leader>h]], [[<Cmd>setlocal foldenable!<Cr>]], { desc = "Toggle folding (buffer-local)" })
bindkey("n", [[<Leader>l]], [[<Cmd>set cursorline!<Cr>]], { desc = "Toggle cursorline" })
bindkey("n", [[<Leader>m]], [[<Cmd>make!<Cr>]], { desc = "Run make! (doesn't jump to errorfile)" })
bindkey("n", [[<Leader>i]], [[<Cmd>TSToggle highlight|doautocmd ColorScheme<Cr>]],
    { desc = "Toggle tree-sitter syntax highlighting" })
-- Toggle line numbers for focused buffer.
bindkey("n", [[<Leader>n]], [[<Cmd>set number! relativenumber!<Cr>]], { silent = true })
-- Paste last yanked text ignoring cut text.
bindkey("", [[<Leader>p]], [["0p]])
bindkey("", [[<Leader>P]], [["0P]])
-- Toggle spell checking in current buffer.
bindkey("n", [[<Leader>s]], [[<Cmd>setlocal spell!<Cr>]], { silent = true })
-- Sync theme to system, using `theme -q` (Linux only).
bindkey("n", [[<Leader>t]], [[<Cmd>SyncTheme<Cr>]], { silent = true })
-- Write focused buffer if modified.
bindkey("n", [[<Leader>w]], [[<Cmd>up<Cr>]], { silent = true })
-- Copy file contents, name or path to clipboard.
bindkey("n", [[<Leader>y]], function() copy_file() end,
    { silent = true, desc = "Copy file contents, name, path or directory to clipboard" })
-- Toggle soft-wrapping of long lines to the view width.
bindkey("n", [[<Leader>z]], function()
    if vim.o.textwidth > 0 and vim.o.wrap == false then
        opt.textwidth = 0
        opt.wrap = true
    elseif vim.o.textwidth == 0 and vim.o.wrap == true then
        opt.wrap = false
        opt.filetype = vim.o.filetype -- This should reset &textwidth.
    end
end, { silent = true, desc = "Toggle use of 'textwidth' for hard-wrapping versus soft-wrapping with 'wrap'" })
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

local function load(plugin) -- Load either local or third-party plugin.
    local has_plugin, out = pcall(require, plugin)
    if has_plugin then
        return out
    else
        warn("failed to load plugin '" .. plugin .. "'")
        return nil
    end
end

command("TabTerminal", function(opts) vim.cmd("tabnew|terminal " .. opts.args) end,
    { nargs = "?", complete = "shellcmd", desc = "Open new tab with a terminal (optionally running the given command)" })

local function pkgbootstrap()
    local pckr_path = fn.stdpath("data") .. "/site/pack/pckr/start/pckr.nvim"
    if not vim.loop.fs_stat(pckr_path) then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/lewis6991/pckr.nvim", pckr_path })
    end
    opt.rtp:prepend(pckr_path)
end

pkgbootstrap()
require("pckr").add {
    "neovim/nvim-lspconfig",               -- Community configs for :h lsp.
    "numToStr/Comment.nvim",               -- Quickly comment/uncomment code.
    "kylechui/nvim-surround",              -- Quoting/parenthesizing made simple.
    "nvim-lua/plenary.nvim",               -- Lua functions/plugin dev library.
    "whiteinge/diffconflicts",             -- 2-way vimdiff for merge conflicts (VimL).
    "echasnovski/mini.map",                -- A code minimap, like what cool Atom kids have.
    "lukas-reineke/indent-blankline.nvim", -- Visual indentation guides.
    "folke/todo-comments.nvim",            -- Track TODO/FIXME comments.
    "lewis6991/gitsigns.nvim",             -- Git status in sign column and statusbar.
    "SidOfc/carbon.nvim",                  -- Replacement for :h netrw, directory viewer.
    "ggandor/leap.nvim",                   -- Alternative to '/' for quick search/motions.
    "farmergreg/vim-lastplace",            -- Open files at the last viewed location (VimL).
    "AndrewRadev/inline_edit.vim",         -- Edit embedded code in a temporary buffer with a different filetype
    -- Downloader and shims for tree-sitter grammars; see :h :TSInstall and :h :TSEnable.
    { "nvim-treesitter/nvim-treesitter", cond = function(load_plugin)
        if is_executable('tree-sitter') then load_plugin() end
    end, run = ":TSUpdate" },
    -- Community configs for efm-langserver.
    { "creativenull/efmls-configs-nvim", cond = function(load_plugin)
        if is_executable('efm-langserver') then load_plugin() end
    end,
        requires = { "neovim/nvim-lspconfig" },
    },
    -- Follow symlinks when opening files (Linux, VimL).
    { "aymericbeaumet/vim-symlink",
        requires = { "moll/vim-bbye" },
    },
    "dhruvasagar/vim-open-url",   -- Open URL's in browser without :h netrw (VimL).
    "alvan/vim-closetag",         -- Auto-close (x|ht)ml tags (VimL).
    "vim-python/python-syntax",   -- Improved Python syntax highlighting (VimL).
    "hattya/python-indent.vim",   -- PEP8 auto-indenting for Python (VimL).
    "euclidianAce/BetterLua.vim", -- Improved Lua syntax highlighting (VimL).
    "jakemason/ouroboros",        -- Switch between .c/.cpp and header files.

    "adigitoleo/vim-mellow",
    "adigitoleo/vim-mellow-statusline",
    "https://git.sr.ht/~adigitoleo/overview.nvim",
    "https://git.sr.ht/~adigitoleo/haunt.nvim",
    "https://git.sr.ht/~adigitoleo/quark.nvim",

    -- Comprehensive LaTeX integration.
    { "lervag/vimtex", cond = function(load_plugin)
        if is_executable("latex") then load_plugin() end
    end },
    -- Improved Julia syntax highlighting, unicode input.
    { "JuliaEditorSupport/julia-vim", cond = function(load_plugin)
        if is_executable("julia") then
            load_plugin()
            table.insert(freqlangs, "julia")
        end
    end },
    -- Syntax highlighting for #lang pollen
    { "otherjoel/vim-pollen", cond = function(load_plugin)
        if is_executable("racket") then
            load_plugin()
            vim.list_extend(freqlangs, { "racket", "pollen" })
        end
    end },
    -- Provides the basic fzf.vim file.
    { "junegunn/fzf", run = ":call fzf#install()", cond = function(load_plugin)
        if system == "Windows_NT" or is_executable("apt") then load_plugin() end
    end },
}

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
            bindkey("n", "gL", vim.lsp.buf.document_symbol, { buffer = ev.buf, desc = "List symbols (current document)" })
            bindkey("n", "gf", function()
                vim.lsp.buf.format { async = true }
            end, { buffer = ev.buf, desc = "Run LSP formatter" })
            bindkey("v", "gf", function()
                vim.lsp.buf.format { async = true }
            end, { buffer = ev.buf, desc = "Run LSP formatter" })
        end,
    })
    -- Borders for LSP popup windows.
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
    vim.diagnostic.config { float = { border = "single" } }
    -- https://github.com/LuaLS/lua-language-server
    if is_executable('lua-language-server') then
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
                    telemetry = { enable = false }, -- Do not send telemetry data!
                },
            },
        }
    end
    -- https://github.com/mattn/efm-langserver
    if is_executable('efm-langserver') then
        local efm_languages = {}
        if is_executable('shellcheck') then
            local shellcheck = load('efmls-configs.linters.shellcheck')
            if shellcheck then efm_languages.sh = { shellcheck } end
        end
        lsp.efm.setup {
            filetypes = vim.tbl_keys(efm_languages),
            settings = {
                rootMarkers = { '.git/' },
                languages = efm_languages,
            },
            init_options = {
                documentFormatting = true,
                documentRangeFormatting = true,
            }
        }
    end
    -- Requires pip install python-lsp-server (NOT python-language-server!).
    if is_executable('pylsp') then
        lsp.pylsp.setup {
            settings = {
                pylsp = { plugins = { pycodestyle = { maxLineLength = 88 } } }
            }
        }
    end
    -- https://github.com/latex-lsp/texlab
    if is_executable('texlab') then lsp.texlab.setup {} end
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

-- Indent guides.
local indent_blankline = load("ibl")
if indent_blankline then indent_blankline.setup() end

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

overview = load("overview")
if overview then -- Overview.nvim bindings.
    bindkey("n", "gO", overview.toggle, { desc = "Toggle Overview sidebar for current buffer" })
    bindkey("n", "go", overview.focus, { desc = "Toggle focus between Overview sidebar and source buffer" })
end
haunt = load("haunt")
quark = load("quark")
if quark then
    quark.setup {
        -- Requires ripgrep: <https://github.com/BurntSushi/ripgrep>
        fzf = { default_command = "rg --files --hidden --no-messages" }
    }
    bindkey("n", ";", quark.fuzzy_cmd, { desc = "Search for (and execute) ex-commands" })
    bindkey("n", [[<Leader>b]], [[<Cmd>QuarkSwitch<Cr>]], { desc = "Launch buffer switcher" })
    bindkey("n", [[<Leader>f]], [[<Cmd>QuarkFind<Cr>]], { desc = "Launch file browser" })
    bindkey("n", [[<Leader>r]], [[<Cmd>QuarkRecent<Cr>]], { desc = "Launch recent file browser" })
end

-- Mellow theme setup.
vim.g.mellow_show_bufnr = 0
if vim.env.COLORTERM == "truecolor" or system ~= "Linux" then
    opt.termguicolors = true
    if is_executable('theme') then -- Inherit 'background' (dark/light mode) from terminal emulator.
        opt.background = fn.get(fn.systemlist('theme -q'), 0)
    else
        local hour24 = nil
        if system ~= "Linux" and string.match(vim.o.shell, "pwsh") ~= nil then
            hour24 = tonumber(fn.system('Get-Date -Format HH'))
        else
            hour24 = tonumber(fn.system('date +%H'))
        end
        if hour24 == nil then hour24 = 0 end
        if hour24 > 20 or hour24 < 9 then
            opt.background = "dark"
        else
            opt.background = "light"
        end
    end
    vim.g.mellow_user_colors = 1
    vim.cmd [[colorscheme mellow]]
else -- Minimal fallback color settings for vconsole.
    vim.cmd [[colorscheme lunaperche]]
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
