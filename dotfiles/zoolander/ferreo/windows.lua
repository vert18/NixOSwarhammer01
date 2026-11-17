local function rule(match, pattern, float, dim_around, no_animation, idle_inhibit, fullscreen, content)
  assert(zl.add_window_rule(match, pattern, float or false, dim_around or false, no_animation or false, idle_inhibit or false, fullscreen or false, content))
end

rule("app_id", "^(launcher)$", true)
rule("title", "^(Sharing)$", true)
rule("app_id", "^(gamescope)$", false, false, false, true)
rule("app_id", "^(steam_app_.*)$", false, false, false, false, true)
rule("app_id", "^(.*\\.exe)$", false, false, false, false, false, "game")
rule("app_id", "^(com.github.pikaos-linux.pikmanupdatemanager)$", true)
rule("app_id", "^(io.github.lact-linux)$", true)
rule("app_id", "^(com.saivert.pwvucontrol)$", true)
rule("title", "^(gsr ui)$", false, false, true)
zl.add_layer_no_animation_rule("^(wayfreeze)$")
