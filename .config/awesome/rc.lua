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
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
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

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.magnifier,
    awful.layout.suit.tile.top,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.right,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.corner.nw,
}
-- }}}

-- {{{ Wibar
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()
require("widgets/calendar")(mytextclock)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
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
                    awful.button({ }, 8, function(t) awful.tag.viewprev(t.screen) end))

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     -- Use touchpad three-finger swipes for switching tags
                     awful.button({ }, 9, function(c) awful.tag.viewnext(c.screen) end),
                     awful.button({ }, 8, function(c) awful.tag.viewprev(c.screen) end))

local myvseparator = wibox.widget.separator({
    orientation = "vertical",
    color = beautiful.border_focus,
    forced_width = 15,
    span_ratio = 0.7,
})

local mysystray = wibox.widget.systray()
local mysensors = require("widgets/sensors")()
local mybattery = require("widgets/battery")()
local mybacklight = require("widgets/backlight")()
local mytouchpad = require("widgets/touchpad")({ enabled = true })
local mypowermenu = require("widgets/powermenu")({
    cb_lock_screen = locker,
    cb_system_suspend = function() awful.spawn("loginctl suspend") end,
    cb_system_restart = function() awful.spawn("loginctl reboot") end,
    cb_system_poweroff = function() awful.spawn("loginctl poweroff") end,
})

awful.screen.connect_for_each_screen(function(s)

    if s.index ~= 1 then
        -- Configure external screen to use full-screen layout only.
        awful.tag({ "1" }, s, awful.layout.suit.max.fullscreen)
        return
    end

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Remove tooltip from the layoutbox widget.
    s.mylayoutbox._layoutbox_tooltip:remove_from_object(s.mylayoutbox)

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
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
            mysensors.widget,
            myvseparator,
            mybattery.widget,
            myvseparator,
            mybacklight.widget,
            myvseparator,
            mytouchpad.widget,
            myvseparator,
            mypowermenu.widget,
            myvseparator,
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    -- Use touchpad three-finger swipes for switching tags
    awful.button({ }, 9, awful.tag.viewnext),
    awful.button({ }, 8, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
local globalkeys = gears.table.join(

    -- System shortcuts
    awful.key({ modkey,           }, "h",      hotkeys_popup.show_help,
              {description = "show help", group = "awesome"}),
    awful.key({ modkey,           }, "q",      launcher,
              {description = "show launcher", group = "awesome"}),
    awful.key({ modkey,           }, "l",      locker,
              {description = "lock screen", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "r",      awesome.restart,
              {description = "restart", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit,
              {description = "quit", group = "awesome"}),

    -- Screen capture
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

    -- Standard programs
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal)              end,
              {description = "terminal", group = "awesome: launcher"}),
    awful.key({ modkey, "Shift"   }, "Return",
        function ()
            awful.spawn(terminal .. " -ssc +sb -name MC -e /usr/bin/mc")
        end,
        {description = "file explorer", group = "awesome: launcher"}),

    -- Backlight control
    awful.key({                   }, "XF86MonBrightnessUp",   function () mybacklight:update() end),
    awful.key({                   }, "XF86MonBrightnessDown", function () mybacklight:update() end),

    -- Display control
    awful.key({                   }, "XF86Display", function () awful.spawn("lxrandr") end),

    -- Touchpad control
    awful.key({                   }, "XF86TouchpadOn",  function () mytouchpad:on() end),
    awful.key({                   }, "XF86TouchpadOff", function () mytouchpad:off() end),

    -- Volume control (handled by ACPI)
    awful.key({                   }, "XF86AudioMute",        function () end),
    awful.key({                   }, "XF86AudioLowerVolume", function () end),
    awful.key({                   }, "XF86AudioRaiseVolume", function () end),

    -- Layout
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

    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "awesome: client"})

)

local clientkeys = gears.table.join(
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
        {description = "increase opacity", group = "awesome: client"})
)

-- Bind function key numbers to tags.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "F" .. i,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "F" .. i,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "F" .. i,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "F" .. i,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end)
    )
end

globalkeys = gears.table.join(globalkeys,
    awful.key({ modkey }, "Escape", awful.tag.history.restore)
)

local clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = (awful.placement.under_mouse + awful.placement.no_offscreen),
                     size_hints_honor = false,
     }
    },

    -- Vivaldi with custom decorations.
    { rule = { class = "Vivaldi-stable" },
      properties = {
        titlebars_enabled = false } },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
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
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
          "Picture in Picture",  -- Opera Video Pop-Up.
          "Picture in picture",  -- Vivaldi Video Pop-Up.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Finally launch some applications :)
require("autostart")
