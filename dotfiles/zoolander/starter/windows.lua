-- Window and layer rules.
--
-- zl.add_window_rule(match, pattern, actions) applies actions to the windows
-- it matches. match is "app_id", "title" or "tag" (`zoolanderctl clients`
-- shows each window's). pattern is an exact name, or ^(...)$ in which .* is
-- the only wildcard and \ escapes the next character. Every rule that
-- matches contributes: on/off actions add up, and for single values (content,
-- workspace, sizes) the later rule wins.

-- A helper keeps a run of similar rules short. It takes the actions in the
-- order zl.add_window_rule's positional form does, and its parameters are
-- named after the actions, which lets zoolander-settings edit and delete the
-- rules written through it. Leave out trailing arguments you don't need.
local function rule(match, pattern, float, dim_around, no_animation, idle_inhibit, fullscreen, content, border_size, rounding, shadow, decorate, workspace, follow, confine_cursor, force_game_hdr)
    zl.add_window_rule(match, pattern, float or false, dim_around or false, no_animation or false, idle_inhibit or false, fullscreen or false, content, border_size, rounding, shadow, decorate, workspace, follow or false, confine_cursor or false, force_game_hdr or false)
end

-- Dialog-like apps float: settings, the portal's file picker, volume control
-- and network connections.
rule("app_id", "^(zoolander-settings)$", true)
rule("app_id", "^(xdg-desktop-portal-gtk)$", true)
rule("app_id", "^(com.saivert.pwvucontrol)$", true)
rule("app_id", "^(org.pulseaudio.pavucontrol)$", true)
rule("app_id", "^(nm-connection-editor)$", true)

-- Steam games and gamescope count as games, which vrr = "fullscreen_game"
-- in monitors.lua goes by.
zl.add_window_rule("app_id", "^(steam_app_.*)$", { content = "game" })
zl.add_window_rule("app_id", "^(gamescope)$", { content = "game" })
-- mpv is video, and keeps the screen awake while it is open.
zl.add_window_rule("app_id", "^(mpv)$", { content = "video", idle_inhibit = true })
zl.add_window_rule("title", "^(Picture-in-Picture)$", { float = true })

-- Every window rule action, by example:
--
-- zl.add_window_rule("app_id", "^(org.gnome.Calculator)$", {
--     float = true,            -- open floating, at the size the app asks for
--     dim_around = true,       -- dim everything else while it is open
--     no_animation = true,     -- open and close without animating
--     idle_inhibit = true,     -- keep the screen awake while it is open
--     fullscreen = true,       -- open fullscreen
--     content = "photo",       -- "none", "photo", "video" or "game"
--     border_size = 0,         -- 0..64, over zl.set_window_style's
--     rounding = 0,            -- 0..128, over zl.set_window_style's
--     shadow = false,          -- true or false over the global shadow
--     decorate = false,        -- true or false over server-side titlebars
-- })
--
-- Open on a workspace; follow switches to it with the window.
-- zl.add_window_rule("app_id", "^(discord)$", { workspace = "9", follow = false })
-- A special (scratchpad) workspace, created hidden until
-- zl.toggle_special_workspace("music") shows it.
-- zl.add_window_rule("app_id", "^(spotify)$", { workspace = "special:music" })
--
-- Keep the pointer inside a focused game, so it cannot drift onto another
-- monitor. A game's own pointer lock still wins while it holds one.
-- zl.add_window_rule("app_id", "^(steam_app_.*)$", { confine_cursor = true })
--
-- force_game_hdr tells a game its output is in HDR mode while the output
-- shows SDR, and tone maps the game's HDR back to SDR: gamescope's
-- --hdr-debug-force-support for one window. Proton games also need
-- DXVK_HDR=1 in their launch options (DXVK_HDR=1 %command% in Steam, or
-- PROTON_ENABLE_HDR=1 with GE-Proton): DXVK's Windows side only reads the
-- environment the game started with. Set the game's paper white to about
-- 100 nits.
-- zl.add_window_rule("app_id", "^(steam_app_.*)$", { force_game_hdr = true })
--
-- Match the tag a Wayland app gives a window (xdg-toplevel-tag):
-- zl.add_window_rule("tag", "^(settings)$", { float = true })

-- Layer rules, for bars, launchers and notifications by their namespace:
-- zl.add_layer_blur_rule("^(otter-bar)$", 0.2)          -- blur behind, ignoring alpha below 0.2
-- zl.add_layer_no_animation_rule("^(otter-launcher)$")  -- show and hide at once
-- zl.add_layer_animation_rule("^(otter-notifications)$", "slide right")
