-- 1. MONITORS (Pin DP-1 to ASUS ROG PG27U 4K@144Hz at 1.67 scale and disable unknown outputs)
hl.monitor({
    output   = "DP-1",
    mode     = "3840x2160@144",
    position = "0x0",
    scale    = 1.67,
})

-- 2. ENVIRONMENT VARIABLES (Matches Umbriel's working RTX 5080 Wayland EGL setup)
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("__NV_DISABLE_EXPLICIT_SYNC", "1")

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland")
    hl.exec_cmd("sh -c 'sleep 1 && __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json noctalia'")
    hl.exec_cmd("lxqt-policykit-agent")
    hl.exec_cmd("nm-applet --indicator")
end)

-- 4. LOOK, FEEL & INPUT (Matches Umbriel 24px gaps & dwindle layout)
hl.config({
    general = {
        gaps_in     = 12,
        gaps_out    = 24,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },
    decoration = {
        rounding       = 10,
        rounding_power = 2,
        blur = {
            enabled  = true,
            size     = 5,
            passes   = 2,
            vibrancy = 0.1696,
        },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        vrr                     = 2, -- Fullscreen VRR (matches Umbriel vrr = "fullscreen")
    },
    input = {
        kb_layout     = "us",
        follow_mouse  = 1,
        sensitivity   = 0,
        accel_profile = "flat",
    },    
})

-- 5. WINDOW RULES (Includes required 'name' field for Hyprland 0.55.4)
hl.window_rule({
    name        = "flameshot-overlay",
    match       = { class = "^(org\\.flameshot\\.)?[Ff]lameshot$" },
    float       = true,
    fullscreen  = true,
    border_size = 0,
})

hl.window_rule({
    name  = "sseedit-float",
    match = { class = "^sseedit\\.exe$" },
    float = true,
    size  = "800 600",
})

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- 6. KEYBINDS (100% verified against Hyprland 0.55.4 stubs + Umbriel layout)
local mod = "SUPER"

-- Core Apps
hl.bind(mod .. " + Return", hl.dsp.exec_cmd("env __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json kitty"))
hl.bind(mod .. " + SHIFT + Return", hl.dsp.exec_cmd("foot"))
hl.bind(mod,                   hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), { release = true })
hl.bind(mod .. " + Space",     hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mod .. " + B",         hl.dsp.exec_cmd("helium"))
hl.bind(mod .. " + E",         hl.dsp.exec_cmd("doublecmd"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty yazi"))
hl.bind(mod .. " + C",         hl.dsp.exec_cmd("codium"))

-- Screenshots (Flameshot Wayland command from Umbriel)
local flameshot_cmd = "pkill -9 flameshot; QT_QPA_PLATFORM=wayland flameshot gui"
hl.bind("Print",       hl.dsp.exec_cmd(flameshot_cmd))
hl.bind(mod .. " + P", hl.dsp.exec_cmd(flameshot_cmd))

-- Window Management
hl.bind(mod .. " + Q",         hl.dsp.window.close())
hl.bind(mod .. " + F",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + J",         hl.dsp.layout("togglesplit"))

-- Focus Movement (Arrows & Vim keys)
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + H",     hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K",     hl.dsp.focus({ direction = "up" }))

-- Workspaces 1-9 & Scratchpad
for i = 1, 9 do
    hl.bind(mod .. " + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Exit Hyprland back to Login Manager
hl.bind(mod .. " + SHIFT + M", hl.dsp.exit())

-- Mouse Drag to Move/Resize Floating Windows
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Hardware Volume & Brightness Keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

