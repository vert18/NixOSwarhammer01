-- Programs started with the session.
--
-- A startup handler runs once, when the compositor is ready; it does not run
-- again on a reload. zl.exec_command runs its command with /bin/sh. Otter's
-- wallpaper and bar start from init.lua unless a shell profile starts its own.

zl.on("startup", function()
    -- zl.exec_command("nm-applet --indicator")
end)

-- Variables for every program started after this, such as a cursor theme:
-- zl.set_env("XCURSOR_THEME", "Adwaita")
-- zl.set_env("XCURSOR_SIZE", "24")
