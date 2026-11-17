-- Zoolander config.
--
-- Zoolander copied this directory from its starter config on first start. The
-- files are yours: edit them, or let zoolander-settings edit them. Zoolander
-- never overwrites a file here; delete one and the next start without an
-- init.lua copies the starter's version back.
--
-- Saving init.lua or one of the .lua files beside it reloads the whole config.
-- A reload that fails leaves the previous config running, so a typo cannot
-- lock you out. `zoolanderctl reload` reloads by hand, which edits below a
-- subdirectory (such as shell/) need. Every `zl` function is described in
-- docs/LUA-API.md, and `zoolander --config-schema` lists every setting.
--
-- The config is split across files the way most setups grow:
--   monitors.lua  outputs: modes, positions, scale, HDR and VRR
--   keybinds.lua  keyboard and mouse bindings
--   windows.lua   window and layer rules
--   exec.lua      programs started with the session

-- Layouts --------------------------------------------------------------------

-- The layout new workspaces start with, its main-area ratio and how many
-- windows share the main area. The other built-in layouts are master_stack,
-- grid, monocle, spiral, scrolling, floating, canvas, shelves, islands, lanes,
-- accordion, workbench, pairs and anchors.
zl.set_layout("dwindle", 0.6, 1)

-- Give single workspaces their own layout:
-- zl.set_workspace_layout("3", "scrolling", 0.5)
-- zl.set_workspace_layout("4", "floating")

-- Dwindle splits where the pointer is, rather than always to the right:
-- zl.set_dwindle({ smart_split = true })

-- Column widths that zl.cycle_column_width steps through in Scrolling:
-- zl.set_scrolling({ width_presets = { 1/3, 1/2, 2/3, 1 } })

-- The overview: smaller workspaces closer together show several at once, and
-- a workspace whose windows reach past the screen shows two of them at full
-- size, Super+scroll over it for the rest (0 fits them all):
-- zl.set_overview({ scale = 0.35, gap = 8, visible_windows = 2 })

-- Input ----------------------------------------------------------------------

-- Keyboard layout names left out come from /etc/default/keyboard.
zl.set_keyboard({
    repeat_rate = 50,
    repeat_delay = 300,
    numlock = true,
    -- layout = "gb",
    -- options = "caps:escape",
})

-- follow_mouse: "click" focuses a window when you click it, "focus" when the
-- pointer enters it, "disabled" only through the keyboard.
zl.set_pointer({
    accel_profile = "flat",
    sensitivity = 0,
    follow_mouse = "click",
})

-- Looks ----------------------------------------------------------------------

zl.set_window_style({
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,
    active_border = "#7aa2f7",
    inactive_border = "#414868",
    rounding = 10,
})

-- Server-side titlebars. follow_theme takes colours and fonts from the Otter
-- theme.
zl.set_ssd(false)
-- zl.set_ssd({ enabled = true, follow_theme = true, floating_workspaces_only = true })

zl.set_blur({ enabled = false })
-- zl.set_blur({ enabled = true, size = 8, passes = 2 })

-- Animations -----------------------------------------------------------------

-- One duration and easing for every animation first, then per-animation
-- overrides. Leaves: windows_in, windows_out, windows_move, fade, layers,
-- workspaces, camera, layout and windows_minimize.
zl.set_animations({ enabled = true, duration = 200, easing = "ease_out_cubic" })
zl.set_animation_leaf("windows_in", { duration = 220, easing = "ease_out_cubic", style = "popin", percent = 80 })
zl.set_animation_leaf("workspaces", { duration = 250, easing = "ease_in_out_cubic", style = "slide" })

-- A curve that overshoots and settles back:
-- zl.set_animation_leaf("windows_move", { duration = 300, curve = { x1 = 0.34, y1 = 1.56, x2 = 0.64, y2 = 1 } })

-- Turn every animation off:
-- zl.set_animations_enabled(false)

-- Shell profile --------------------------------------------------------------

-- A shell profile (pika-shell-profiles) installs its bindings, rules and
-- startup programs into shell/. Each fragment is optional; they load before
-- your own files so that a binding or rule of yours replaces theirs. A
-- fragment that is there but fails still stops the config, so its error is
-- reported rather than silently skipped.
local function optional(name)
    local ok, err = pcall(require, name)
    if not ok and not tostring(err):find("not found", 1, true) then
        error(err, 0)
    end
    return ok
end

optional("shell.keybinds")
optional("shell.windows")
local shell_starts_programs = optional("shell.exec")

require("monitors")
require("keybinds")
require("windows")
require("exec")

-- Without a shell profile, start Otter's wallpaper and bar.
if not shell_starts_programs then
    zl.on("startup", function()
        zl.exec_command("otter-wallpaper")
        zl.exec_command("otter-bar")
    end)
end
