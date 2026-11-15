-- 1. MONITOR (Matches Umbriel DP-1: 3840x2160 @ 144Hz, 1.75 scale)
hl.monitor({
    output = "DP-1",
    mode = "3840x2160@144",
    position = "0x0",
    scale = 1.75,
})

-- 2. ENVIRONMENT VARIABLES
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- 3. AUTOSTART (Matches Umbriel autostart + Noctalia shell)
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("lxqt-policykit-agent")
    hl.exec_cmd("nm-applet --indicator")
end)

-- 4. LOOK, FEEL & INPUT (Matches Umbriel 24px gaps & dwindle layout)
hl.config({
    general = {
        gaps_in = 12,
        gaps_out = 24,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        layout = "dwindle",
    },
    decoration = {
        rounding = 8,
        blur = {
            enabled = true,
            size = 5,
            passes = 2,
        },
    },
    misc = {
        vrr = 2, -- Fullscreen VRR (matches Umbriel vrr = "fullscreen")
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
    },
})

-- 5. WINDOW RULES (Flameshot & SSEEdit from Umbriel)
hl.window_rule({
    match = { class = "^(org\\.flameshot\\.)?[Ff]lameshot$" },
    float = true,
    fullscreen = true,
    border_size = 0,
})

hl.window_rule({
    match = { class = "^sseedit\\.exe$" },
    float = true,
    size = { 800, 600 },
})

-- 6. KEYBINDS (Mirrors Umbriel keybinds)
local mod = "SUPER"

-- Core Apps
hl.bind(mod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mod, hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), { release = true })
hl.bind(mod .. " + Space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("helium"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("doublecmd"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty yazi"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd("codium"))

-- Screenshots (Flameshot Wayland command from Umbriel)
local flameshot_cmd = "pkill -9 flameshot; QT_QPA_PLATFORM=wayland flameshot gui"
hl.bind("Print", hl.dsp.exec_cmd(flameshot_cmd))
hl.bind(mod .. " + P", hl.dsp.exec_cmd(flameshot_cmd))

-- Window Management
hl.bind(mod .. " + Q", hl.dsp.window.kill())
hl.bind(mod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "toggle" }))

-- Focus Movement (Arrows & Vim keys)
hl.bind(mod .. " + Left", hl.dsp.window.focus_direction("l"))
hl.bind(mod .. " + Right", hl.dsp.window.focus_direction("r"))
hl.bind(mod .. " + Up", hl.dsp.window.focus_direction("u"))
hl.bind(mod .. " + Down", hl.dsp.window.focus_direction("d"))
hl.bind(mod .. " + H", hl.dsp.window.focus_direction("l"))
hl.bind(mod .. " + L", hl.dsp.window.focus_direction("r"))
hl.bind(mod .. " + K", hl.dsp.window.focus_direction("u"))
hl.bind(mod .. " + J", hl.dsp.window.focus_direction("d"))

-- Workspaces 1-9
for i = 1, 9 do
    hl.bind(mod .. " + " .. i, hl.dsp.workspace.switch(i))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move_to_workspace(i))
end

-- Exit Hyprland back to Login Manager
hl.bind(mod .. " + SHIFT + M", hl.dsp.exit())

-- Mouse Drag to Move/Resize Floating Windows
hl.bind(mod .. " + mouse:272", hl.dsp.window.move_mouse(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize_mouse(), { mouse = true })

-- Hardware Volume & Brightness Keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

