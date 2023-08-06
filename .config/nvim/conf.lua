-- First steps in migrating to lua config.
vim.filetype.add({extension = {tikzstyles = 'tex'}})

-- TODO: Print warnings when the has_<plugin> stuff fails.
local has_lspconfig, lsp = pcall(require, 'lspconfig')
if has_lspconfig then
    -- Requires pip install python-lsp-server (NOT python-language-server!).
    if vim.fn.executable('pylsp') > 0 then
        lsp.pylsp.setup{
            settings = {
                pylsp = {
                    plugins = {
                        pycodestyle = {
                            maxLineLength = 88
                        }
                    }
                }
            }
        }
    end

    -- https://github.com/LuaLS/lua-language-server
    if vim.fn.executable('lua-language-server') > 0 then
        lsp.lua_ls.setup {
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = {'vim'},
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file("", true),
                        -- silence weird luassert message, https://github.com/LuaLS/lua-language-server/discussions/1688
                        checkThirdParty = false,
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = {
                        enable = false,
                    },
                },
            },
        }
    end

    -- LSP mappings and autocommands.
    -- To focus the hover buffer, press K a second time.
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', 'gR', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', 'gf', function()
                vim.lsp.buf.format{async = true}
            end, opts)
        end,
    })
end

-- Git signs and minimap.
local has_gitsigns, gitsigns = pcall(require, 'gitsigns')
if has_gitsigns then gitsigns.setup() end
local has_minimap, minimap = pcall(require, 'mini.map')
if has_minimap then
    minimap.setup({
        symbols = { encode = minimap.gen_encode_symbols.dot('3x2') },
        integrations =  { minimap.gen_integration.gitsigns() },
        window = { width = 15, show_integration_count = false },
    })
    vim.keymap.set('n', 'mf', minimap.toggle_focus)
    vim.keymap.set('n', 'mr', minimap.refresh)
    vim.keymap.set('n', 'gm', minimap.toggle)
end

-- TODO/FIXME comment tracker setup.
local has_todo_comments, todo_comments = pcall(require, 'todo-comments')
if has_todo_comments then
    todo_comments.setup({signs = false, colors = {error = {"DiagnosticWarn"}}, highlight = {before = "bg", after = ""}})
    vim.keymap.set("n", "]t", function()
        todo_comments.jump_next()
    end, { desc = "Next todo comment" })
    vim.keymap.set("n", "[t", function()
        todo_comments.jump_prev()
    end, { desc = "Previous todo comment" })
end

-- Replacement for buggy vim8 directory viewer.
local has_carbon, carbon = pcall(require, 'carbon')
if has_carbon then carbon.setup() end
