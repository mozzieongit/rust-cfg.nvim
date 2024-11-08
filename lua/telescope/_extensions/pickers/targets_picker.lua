local actions       = require('telescope.actions')
local actions_state = require('telescope.actions.state')
local conf          = require('telescope.config').values
local finders       = require('telescope.finders')
local pickers       = require('telescope.pickers')

local rust_cfg      = require('rust_cfg')
local rustup        = require('rust_cfg.rustup')
local async         = require('rust_cfg.async')

local picker        = async.wrap(function(opts)
  local features, cancelled = rustup.get_targets()
  if cancelled then return end

  opts = opts or {}
  pickers
      .new(opts, {
        prompt_title = "Rustup targets",
        finder = finders.new_table({ results = features }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = actions_state.get_selected_entry()
            actions.close(prompt_bufnr)
            rust_cfg.set_target(selection.value)
          end)
          return true
        end,
      }):find()
end)

return picker
