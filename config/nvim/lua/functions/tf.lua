local M = {}

M.ssodata = function()
  -- Using vim.ui.input to get user input in Lua
  vim.ui.input({ prompt = "Enter object value: " }, function(object)
    if object then
      vim.ui.input({ prompt = "Enter role name value (e.g., Test): " }, function(rolename)
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

M.provider = function()
  -- Using vim.ui.input to get user input in Lua
  vim.ui.input({ prompt = "Enter profile name, e.g. non-prd: " }, function(profile)
    if profile then
      local formatted_profile = profile:gsub("-", "_")
      -- Template with placeholders replaced by user input
      local template = string.format(
        "provider \"aws\" {\n" ..
        "  region  = \"us-east-1\"\n" ..
        "  profile = var.ci ? \"terraform-it\" : \"terraform-%s\"\n" ..
        "  alias = \"%s\"\n" ..
        "  dynamic \"assume_role\" {\n" ..
        "    for_each = var.ci ? [\"default\"] : []\n" ..
        "    content {\n" ..
        "      role_arn = data.terraform_remote_state.runners.outputs[\"roles\"][\"%s\"]\n" ..
        "    }\n" ..
        "  }\n" ..
        "}", profile, profile, formatted_profile)
      local lines = vim.split(template, "\n", true)
      vim.api.nvim_put(lines, 'l', true, true)
    end
  end)
end

return M
