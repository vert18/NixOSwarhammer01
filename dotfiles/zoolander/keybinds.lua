local split = require("split_workspaces")

local named_keys = {
    space = zl.KEY_SPACE,
    tab = zl.KEY_TAB,
    ["return"] = zl.KEY_RETURN,
    escape = zl.KEY_ESCAPE,
    left = zl.KEY_LEFT,
    right = zl.KEY_RIGHT,
    up = zl.KEY_UP,
    down = zl.KEY_DOWN,
    print = 0xff61,
    caps_lock = 0xffe5,
    xf86monbrightnessup = 0x1008ff02,
    xf86monbrightnessdown = 0x1008ff03,
    xf86audiolowervolume = 0x1008ff11,
    xf86audiomute = 0x1008ff12,
    xf86audioraisevolume = 0x1008ff13,
    xf86audioplay = 0x1008ff14,
    xf86audiostop = 0x1008ff15,
    xf86audioprev = 0x1008ff16,
    xf86audionext = 0x1008ff17,
    xf86calculator = 0x1008ff1d,
}

local function bind(description, action, options)
    local modifiers = 0
    local key
    for token in description:gmatch("[^+]+") do
        local value = token:match("^%s*(.-)%s*$"):lower()
        if value == "shift" then modifiers = modifiers + zl.MOD_SHIFT
        elseif value == "ctrl" or value == "control" then modifiers = modifiers + zl.MOD_CTRL
        elseif value == "alt" then modifiers = modifiers + zl.MOD_ALT
        elseif value == "super" or value == "logo" then modifiers = modifiers + zl.MOD_LOGO
        else key = value end
    end
    local keysym = named_keys[key] or (#key == 1 and string.byte(key))
    assert(keysym, "unknown key: " .. tostring(key))
    return zl.bind(modifiers, keysym, action, options)
end

local function command(value)
    return function() return zl.exec_command(value) end
end

local locked = { locked = true }
local locked_repeat = { locked = true, repeating = true }

bind("SUPER + SPACE", command("playerctl play-pause"), locked)
bind("SUPER + X", command("playerctl previous"), locked)
bind("SUPER + C", command("playerctl next"), locked)
bind("SUPER + T", command("otter-transcribectl toggle"))
zl.bind_mouse(zl.MOD_LOGO, 272, function() return zl.begin_move() end)
zl.bind_mouse(zl.MOD_LOGO, 273, function() return zl.begin_resize() end)
-- Super+wheel zooms a Canvas; elsewhere it switches workspace.
local layouts = require("layouts")
zl.bind_axis(zl.MOD_LOGO, zl.AXIS_DOWN, layouts.zoom_or(-1, split.cycle_workspaces("next")))
zl.bind_axis(zl.MOD_LOGO, zl.AXIS_UP, layouts.zoom_or(1, split.cycle_workspaces("prev")))
bind("SUPER + SHIFT + B", command("helium"))
bind("SUPER + Return", command("env __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json kitty"))
bind("SUPER + SHIFT + Return", command("foot"))
bind("SUPER + N", command("otter-osd volume-mute-toggle"))
bind("SUPER + SHIFT + V", command("pwvucontrol"))
bind("SUPER + SHIFT + Q", command("otter-logout"))
bind("SUPER + SHIFT + F", command("doublecmd"))
bind("SUPER + Escape", command("zoolanderctl reload && notify-send \"Config Reloaded\""))
bind("SUPER + Z", function() return zl.toggle_special_workspace("") end)
bind("SUPER + S", function() return zl.toggle_floating() end)
bind("SUPER + A", function() return zl.toggle_pin() end)
bind("SUPER + Q", function() return zl.close_window() end)
bind("SUPER + F", function() return zl.toggle_fullscreen() end)
bind("XF86AudioRaiseVolume", command("otter-osd volume-up 5"), locked_repeat)
bind("XF86AudioLowerVolume", command("otter-osd volume-down 5"), locked_repeat)
bind("XF86AudioMute", command("otter-osd volume-mute-toggle"), locked)
bind("XF86MonBrightnessUp", command("otter-osd brightness-up 5"), locked_repeat)
bind("XF86MonBrightnessDown", command("otter-osd brightness-down 5"), locked_repeat)
bind("Caps_Lock", command("otter-osd caps-lock"), locked)
bind("XF86Calculator", command("kcalc"))
bind("XF86AudioPlay", command("playerctl play-pause"), locked)
bind("XF86AudioStop", command("playerctl stop"), locked)
bind("XF86AudioPrev", command("playerctl previous"), locked)
bind("XF86AudioNext", command("playerctl next"), locked)
bind("SUPER + D", command("noctalia msg panel-toggle launcher"))
bind("SUPER + SHIFT + M", function() zl.quit() end)
-- Focus/move/resize arrows, layout cycling, shelves, anchors, inspection and
-- the command sheet: see layouts.lua.
require("layouts").setup({
    split = split,
    -- SUPER + L / SUPER + SHIFT + L announce the new layout through the OSD.
    announce = function(name)
        zl.exec_command("otter-osd message 'Layout: " .. name .. "'")
    end,
})
bind("SUPER + CTRL + left", split.cycle_workspaces("prev"))
bind("SUPER + CTRL + right", split.cycle_workspaces("next"))
bind("SUPER + CTRL + up", function() return zl.focus_monitor("left") end)
bind("SUPER + CTRL + down", function() return zl.focus_monitor("right") end)
for index = 1, split.get_amount_of_workspaces() do
    local key = tostring(index)
    bind("SUPER + " .. key, split.workspace(key))
    bind("SUPER + SHIFT + " .. key, split.move_to_workspace_silent(key))
end
bind("SUPER + tab", function() return zl.toggle_overview() end)
local flameshot_cmd = "pkill -9 flameshot; QT_QPA_PLATFORM=wayland flameshot gui"
bind("Print", command(flameshot_cmd))
bind("SUPER + P", command(flameshot_cmd))

