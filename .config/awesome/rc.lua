-- Awesome WM configuration
-- vim: expandtab:sw=4:ts=8:sts=4

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- {{{ Variable definitions
-- Themes define colors, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.font = "Hack Nerd Font 10"
beautiful.notification_icon_size = 48
beautiful.tasklist_plain_task_name = true

-- This is used later as the default terminal and editor to run.
local terminal = "urxvtc"
local editor = os.getenv("EDITOR") or "vi"
local editor_cmd = terminal .. " -e " .. editor

-- Implementation of some common WM functionalities
local function launcher()
    awful.spawn("rofi -modi drun -show drun -show-icons -theme dmenu-custom")
end
local function locker()
    awful.spawn("alock -b shade -c glyph -i frame")
end

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"

-- {{{ Tag layout
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.magnifier,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.right,
        awful.layout.suit.tile.top,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.corner.nw,
    })
end)
-- }}}

-- {{{ Wibar

-- Vertical separator for widgets
local myvseparator = wibox.widget.separator({
    orientation = "vertical",
    color = beautiful.border_focus,
    forced_width = 15,
    span_ratio = 0.7,
})

-- Create a textclock widget
local mytextclock = wibox.widget.textclock()
-- Add on-hover calendar to the clock widget
require("widgets/calendar")(mytextclock)

local mysystray = wibox.widget.systray()
local mycpu = require("widgets/cpu")()
local mysensors = require("widgets/sensors")()
local mybattery = require("widgets/battery")()
local mybacklight = require("widgets/backlight")()
local mytouchpad = require("widgets/touchpad")({ enabled = true })
local myvolume = require("widgets/volume")()
local mypowermenu = require("widgets/powermenu")({
    cb_lock_screen = locker,
    cb_system_suspend = function() awful.spawn("loginctl suspend") end,
    cb_system_restart = function() awful.spawn("loginctl reboot") end,
    cb_system_poweroff = function() awful.spawn("loginctl poweroff") end,
})

screen.connect_signal("request::desktop_decoration", function(s)

    if s.index ~= 1 then
        -- Configure external screen to use full-screen layout only.
        awful.tag({ "1" }, s, awful.layout.suit.max.fullscreen)
        return
    end

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
            awful.button({ }, 5, function () awful.layout.inc(-1) end),
        }
    }
    -- Remove tooltip from the layoutbox widget.
    s.mylayoutbox._layoutbox_tooltip:remove_from_object(s.mylayoutbox)

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                                            if client.focus then
                                                client.focus:toggle_tag(t)
                                            end
                                        end),
             -- Use touchpad three-finger swipes for switching tags
            awful.button({ }, 9, function(t) awful.tag.viewnext(t.screen) end),
            awful.button({ }, 8, function(t) awful.tag.viewprev(t.screen) end),
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            -- Use touchpad three-finger swipes for switching tags
            awful.button({ }, 9, function(c) awful.tag.viewnext(c.screen) end),
            awful.button({ }, 8, function(c) awful.tag.viewprev(c.screen) end),
        }
    }

    -- Create the wibox
    s.mywibox = awful.wibar {
        position = "top",
        screen   = s,
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                mysystray,
                myvseparator,
                mycpu.widget,
                myvseparator,
                mysensors.widget,
                myvseparator,
                mybattery.widget,
                myvseparator,
                mybacklight.widget,
                myvseparator,
                mytouchpad.widget,
                myvseparator,
                myvolume.widget,
                myvseparator,
                mypowermenu.widget,
                myvseparator,
                mytextclock,
                s.mylayoutbox,
            },
        }
    }
end)

-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
    -- Use touchpad three-finger swipes for switching tags
    awful.button({ }, 9, awful.tag.viewnext),
    awful.button({ }, 8, awful.tag.viewprev)
})
-- }}}

-- {{{ Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "h", hotkeys_popup.show_help,
              {description = "show help", group = "awesome"}),
    awful.key({ modkey,           }, "q", launcher,
              {description = "show launcher", group = "awesome"}),
    awful.key({ modkey,           }, "l", locker,
              {description = "lock screen", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "r", awesome.restart,
              {description = "restart", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit", group = "awesome"}),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "execute lua", group = "awesome"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "terminal", group = "awesome: launcher"}),
    awful.key({ modkey, "Shift"   }, "Return",
        function ()
            awful.spawn(terminal .. " -ssc +sb -name MC -e /usr/bin/mc")
        end,
        {description = "file explorer", group = "awesome: launcher"}),
})

-- Screen capture
awful.keyboard.append_global_keybindings({
    awful.key({                   }, "Print",
        function ()
            local filename = "screenshot-" .. os.date("%Y%m%d-%H%M%S") .. ".png"
            awful.spawn("import -window root +repage " .. os.getenv("HOME") .. "/" .. filename)
            naughty.notify({ title = "Screen captured", text = "~/" .. filename })
            end,
        {description = "capture screen", group = "awesome: capture"}),
    awful.key({ modkey,           }, "Print",
        function ()
            local filename = "screenshot-" .. os.date("%Y%m%d-%H%M%S") .. ".png"
            awful.spawn("import -frame +repage " .. os.getenv("HOME") .. "/" .. filename)
            naughty.notify({ title = "Screen captured", text = "~/" .. filename })
        end,
        {description = "capture screen region", group = "awesome: capture"}),
})

-- Multimedia keys
awful.keyboard.append_global_keybindings({
    awful.key({                   }, "XF86MonBrightnessUp",   function () mybacklight:update() end),
    awful.key({                   }, "XF86MonBrightnessDown", function () mybacklight:update() end),
    awful.key({                   }, "XF86Display", function () awful.spawn("lxrandr") end),
    awful.key({                   }, "XF86TouchpadOn",  function () mytouchpad:on() end),
    awful.key({                   }, "XF86TouchpadOff", function () mytouchpad:off() end),
    awful.key({                   }, "XF86AudioMute",        function () end),
    awful.key({                   }, "XF86AudioLowerVolume", function () end),
    awful.key({                   }, "XF86AudioRaiseVolume", function () end),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "awesome: client"})

})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "=",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "awesome: layout"}),
    awful.key({ modkey,           }, "-",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "awesome: layout"}),
    awful.key({ modkey, "Shift"   }, "=",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "awesome: layout"}),
    awful.key({ modkey, "Shift"   }, "-",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "awesome: layout"}),
    awful.key({ modkey, "Control" }, "=",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "awesome: layout"}),
    awful.key({ modkey, "Control" }, "-",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "awesome: layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "awesome: layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "awesome: layout"}),
})

awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey,           }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "awesome: client"}),
        awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
                  {description = "close", group = "awesome: client"}),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                  {description = "toggle floating", group = "awesome: client"}),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                  {description = "move to master", group = "awesome: client"}),
        awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
                  {description = "move to screen", group = "awesome: client"}),
        awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
                  {description = "toggle keep on top", group = "awesome: client"}),
        awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky          end,
                  {description = "toggle sticky", group = "awesome: client"}),
        awful.key({ modkey,           }, "n",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "awesome: client"}),
        awful.key({ modkey,           }, "m",
            function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "awesome: client"}),
        awful.key({ modkey, "Control" }, "m",
            function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end ,
            {description = "(un)maximize vertically", group = "awesome: client"}),
        awful.key({ modkey, "Shift"   }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end ,
            {description = "(un)maximize horizontally", group = "awesome: client"}),
        awful.key({ modkey,           }, "9", function (c) c.opacity = c.opacity - 0.1           end,
            {description = "decrease opacity", group = "awesome: client"}),
        awful.key({ modkey,           }, "0", function (c) c.opacity = c.opacity + 0.1           end,
            {description = "increase opacity", group = "awesome: client"}),
    })
end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.under_mouse + awful.placement.no_offscreen,
            size_hints_honor = false,
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "mpv",
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xpad",
                "xtightvncviewer",
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
                "Picture in Picture",  -- Opera Video Pop-Up.
                "Picture in picture",  -- Vivaldi Video Pop-Up.
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }

    -- Add title bars to dialogs.
    ruled.client.append_rule {
        id         = "titlebars",
        rule_any   = { type = { "dialog" } },
        properties = { titlebars_enabled = true      }
    }

    -- Vivaldi with custom decorations.
    ruled.client.append_rule {
        rule = { class = "Vivaldi-stable" },
        properties = { titlebars_enabled = false },
    }
end)
-- }}}

-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the title bar
    local buttons = {
        awful.button({ }, 1, function()
            c:activate { context = "titlebar", action = "mouse_move"  }
        end),
        awful.button({ }, 3, function()
            c:activate { context = "titlebar", action = "mouse_resize"}
        end),
    }
    -- widgets for the title bar
    awful.titlebar(c).widget = {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                halign = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)
-- }}}

-- {{{ Notifications
ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)
naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)
-- }}}

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)

-- Finally launch some applications :)
require("autostart")
