return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      -- { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
      { "nvim-telescope/telescope-fzf-native.nvim", build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' },
    },
    config = function()
      --      local telescope_custom_actions = {}
      --
      --      local actions = require("telescope.actions")
      --      local action_state = require("telescope.actions.state")
      --
      --      function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
      --        local picker = action_state.get_current_picker(prompt_bufnr)
      --        local selected_entry = action_state.get_selected_entry()
      --        local selected_entries = picker:get_multi_selection()
      --
      --        if #selected_entries == 0 then
      --          local entry = action_state.get_selected_entry()
      --          vim.cmd(string.format("%s %s", open_cmd, entry.path))
      --        else
      --          for _, entry in ipairs(selected_entries) do
      --            vim.cmd(string.format("%s %s", open_cmd, entry.path))
      --          end
      --        end
      --        actions.close(prompt_bufnr)
      --        --local num_selections = #picker:get_multi_selection()
      --        --if not num_selections or num_selections <= 1 then
      --        --  actions.add_selection(prompt_bufnr)
      --        --end
      --        --actions.send_selected_to_qflist(prompt_bufnr)
      --        --vim.cmd("cfdo " .. open_cmd)
      --      end
      --
      --      function telescope_custom_actions.multi_selection_open_vsplit(prompt_bufnr)
      --        telescope_custom_actions._multiopen(prompt_bufnr, "vsplit")
      --      end
      --
      --      function telescope_custom_actions.multi_selection_open_split(prompt_bufnr)
      --        telescope_custom_actions._multiopen(prompt_bufnr, "split")
      --      end
      --
      --      function telescope_custom_actions.multi_selection_open_tab(prompt_bufnr)
      --        telescope_custom_actions._multiopen(prompt_bufnr, "tabe")
      --      end
      --
      --      function telescope_custom_actions.multi_selection_open(prompt_bufnr)
      --        telescope_custom_actions._multiopen(prompt_bufnr, "edit")
      --      end
      --
      require("telescope").setup {
        defaults = {
          path_display = { "smart" },
          --          mappings = {
          --            i = {
          --              ["<ESC>"] = actions.close,
          --              ["<C-J>"] = actions.move_selection_next,
          --              ["<C-K>"] = actions.move_selection_previous,
          --              ["<TAB>"] = actions.toggle_selection,
          --              ["<C-TAB>"] = actions.toggle_selection + actions.move_selection_next,
          --              ["<S-TAB>"] = actions.toggle_selection + actions.move_selection_previous,
          --              ["<CR>"] = telescope_custom_actions.multi_selection_open,
          --              ["<C-V>"] = telescope_custom_actions.multi_selection_open_vsplit,
          --              ["<C-S>"] = telescope_custom_actions.multi_selection_open_split,
          --              ["<C-T>"] = telescope_custom_actions.multi_selection_open_tab,
          --              ["<C-DOWN>"] = require('telescope.actions').cycle_history_next,
          --              ["<C-UP>"] = require('telescope.actions').cycle_history_prev,
          --            },
          --            n = i,
          --          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            hidden = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          },
        },
      }
      require("telescope").load_extension("fzf")
      vim.api.nvim_set_keymap("n",
        "<C-p>",
        ":Telescope find_files<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ff",
        ":Neotree focus<CR>:Telescope find_files<CR>",
        { noremap = true, silent = true }
      )
      -- Create a file search with telescope
      local builtin = require("telescope.builtin")
      vim.keymap.set(
        "n",
        "<leader>ps",
        function()
          builtin.grep_string(
            { search = vim.fn.input("Grep: ") }
          )
        end
      )
    end
    --opts = {
    --  defaults = {},
    --  pickers = {
    --    find_files = {
    --      theme = "dropdown",
    --    },
    --  },
    --},
  },
}
