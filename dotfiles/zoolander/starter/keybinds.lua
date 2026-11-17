-- Keyboard and mouse bindings.
--
-- zl.bind(modifiers, key, function, options). Modifiers are zl.MOD_LOGO
-- (Super), zl.MOD_SHIFT, zl.MOD_CTRL and zl.MOD_ALT, added together. A key
-- is one character ("q"), a zl.KEY_* constant or a numeric XKB keysym. The
-- description shows in key cheat sheets. options.locked keeps a binding
-- working on the lock screen; options.repeating repeats it while held.
-- Binding a key again replaces the earlier binding.

local SUPER, SHIFT = zl.MOD_LOGO, zl.MOD_SHIFT

zl.bind(SUPER, zl.KEY_RETURN, function() zl.exec_command("otter-term") end, { description = "Terminal" })
zl.bind(SUPER, "d", function() zl.exec_command("otter-launcher") end, { description = "Application launcher" })
zl.bind(SUPER, "q", function() zl.close_window() end, { description = "Close window" })
zl.bind(SUPER, "f", function() zl.toggle_fullscreen() end, { description = "Fullscreen" })
zl.bind(SUPER, "v", function() zl.toggle_floating() end, { description = "Float window" })
zl.bind(SUPER, zl.KEY_TAB, function() zl.toggle_overview() end, { description = "Overview" })
zl.bind(SUPER + SHIFT, "q", function() zl.exec_command("otter-logout") end, { description = "Log out" })

-- Focus with Super+arrow; move the window with Super+Shift+arrow.
for _, direction in ipairs({ "left", "right", "up", "down" }) do
    local key = zl["KEY_" .. direction:upper()]
    zl.bind(SUPER, key, function() zl.focus_direction(direction) end, { description = "Focus " .. direction })
    zl.bind(SUPER + SHIFT, key, function() zl.move_window_direction(direction) end, { description = "Move window " .. direction })
end

-- Super+1..9 shows that workspace; Super+Shift+1..9 sends the window there.
for i = 1, 9 do
    local name = tostring(i)
    zl.bind(SUPER, name, function() zl.workspace(name) end, { description = "Workspace " .. name })
    zl.bind(SUPER + SHIFT, name, function() zl.move_window_workspace(name) end, { description = "Move to workspace " .. name })
end

-- Super+left drag moves a window, Super+right drag resizes it.
zl.bind_mouse(SUPER, 272, function() zl.begin_move() end, { description = "Move window" })
zl.bind_mouse(SUPER, 273, function() zl.begin_resize() end, { description = "Resize window" })

-- Super+scroll down opens the overview; the top-left hot corner too:
-- zl.bind_axis(SUPER, zl.AXIS_DOWN, function() zl.toggle_overview() end)
-- zl.bind_hot_corner(0, zl.CORNER_TOP_LEFT, function() zl.toggle_overview() end)

-- Turn HDR on or off on the monitor you are using. This lasts until the next
-- reload; set hdr in monitors.lua to keep it.
-- zl.bind(SUPER + SHIFT, "h", function() zl.toggle_hdr() end, { description = "Toggle HDR on this monitor" })
-- The same by hand, for any presentation field:
-- zl.bind(SUPER + SHIFT, "h", function()
--     local p = zl.presentation("focused")
--     zl.set_presentation({ hdr = p.hdr == "off" and "always" or "off" }, "focused")
-- end, { description = "Toggle HDR on this monitor" })

-- Media keys work on the lock screen and repeat while held:
-- zl.bind(0, 0x1008ff13, function() zl.exec_command("wpctl set-volume @DEFAULT_SINK@ 5%+") end,
--     { description = "Raise volume", locked = true, repeating = true })
