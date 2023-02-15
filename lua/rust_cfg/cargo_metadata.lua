local has_plenary_job, Job = pcall(require, "plenary.job")
if not has_plenary_job then
  error("This plugins requires plenary")
end

-- -----------------------------------------------------------------------------
-- Utils 
-- -----------------------------------------------------------------------------
local JSON_DECODE_OPTS = { luanil = { object = true, array = true } }

local function parse_json(json_str)
   if not json_str then
      return
   end
   local success, json = pcall(vim.json.decode, json_str, JSON_DECODE_OPTS)
   if not success then
      return
   end

   if json and type(json) == "table" then
      return json
   end
end

-- -----------------------------------------------------------------------------
-- Main logic 
-- -----------------------------------------------------------------------------

-- the features list retrieved from cargo metadata
local M = {}

-- Retrieve cargo metadata
--
-- @param on_exit Callback
local function get_cargo_metadata(on_exit)
  return Job:new({
    command = "cargo",
    args = {
      "metadata", 
      "--no-deps", 
      "--format-version","1" 
    },
    on_exit = vim.schedule_wrap(on_exit),
  })
end

-- Parse cargo metadata --no-deps json output in order to extract the features of the current crate
--
-- Retrieves features from cargo metadata by parsing the json string
-- @param json_str String
-- @return table of features
function M.parse_features(json_str)
  local json = parse_json(json_str)
  if not (json and json.packages) then
    return 
  end

  local crate_data = json.packages[1]
  local features_list = { "all" }
  for feats, _ in pairs(crate_data.features) do
    table.insert(features_list, feats)
  end

  return features_list
end

local function get_features(callback)
  if M.jobs then
      return
   end

  local callbacks = { callback }

  -- Job callback
  local function on_exit(j, code, signal)
    local cancelled = signal ~= 0

    local json = nil
    if code == 0 then
      json = table.concat(j:result(), "\n")
    end

    local features = {}
    if not cancelled then
     features = M.parse_features(json)
    end
    for _, c in ipairs(callbacks) do
      c(features, cancelled)
    end

    M.jobs = nil
  end

  local job = get_cargo_metadata(on_exit)
  M.jobs = {
    job = job,
    callbacks = callbacks
  }
  job:start()
end

function M.get_features()
   return coroutine.yield(function(resolve)
      get_features(resolve)
   end)
end

return M
