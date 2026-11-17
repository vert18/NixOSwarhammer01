local function run(command)
    assert(zl.exec_command(command))
end

zl.on("startup", function()
    run("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    run("systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    run("sh -c 'sleep 1 && __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json noctalia' &")
    run("lxqt-policykit-agent &")
    run("nm-applet --indicator &")
end)

