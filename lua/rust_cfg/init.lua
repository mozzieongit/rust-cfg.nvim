local has_rusttools, rusttools = pcall(require, "rust-tools")

local defaults_opts = {
  get_settings = function()
    if not has_rusttools then
      error("Either use rusttools, or override get_settings function")
    end
    return rusttools.config.options.server.settings
  end
}
local M = {}

M.metadata = {
  -- the list of features 
  features = {},
  -- the target 
  target = nil
}

M.options = {}

M.setup = function(opts)
  opts = opts or {}
  M.options = vim.tbl_deep_extend("force", defaults_opts, opts)
end

-- -----------------------------------------------------------------------------
-- rust-analyzer configuration
-- -----------------------------------------------------------------------------
local set_rust_analyzer_features = function(features)
  local settings = M.options.get_settings()
  if settings == nil then
    error("Couldn't get LSP settings")
  end

  -- check if cargo is nil which could happend depending on the configuration used
  if not settings["rust-analyzer"].cargo then
    settings["rust-analyzer"].cargo= {
      features = features
    }
  else
    settings["rust-analyzer"].cargo.features = features
  end
  vim.cmd[[:LspRestart<CR>]]
end

local set_rust_analyzer_target = function(target_triple)
  local settings = M.options.get_settings()
  if settings == nil then
    error("Couldn't get LSP settings")
  end

  -- check if cargo is nil which could happend depending on the configuration used
  if not settings["rust-analyzer"].cargo then
    settings["rust-analyzer"].cargo = {
      target = target_triple
    }
  else
    settings["rust-analyzer"].cargo.target = target_triple
  end
  vim.cmd[[:LspRestart<CR>]]
end

-- -----------------------------------------------------------------------------
-- Plugin functions
-- -----------------------------------------------------------------------------

-- Toggle a feature 
-- @param feature string - The feature to toggle
M.toggle_feature = function(feature)
  if M.metadata.features == "all" then
    M.metadata.features = {}
  end

  local idx = nil
  for i, f in ipairs(M.metadata.features) do
    if f == feature then
      idx = i
      break
    end
  end

  if idx then
    table.remove(M.metadata.features, idx)
  else
    table.insert(M.metadata.features, feature)
  end
  set_rust_analyzer_features(M.metadata.features)
end

-- Configure rust-analyzer in order to check all features
M.set_all_features = function()
  M.metadata.features = "all"
  set_rust_analyzer_features(M.metadata.features)
end

-- Remove all features from the rust-analyzer configuration
M.no_features = function()
  M.metadata.features = {}
  set_rust_analyzer_features(M.metadata.features)
end

-- Set the target of the current project to the triple provided in parameter
M.set_target = function(triple)
  M.metadata.target = triple
  set_rust_analyzer_target(M.metadata.target)
end

-- Reset the target 
M.reset_target = function()
  M.metadata.target = nil
  set_rust_analyzer_target(M.metadata.target)
end

return M
