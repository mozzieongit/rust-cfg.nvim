local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
end

local features_picker = require('telescope._extensions.pickers.features_picker')
local targets_picker  = require('telescope._extensions.pickers.targets_picker')


-- -----------------------------------------------------------------------------
-- Telescope
-- -----------------------------------------------------------------------------

local run_features = function(opts)
  opts = opts or {}

  defaults = {
    -- action = action,
  }

  features_picker(vim.tbl_extend("force", defaults, opts))
end

local run_targets = function(opts)
  opts = opts or {}

  defaults = {
    -- action = action,
  }

  targets_picker(vim.tbl_extend("force", defaults, opts))
end

-- -----------------------------------------------------------------------------
-- Telescope extension registration
-- -----------------------------------------------------------------------------

return telescope.register_extension({
  exports = {
    targets = run_targets,
    features = run_features
  }
})
