local has_plenary_job, Job = pcall(require, "plenary.job")
if not has_plenary_job then
  error("This plugins requires plenary")
end

local M = {}

-- Retrieve targets
--
-- @param on_exit Callback
local function get_rustup_targets(on_exit)
  return Job:new({
    command = "rustup",
    args = {
      "target",
      "list",
      "--installed"
    },
    on_exit = vim.schedule_wrap(on_exit),
  })
end

-- Parse rustup targets
function M.parse_targets(data)
  local targets = {}
  for line in string.gmatch(data, "[^\n]+") do
      table.insert(targets, line);
  end

  return targets
end

local function get_targets(callback)
  if M.jobs then
      return
   end

  local callbacks = { callback }

  -- Job callback
  local function on_exit(j, code, signal)
    local cancelled = signal ~= 0

    local json = nil
    if code == 0 then
      data = table.concat(j:result(), "\n")
    end

    local targets = {}
    if not cancelled then
     targets = M.parse_targets(data)
    end
    for _, c in ipairs(callbacks) do
      c(targets, cancelled)
    end

    M.jobs = nil
  end

  local job = get_rustup_targets(on_exit)
  M.jobs = {
    job = job,
    callbacks = callbacks
  }
  job:start()
end

function M.get_targets()
   return coroutine.yield(function(resolve)
      get_targets(resolve)
   end)
end

return M
