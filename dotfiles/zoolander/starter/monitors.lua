-- Outputs: mode, position, scale, and how each presents (VRR, HDR).
--
-- Without a rule an output keeps the mode the driver picks and is placed
-- automatically. `zoolanderctl monitors` lists the connector names (DP-1,
-- HDMI-A-1, eDP-1) and the modes each output offers.

-- Presentation for every output. A field in an output's rule below beats it.
--   vrr: "off", "always", "fullscreen" (while one window covers the output)
--        or "fullscreen_game" (only while that window is a game)
--   hdr: "off", "auto" (while HDR content is on screen) or "always"
zl.set_presentation({
    vrr = "off",
    hdr = "auto",
    allow_tearing = false,
})

-- One rule per output. Every field is optional; leave one out to keep what
-- the output has now.
-- zl.output_rule({
--     output = "DP-1",
--     width = 2560, height = 1440, refresh = 165,  -- all three or none
--     x = 0, y = 0,                                -- top-left, in logical pixels
--     scale = 1.25,
--     transform = "normal",                        -- "90", "180", "270", "flipped", ...
--     primary = true,                              -- where X11 apps and new popups open
--     vrr = "fullscreen_game",
-- })
-- zl.output_rule({ output = "HDMI-A-1", enabled = false })

-- A wide-gamut monitor in its native colour mode that looks oversaturated
-- in SDR: map colour into the primaries its EDID reports. Not for a monitor
-- in its own sRGB mode.
-- zl.output_rule({ output = "DP-1", color_profile = "edid" })

-- HDR per output. bitdepth 10 also scans SDR out at 10 bits; the sdr_*
-- fields set how SDR content looks while the output is in HDR; the
-- luminances (nits) replace what the display's EDID reports.
-- zl.output_rule({
--     output = "DP-2",
--     hdr = "always",
--     bitdepth = 10,
--     sdr_max_luminance = 203,   -- SDR white
--     sdr_brightness = 1,
--     sdr_saturation = 1,
--     sdr_eotf = "gamma22",      -- "srgb", "gamma22" or "gamma24"
--     max_luminance = 1000,      -- tone-mapping peak
--     min_luminance = 0.005,
--     max_avg_luminance = 400,
-- })

-- HDR can also be flipped at runtime for one monitor with
-- zl.set_presentation(options, "focused"); keybinds.lua has an example.
