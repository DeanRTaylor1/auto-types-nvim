
local M = {}

M.setup = function(opts)
    print("Options:", opts)
end

M.print_diagnostics = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local diagnostics = vim.diagnostic.get(bufnr)
    if #diagnostics == 0 then
        print(nil)
    else
        for i, diagnostic in ipairs(diagnostics) do
          if string.match(diagnostic.message, "missing the following properties from type") then
            print(string.format("Diagnostic %d: %s", i, diagnostic.message))
            local type = string.match(diagnostic.message, "incorrectly implements interface '(.-)'.")
            print(type)
            local win = vim.api.nvim_get_current_win()
            local pos = vim.fn.searchpos(type, 'n')
            vim.api.nvim_win_set_cursor(win, pos)
            -- Send a request to the LSP server and provide a callback function
            vim.lsp.buf_request(0, 'textDocument/hover', vim.lsp.util.make_position_params(), function(err, result)
              if err then
                print("Error: ", err)
              else
                -- Store the result in a variable
                local type_definition = result
                -- Print the result
                local lines = vim.split(vim.inspect(type_definition), '\n', true)
                -- Create a new buffer and set it to the current window
                local buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_set_current_buf(buf)
                -- Add the lines to the new buffer
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
              end
            end)
          end
        end
    end
end

vim.keymap.set("n", "<Leader>ac", M.print_diagnostics)

return M

