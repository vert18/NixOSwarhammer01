local module = {}
local config
local slots = {}
local next_slot = 1
local last_active = {}

local function monitors()
    local values = {}
    for index = 0, zl.monitor_count() - 1 do
        table.insert(values, zl.monitor_info(index))
    end
    return values
end

local function monitor_slot(name)
    if slots[name] then return slots[name] end
    slots[name] = next_slot
    next_slot = next_slot + 1
    return slots[name]
end

local function map_monitor(monitor)
    local slot = assert(monitor_slot(monitor.name))
    local first = (slot - 1) * config.workspace_count + 1
    local previous = tonumber(last_active[monitor.name] or monitor.active_workspace.name)
    last_active[monitor.name] = nil
    for index = first, first + config.workspace_count - 1 do
        local name = tostring(index)
        assert(zl.workspace_on_monitor(monitor.name, name))
        assert(zl.set_workspace_persistent(name, config.enable_persistent_workspaces, monitor.name))
    end
    local last = first + config.workspace_count - 1
    if config.keep_focused and previous and previous >= first and previous <= last then
        assert(zl.workspace_on_monitor(monitor.name, tostring(previous)))
    else
        assert(zl.workspace_on_monitor(monitor.name, tostring(first)))
    end
end

local function map_all()
    for _, monitor in ipairs(monitors()) do map_monitor(monitor) end
end

local function output_removed(monitor)
    last_active[monitor.name] = monitor.active_workspace.name
    map_all()
end

local function resolve(value)
    local monitor = assert(zl.monitor_info(zl.active_monitor_index()))
    local first = (assert(monitor_slot(monitor.name)) - 1) * config.workspace_count + 1
    local current = tonumber(monitor.active_workspace.name) or first
    if value == "+1" or value == "-1" then
        local target = current + tonumber(value)
        local last = first + config.workspace_count - 1
        if config.enable_wrapping then
            if target < first then target = last end
            if target > last then target = first end
        else
            if target < first then target = first end
            if target > last then target = last end
        end
        return tostring(target)
    end
    local local_index = assert(tonumber(value))
    assert(local_index == math.floor(local_index) and local_index >= 1 and local_index <= config.workspace_count, "workspace index out of range")
    return tostring(first + local_index - 1)
end

function module.setup(value)
    assert(type(value) == "table", "split_workspaces.setup expects a table")
    assert(type(value.workspace_count) == "number" and value.workspace_count == math.floor(value.workspace_count) and value.workspace_count >= 1, "workspace_count must be a positive integer")
    value.monitor_priority = value.monitor_priority or {}
    assert(type(value.monitor_priority) == "table", "monitor_priority must be a table")
    local names = {}
    for _, name in ipairs(value.monitor_priority) do
        assert(type(name) == "string" and name ~= "" and not names[name], "monitor_priority entries must be unique names")
        names[name] = true
    end
    config = value
    slots = {}
    last_active = {}
    for index, name in ipairs(config.monitor_priority) do slots[name] = index end
    next_slot = #config.monitor_priority + 1
    if config.keep_focused == nil then config.keep_focused = true end
    if config.enable_persistent_workspaces == nil then config.enable_persistent_workspaces = true end
    zl.on("config_reloaded", map_all)
    zl.on("output_added", map_monitor)
    zl.on("output_removed", output_removed)
end

function module.workspace(value)
    return function() return zl.workspace(resolve(value)) end
end

function module.move_to_workspace(value)
    return function() return zl.move_window_workspace(resolve(value), true) end
end

function module.move_to_workspace_silent(value)
    return function() return zl.move_window_workspace(resolve(value), false) end
end

function module.cycle_workspaces(direction)
    return module.workspace(direction == "prev" and "-1" or "+1")
end

function module.get_amount_of_workspaces()
    return config.workspace_count
end

function module.grab_rogue_windows()
    return function()
        local active = assert(zl.monitor_info(zl.active_monitor_index()))
        local mapped = {}
        for _, monitor in ipairs(monitors()) do
            local first = (assert(monitor_slot(monitor.name)) - 1) * config.workspace_count + 1
            for index = first, first + config.workspace_count - 1 do mapped[tostring(index)] = true end
        end
        for _, window in ipairs(zl.get_windows()) do
            if window.mapped and not window.workspace.special and not mapped[window.workspace.name] then
                assert(zl.move_window_workspace(active.active_workspace.name, false, window.address))
            end
        end
    end
end

return module
