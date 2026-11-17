-- The author's desktop profile: two monitors with split workspaces, running
-- the Otter shell.

local split = require("split_workspaces")
require("monitors")

zl.set_layout("dwindle", 0.6, 1)
zl.set_dwindle({
    preserve_split = false,
    smart_split = false,
    smart_resizing = true,
    force_split = 0,
    split_width_multiplier = 1.0,
})
zl.set_keyboard({ repeat_rate = 50, repeat_delay = 300, numlock = true })
zl.set_pointer({ left_handed = false, accel_profile = "flat", follow_mouse = 2 })
zl.set_presentation({ allow_tearing = true, immediate_fullscreen = true, vrr = 2, direct_scanout = false, hdr = "auto" })
zl.set_window_style({
    gaps_in = 3,
    gaps_out = 6,
    border_size = 2,
    active_border = "#dbab96ff",
    active_border_end = "#dbab96ff",
    active_border_angle = 0,
    inactive_border = "#201e1eff",
    inactive_border_end = "#201e1eff",
    inactive_border_angle = 0,
    rounding = 20,
    rounding_power = 4,
    active_opacity = 0.98,
    inactive_opacity = 0.95,
    fullscreen_opacity = 1.0,
    shadow = {
        enabled = false,
        range = 35,
        sharp = 0,
        render_power = 4,
        offset_x = 0,
        offset_y = 12,
        scale = 1.05,
        color = "#00000073",
        color_inactive = "#00000073",
    },
})
split.setup({
    workspace_count = 5,
    monitor_priority = { "DP-3", "DP-2" },
    enable_wrapping = false,
})
zl.set_workspace_layout("3", "scrolling", 0.6, 1)
zl.set_workspace_gesture(true, 3)
zl.set_overview({ axis = "horizontal", rail = "top" })
zl.set_ssd({
    enabled = true,
    border = 2,
    titlebar = 24,
    active_border = "#dbab96ff",
    active_border_end = "#dbab96ff",
    active_border_angle = 0,
    inactive_border = "#201e1eff",
    active_titlebar = "#10151fff",
    inactive_titlebar = "#0b0f17ff",
    show_title = true,
    title_font = "sans-serif",
    title_font_size = 13,
    title_color = "#eaf0faff",
    title_align = "center",
    buttons = {
        { action = "close", side = "right", width = 24, color = "#d75f5fff" },
        { action = "fullscreen", side = "right", width = 24, color = "#5082d2ff" },
    },
})

local no_animation_layers = {
    "^(otter-popup)$",
    "^(otter-logout)$",
    "^(otter-polkit)$",
    "^(otter-screenshot)$",
    "^(otter-shot)$",
    "^(otter-rec)$",
    "^(otter-pick)$",
    "^(selection)$",
    "^(otter-launcher)$",
    "^(otter-wallpaper)$",
    "^(otter-overview)$",
    "^(otter-dock)$",
}
for _, namespace in ipairs(no_animation_layers) do
    zl.add_layer_no_animation_rule(namespace)
end
zl.add_layer_blur_rule("^(otter-polkit)$", 0.5)

zl.set_blur({
    enabled = true,
    size = 2,
    passes = 4,
    noise = 0.02,
    contrast = 1.55,
    brightness = 0.75,
    vibrancy = 0.55,
    vibrancy_darkness = 0.25,
})
zl.set_dim({ inactive = true, strength = 0.1, special = 0.3, around = 0.02 })
zl.set_animations_enabled(true)
local fluent_decel = { x1 = 0.1, y1 = 1, x2 = 0, y2 = 1 }
zl.set_animation_leaf("windows_in", { enabled = true, duration = 400, curve = fluent_decel, style = "slide" })
zl.set_animation_leaf("windows_out", { enabled = true, duration = 400, curve = fluent_decel, style = "slide" })
zl.set_animation_leaf("windows_move", { enabled = true, duration = 400, curve = fluent_decel })
zl.set_animation_leaf("fade", { enabled = true, duration = 400, curve = fluent_decel })
zl.set_animation_leaf("workspaces", { enabled = true, duration = 800, curve = fluent_decel })
zl.set_animation_leaf("layers", { enabled = true, duration = 800, curve = fluent_decel, style = "slide" })
zl.add_layer_animation_rule("^(otter-notifications)$", "slide right")
zl.add_layer_animation_rule("^(otter-osd)$", "slide bottom")

require("env")
require("exec")
require("keybinds")
require("windows")
