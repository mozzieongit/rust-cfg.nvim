local actions       = require('telescope.actions')
local actions_state = require('telescope.actions.state')
local actions_utils = require('telescope.actions.utils')
local conf          = require('telescope.config').values
local finders       = require('telescope.finders')
local pickers       = require('telescope.pickers')

local rust_cfg      = require('rust_cfg')
local rust_metadata = require('rust_cfg.cargo_metadata')
local async         = require('rust_cfg.async')

local function display_feature(feature, active)
  if active[feature] then
    return "★ " .. feature
  else
    return "  " .. feature
  end
end

local function feature_entry_maker()
  local client = vim.lsp.get_clients({ bufnr = 0 })[1]
  local lsp_features = client.config.settings["rust-analyzer"].cargo.features
  local active = {}
  for _, v in ipairs(lsp_features) do
    active[v] = true
  end

  local lookup_keys = {
    display = 2,
    ordinal = 1,
    value = 1,
  }

  local mt_string_entry = {
    __index = function(t, k)
      return rawget(t, lookup_keys[k])
    end,
  }

  return function(line)
    return setmetatable({
      line,
      display_feature(line, active),
    }, mt_string_entry)
  end
end

local picker = async.wrap(function(opts)
  local features, cancelled = rust_metadata.get_features()
  if cancelled then return end

  opts = opts or {}
  pickers
      .new(opts, {
        prompt_title = "Cargo features",
        finder = finders.new_table({ results = features, entry_maker = feature_entry_maker() }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selected = {}
            actions_utils.map_selections(prompt_bufnr, function(selection)
              table.insert(selected, selection)
            end)

            local used_multi = false
            for _,v in ipairs(selected) do
              used_multi = true
              rust_cfg.toggle_feature(v.value)
            end

            if not used_multi then
              local selection = actions_state.get_selected_entry()
              rust_cfg.toggle_feature(selection.value)
            end

            actions.close(prompt_bufnr)
          end)
          return true
        end,
      }):find()
end)

return picker
