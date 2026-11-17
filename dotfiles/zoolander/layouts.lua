-- Spatial layout bindings (docs/WINDOW-LAYOUTS-DESIGN.md, section 4).
--
-- Stable action families whose meaning follows the focused layout:
--   Super+arrows              focus a neighbour
--   Super+Shift+arrows        move / reorder the focused window
--   Super+Alt+arrows          resize the window or the relevant divider
--   Super+[ / Super+]         previous / next unit (window, lane, island ...)
--   Super+Alt+Return          the layout's primary action
--   Super+Alt+Tab             cycle focus regions (main, shelves, anchors)
--   Super+Ctrl+Return         inspect the focused window
--   Super+Ctrl+Space          command sheet (every action, searchable)
--   Super+L / Super+Shift+L   next / previous layout for this workspace
--   Super+Ctrl+= / - / 0      zoom a Canvas in / out / back to 1:1
--   Super+R / Super+Shift+R   Scrolling: next / previous width of the focused column
--   Super+Alt+Shift+arrows    Scrolling: move the focused column along the strip
--   Super+Ctrl+Alt+arrows     move the focused column to the output that way
--
-- Super+Shift+Left/Right move the window to the adjacent workspace in the
-- classic layouts and within the layout in the spatial ones;
-- Super+Ctrl+Shift+Left/Right always move it to the adjacent workspace.
local M = {}

local L, S, A, C = zl.MOD_LOGO, zl.MOD_SHIFT, zl.MOD_ALT, zl.MOD_CTRL
local arrows = { left = zl.KEY_LEFT, right = zl.KEY_RIGHT, up = zl.KEY_UP, down = zl.KEY_DOWN }

local function layout(action, a, b)
    return function() return zl.layout(action, a, b) end
end

-- Held move/resize/pan keys repeat; the compositor stops a repeat the
-- moment its context changes (another window, layout or workspace).
local held = true

local function bind(mods, key, description, action, repeating)
    return zl.bind(mods, key, action, { description = description, repeating = repeating or false })
end

local pretty = {
    canvas = "Canvas", shelves = "Side Shelves", islands = "Islands", lanes = "Lanes",
    accordion = "Accordion", workbench = "Workbench", pairs = "Pairs", anchors = "Anchors",
    dwindle = "Dwindle", master_stack = "Master", grid = "Grid", monocle = "Monocle",
    spiral = "Spiral", scrolling = "Scrolling", floating = "Floating",
}

-- Next (1) or previous (-1) layout for the focused workspace. By default it
-- steps through every layout: dwindle, master_stack, grid, monocle, spiral,
-- scrolling, floating, then the presets canvas, shelves (Side Shelves),
-- islands, lanes, accordion, workbench, pairs, anchors. `list` limits it to
-- those names, in that order. Without `announce` the
-- compositor shows a toast; with it, the toast is skipped and
-- announce(name) reports the new layout instead (an OSD, a notification).
function M.cycle(step, announce, list)
    return function()
        local result
        if list and #list > 0 then
            local context = zl.layout_context()
            local current = context and (context.entry or context.layout)
            local index = 0
            for i, name in ipairs(list) do
                if name == current then index = i end
            end
            local target
            if index == 0 then
                target = step > 0 and list[1] or list[#list]
            else
                target = list[((index - 1 + step) % #list) + 1]
            end
            result = zl.layout("layout_set", announce and 1 or 0, target)
        else
            result = zl.layout("layout_cycle", step, announce and "quiet" or nil)
        end
        if result == "done" and announce then
            local context = zl.layout_context()
            if context then
                local entry = context.entry or context.layout
                announce(pretty[entry] or entry)
            end
        end
        return result
    end
end

-- Zoom a Canvas by `steps` notches (positive in, 0 = 1:1); anywhere else
-- run `fallback` (e.g. switch workspace), so one binding serves both.
function M.zoom_or(steps, fallback)
    return function()
        local context = zl.layout_context()
        if context and context.layout == "canvas" then return zl.layout("zoom", steps) end
        if fallback then return fallback() end
    end
end

local function spatial()
    local context = zl.layout_context()
    return context ~= nil and context.spatial
end

function M.setup(options)
    options = options or {}
    local split = options.split

    for name, key in pairs(arrows) do
        bind(L, key, "Focus " .. name, function() return zl.focus_direction(name) end)
        local dx = (name == "left" and -20) or (name == "right" and 20) or 0
        local dy = (name == "up" and -20) or (name == "down" and 20) or 0
        bind(L + A, key, "Resize " .. name, function() return zl.resize_window(dx, dy) end, held)
    end
    for _, name in ipairs({ "up", "down" }) do
        bind(L + S, arrows[name], "Move Window " .. name, function() return zl.move_window_direction(name) end, held)
    end
    for _, entry in ipairs({ { "left", "-1" }, { "right", "+1" } }) do
        local name, delta = entry[1], entry[2]
        local to_workspace = split and split.move_to_workspace(delta)
        bind(L + S, arrows[name], "Move Window to " .. (delta == "-1" and "Previous" or "Next") .. " Workspace", function()
            if spatial() or not to_workspace then return zl.move_window_direction(name) end
            return to_workspace()
        end)
        if to_workspace then bind(L + C + S, arrows[name], "Move Window to " .. (delta == "-1" and "Previous" or "Next") .. " Workspace", to_workspace) end
    end

    bind(L, string.byte("l"), "Next Layout", M.cycle(1, options.announce, options.layouts))
    bind(L + S, string.byte("l"), "Previous Layout", M.cycle(-1, options.announce, options.layouts))
    bind(L, string.byte("["), "Previous Unit", layout("cycle", "prev"))
    bind(L, string.byte("]"), "Next Unit", layout("cycle", "next"))
    bind(L + A, zl.KEY_RETURN, "Layout Primary Action", layout("primary"))
    bind(L + A, zl.KEY_TAB, "Next Focus Region", layout("region", "next"))
    bind(L + A + S, zl.KEY_TAB, "Previous Focus Region", layout("region", "prev"))
    bind(L + C, zl.KEY_RETURN, "Inspect Window", layout("inspect"))
    bind(L + C, zl.KEY_SPACE, "Layout Commands", layout("commands"))
    bind(L + C, zl.KEY_TAB, "Window List", layout("windows"))

    -- Placement and group actions.
    bind(L + A, string.byte("1"), "Park Left", layout("park", "left"))
    bind(L + A, string.byte("2"), "Park Right", layout("park", "right"))
    bind(L + A, string.byte("a"), "Anchor Window", layout("anchor"))
    bind(L + A, string.byte("g"), "New Group", layout("group_new"))
    bind(L + A, string.byte("n"), "New Group", layout("group_new"))
    bind(L + A, string.byte("o"), "Toggle Orientation", layout("orientation"))
    bind(L + A, string.byte("t"), "Attach / Detach", function()
        local context = zl.layout_context()
        if context and context.layout == "workbench" then return zl.layout("detach") end
        return zl.layout("attach", 2)
    end)
    bind(L + A, string.byte("["), "Previous in Group", layout("group_cycle", "prev"))
    bind(L + A, string.byte("]"), "Next in Group", layout("group_cycle", "next"))
    bind(L + A, string.byte("x"), "Swap Windows", layout("swap"))
    bind(L + A, string.byte("u"), "Undo Layout Change", layout("undo"))
    bind(L + A, string.byte("s"), "Toggle Shelves", layout("shelves"))

    -- Canvas zoom: Super+Ctrl+= / - / 0 (the wheel over empty desk too).
    bind(L + C, string.byte("="), "Zoom In", layout("zoom", 1), held)
    bind(L + C, string.byte("-"), "Zoom Out", layout("zoom", -1), held)
    bind(L + C, string.byte("0"), "Reset Zoom", layout("zoom", 0))

    -- Scrolling columns.
    bind(L, string.byte("r"), "Next Column Width", function() return zl.cycle_column_width("next") end)
    bind(L + S, string.byte("r"), "Previous Column Width", function() return zl.cycle_column_width("previous") end)
    for name, key in pairs(arrows) do
        bind(L + A + S, key, "Move Column " .. name, function() return zl.move_column(name) end, held)
        bind(L + C + A, key, "Move Column to Output " .. name, function() return zl.move_column_to_monitor(name) end)
    end

    -- Camera: Super+Ctrl+Shift+arrows pan the view a tenth of a screen.
    bind(L + C + S, arrows.up, "Pan Up", layout("pan", 0, -120), held)
    bind(L + C + S, arrows.down, "Pan Down", layout("pan", 0, 120), held)
end

return M
