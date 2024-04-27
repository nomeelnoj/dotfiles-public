local M = {}

M.ssodata = function()
    -- Using vim.ui.input to get user input in Lua
    vim.ui.input({prompt = "Enter object value: "}, function(object)
        if object then
            vim.ui.input({prompt = "Enter role name value (e.g., Test): "}, function(rolename)
                if rolename then
                    -- Template with placeholders replaced by user input
                    local template = string.format(
                        "data \"aws_iam_roles\" \"sso_%s\" {\n" ..
                        "  path_prefix = \"/aws-reserved/sso.amazonaws.com/\"\n" ..
                        "  name_regex  = \"^AWSReservedSSO_%s_.*\"\n" ..
                        "}\n", object, rolename)
                    -- Splitting the template into lines and inserting into the buffer
                    local lines = vim.split(template, "\n", true)
                    vim.api.nvim_put(lines, 'l', true, true)
                end
            end)
        end
    end)
end

return M