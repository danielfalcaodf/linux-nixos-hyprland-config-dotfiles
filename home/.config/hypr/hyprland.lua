-- hyprland.lua — Config principal Hyprland 0.55+ (Lua)
-- Migrado de hyprland.conf (hyprlang) para Lua.
-- Valide com: hyprctl reload && hyprctl configerrors
-- Referência: https://wiki.hypr.land/Configuring/Basics/Start/

-- Carrega paleta Catppuccin Macchiato
local c = dofile(os.getenv("HOME") .. "/.config/hypr/macchiato.lua")


-- =============================================================================
-- MONITORES
-- =============================================================================
-- Veja: https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = 1.6,
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "preferred",
    position = "auto-up",
    scale    = 1.6,
})


-- =============================================================================
-- WORKSPACES POR MONITOR
-- =============================================================================
-- TODO: valide com `hyprctl workspaces` e `hyprctl monitors`

for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i),      monitor = "eDP-1"   })
end
for i = 11, 20 do
    hl.workspace_rule({ workspace = tostring(i),      monitor = "HDMI-A-1" })
end


-- =============================================================================
-- AUTOSTART
-- =============================================================================
-- exec-once = fish -c autostart

hl.on("hyprland.start", function()
    hl.exec_cmd("fish -c autostart")
end)


-- =============================================================================
-- VARIÁVEIS DE AMBIENTE
-- =============================================================================
-- Se usar uwsm, mova para ~/.config/uwsm/env-hyprland para evitar duplicação.
-- TODO: confirme com `hyprctl devices` e `echo $HYPRCURSOR_THEME`

hl.env("HYPRCURSOR_THEME", "Catppuccin-Macchiato-Teal")
hl.env("HYPRCURSOR_SIZE",  "24")
hl.env("XCURSOR_THEME",    "Catppuccin-Macchiato-Teal")
hl.env("XCURSOR_SIZE",     "24")


-- =============================================================================
-- CONFIG PRINCIPAL (general, decoration, animations, dwindle, master, misc)
-- =============================================================================

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border   = c.teal,
            inactive_border = c.surface1,
        },

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled = true,
            size    = 8,
            passes  = 2,
        },

        shadow = {
            enabled      = true,
            range        = 15,
            render_power = 3,
            offset       = { 0, 0 },
            color          = c.teal,
            color_inactive = "0xff" .. c.baseAlpha,
        },

        active_opacity     = 0.7,
        inactive_opacity   = 0.7,
        fullscreen_opacity = 0.7,
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        background_color        = "0x24273a",
    },

    binds = {
        workspace_back_and_forth = true,
    },
})


-- =============================================================================
-- CURVAS E ANIMAÇÕES
-- =============================================================================

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",      enabled = true, speed = 2, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 2, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 2, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "border",       enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "fade",         enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 1, bezier = "default" })


-- =============================================================================
-- INPUT
-- =============================================================================

hl.config({
    input = {
        kb_layout  = "br",
        kb_variant = "abnt2",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,
            tap_and_drag   = true,
        },
    },
})

-- Gesto touchpad 3 dedos horizontal → troca workspace
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


-- =============================================================================
-- POR DISPOSITIVO
-- =============================================================================
-- Confirme o nome exato com: hyprctl devices

hl.device({
    name        = "epic mouse V1",
    sensitivity = -0.5,
})


-- =============================================================================
-- LAYER RULES
-- =============================================================================

hl.layer_rule({
    name  = "blur-logout",
    match = { namespace = "^logout_dialog$" },
    blur  = true,
})


-- =============================================================================
-- WINDOW RULES
-- =============================================================================
-- Confirme classes/títulos com: hyprctl clients

hl.window_rule({
    name  = "mpv-float",
    match = { class = "^mpv$" },
    float   = true,
    opacity = "1.0 1.0 1.0 override",
    size    = { "monitor_w*0.5", "monitor_h*0.5" },
})

hl.window_rule({
    name  = "imv-float",
    match = { class = "^imv$" },
    float   = true,
    opacity = "1.0 1.0 1.0 override",
    size    = { "monitor_w*0.7", "monitor_h*0.7" },
})

-- Atenção: regras baseadas em title dependem do título inicial da janela.
-- Se não funcionar, troque match.title por match.class do leitor de PDF.
hl.window_rule({
    name     = "pdf-float",
    match    = { title = ".*\\.pdf$" },
    float    = true,
    opacity  = "1.0 1.0 1.0 override",
    maximize = true,
})

hl.window_rule({
    name    = "youtube-opaque",
    match   = { title = ".*YouTube - Brave.*" },
    opacity = "1.0 1.0 1.0 override",
})

hl.window_rule({
    name        = "swappy-float",
    match       = { class = "^swappy$" },
    float       = true,
    opacity     = "1.0 1.0 1.0 override",
    center      = true,
    stay_focused = true,
})

-- Scratchpad: terminal dropdown (pyprland)
hl.window_rule({
    name  = "dropterm-scratchpad",
    match = { class = "^terminal-dropterm$" },
    float = true,
    pin   = true,
})

-- Scratchpad: volume side menu (pavucontrol)
hl.window_rule({
    name  = "volume-scratchpad",
    match = { class = "^org.pulseaudio.pavucontrol$" },
    float = true,
    pin   = true,
})


-- =============================================================================
-- KEYBINDINGS
-- =============================================================================

local mainMod = "SUPER"


-- ---------------------------------------------------------------------------
-- Submap: resize
-- ---------------------------------------------------------------------------
-- TODO: valide a API hl.submap() com `hyprctl configerrors`

hl.bind(mainMod .. " + ALT + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("right",  hl.dsp.window.resize({ x =  10, y =   0, relative = true }), { repeating = true })
    hl.bind("left",   hl.dsp.window.resize({ x = -10, y =   0, relative = true }), { repeating = true })
    hl.bind("up",     hl.dsp.window.resize({ x =   0, y = -10, relative = true }), { repeating = true })
    hl.bind("down",   hl.dsp.window.resize({ x =   0, y =  10, relative = true }), { repeating = true })
    hl.bind("l",      hl.dsp.window.resize({ x =  10, y =   0, relative = true }), { repeating = true })
    hl.bind("h",      hl.dsp.window.resize({ x = -10, y =   0, relative = true }), { repeating = true })
    hl.bind("k",      hl.dsp.window.resize({ x =   0, y = -10, relative = true }), { repeating = true })
    hl.bind("j",      hl.dsp.window.resize({ x =   0, y =  10, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)


-- ---------------------------------------------------------------------------
-- Submap: move
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + ALT + M", hl.dsp.submap("move"))

hl.define_submap("move", function()
    hl.bind("right",  hl.dsp.window.move({ direction = "r" }))
    hl.bind("left",   hl.dsp.window.move({ direction = "l" }))
    hl.bind("up",     hl.dsp.window.move({ direction = "u" }))
    hl.bind("down",   hl.dsp.window.move({ direction = "d" }))
    hl.bind("l",      hl.dsp.window.move({ direction = "r" }))
    hl.bind("h",      hl.dsp.window.move({ direction = "l" }))
    hl.bind("k",      hl.dsp.window.move({ direction = "u" }))
    hl.bind("j",      hl.dsp.window.move({ direction = "d" }))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- NOTA: SUPER+ALT+M foi mantido para o submap move.
-- O dispatcher `exit` foi removido desse atalho para evitar conflito.
-- Para sair do Hyprland use wlogout (bind: SUPER+ESCAPE) ou uwsm stop.


-- ---------------------------------------------------------------------------
-- Scratchpads / Pyprland
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + CTRL + T", hl.dsp.exec_cmd("pypr toggle term"))
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("pypr toggle volume"))

hl.bind(mainMod .. " + CTRL + M", hl.dsp.workspace.toggle_special("minimized"))
hl.bind(mainMod .. " + M",        hl.dsp.exec_cmd("pypr toggle_special minimized"))
hl.bind(mainMod .. " + CTRL + E", hl.dsp.exec_cmd("pypr expose"))
hl.bind(mainMod .. " + Z",        hl.dsp.exec_cmd("pypr zoom"))


-- ---------------------------------------------------------------------------
-- Apps
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + T",        hl.dsp.exec_cmd("fish -c kitty_launch"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("Telegram"))
hl.bind(mainMod .. " + B",        hl.dsp.exec_cmd("qutebrowser"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + F",        hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + S",        hl.dsp.exec_cmd("spotify"))
hl.bind(mainMod .. " + Y",        hl.dsp.exec_cmd("pear-desktop"))
hl.bind(mainMod .. " + D",        hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("firejail --apparmor discord"))


-- ---------------------------------------------------------------------------
-- Logout / lock
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + ESCAPE",    hl.dsp.exec_cmd("fish -c wlogout_uniqe"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))


-- ---------------------------------------------------------------------------
-- Screenshots / gravação
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("fish -c screenshot_to_clipboard"))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd("fish -c screenshot_edit"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("fish -c record_screen_gif"))
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd("fish -c record_screen_mp4"))


-- ---------------------------------------------------------------------------
-- Clipboard
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("fish -c clipboard_to_type"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("fish -c clipboard_to_wlcopy"))
hl.bind(mainMod .. " + X",         hl.dsp.exec_cmd("fish -c clipboard_delete_item"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("fish -c clipboard_clear"))


-- ---------------------------------------------------------------------------
-- Bookmarks
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + U",         hl.dsp.exec_cmd("fish -c bookmark_to_type"))
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.exec_cmd("fish -c bookmark_add"))
hl.bind(mainMod .. " + CTRL + U",  hl.dsp.exec_cmd("fish -c bookmark_delete"))


-- ---------------------------------------------------------------------------
-- Color picker
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd('pypr menu "Color picker"'))


-- ---------------------------------------------------------------------------
-- Janelas
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + CTRL + F",  hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.layout("swapsplit"))


-- ---------------------------------------------------------------------------
-- Toggles de sistema
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("fish -c airplane_mode_toggle"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("dunstctl set-paused toggle"))
hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd("fish -c bluetooth_toggle"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("fish -c wifi_toggle"))


-- ---------------------------------------------------------------------------
-- Player
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + p",             hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind(mainMod .. " + bracketright",  hl.dsp.exec_cmd("playerctl next"))
hl.bind(mainMod .. " + bracketleft",   hl.dsp.exec_cmd("playerctl previous"))


-- ---------------------------------------------------------------------------
-- Volume
-- ---------------------------------------------------------------------------

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volumectl -u up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volumectl -u down"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("volumectl toggle-mute"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("volumectl -m toggle-mute"))


-- ---------------------------------------------------------------------------
-- Brilho
-- ---------------------------------------------------------------------------

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("lightctl -D intel_backlight up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("lightctl -D intel_backlight down"))


-- ---------------------------------------------------------------------------
-- Foco (direção)
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down"  }))

-- Cycle next + bring to top
hl.bind(mainMod .. " + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)


-- ---------------------------------------------------------------------------
-- Workspaces — monitor interno (1–10)
-- ---------------------------------------------------------------------------

for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key,               hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,       hl.dsp.window.move({ workspace = i }))
end


-- ---------------------------------------------------------------------------
-- Workspaces — monitor externo (11–20) via ALT
-- ---------------------------------------------------------------------------

for i = 1, 10 do
    local ws  = i + 10
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + ALT + " .. key,               hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + ALT + SHIFT + " .. key,       hl.dsp.window.move({ workspace = ws }))
end


-- ---------------------------------------------------------------------------
-- Scroll entre workspaces
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))


-- ---------------------------------------------------------------------------
-- Mouse move/resize (drag)
-- ---------------------------------------------------------------------------

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
