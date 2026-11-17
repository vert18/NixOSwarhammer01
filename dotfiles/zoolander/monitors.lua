-- One-off native conversion of ~/.config/hypr/monitors.lua. HDR auto policy
-- in init.lua selects 10-bit scanout when HDR content requires it.

if ZL_AMD_VM_TEST then
    zl.output_rule({ output = "HDMI-A-1", width = 1920, height = 1080, refresh = 240, x = 0, y = 0, scale = 1 })
    zl.output_rule({ output = "DP-1", width = 1920, height = 1080, refresh = 240, x = 1920, y = 0, scale = 1 })
    return
end

zl.output_rule({
    output = "DP-1",
    width = 3840,
    height = 2160,
    refresh = 120,
    x = 0,
    y = 0,
    scale = 1.67,
})

