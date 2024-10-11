---------------------------------------------------
-- Power Menu Widget for Awesome Window Manager
---------------------------------------------------

local awful = require('awful')
local beautiful = require('beautiful')
local utils = require('utils')
local wibox = require('wibox')

local widget = {}

function widget:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function widget:init(args)

	local cb_lock_screen = args.cb_lock_screen or function() end
	local cb_system_suspend = args.cb_system_suspend or function() end
	local cb_system_restart = args.cb_system_restart or function() end
	local cb_system_poweroff = args.cb_system_poweroff or function() end

	local icons = {
		reload = utils.lookup_icon("system-restart-symbolic", beautiful.fg_normal),
		quit = utils.lookup_icon("system-log-out-symbolic", beautiful.fg_normal),
		lock_screen = utils.lookup_icon("system-lock-screen-symbolic", beautiful.fg_normal),
		system_suspend = utils.lookup_icon("system-suspend-symbolic", beautiful.fg_normal),
		system_restart = utils.lookup_icon("system-restart-symbolic", beautiful.fg_normal),
		system_poweroff =  utils.lookup_icon("system-shutdown-symbolic", beautiful.fg_normal),
	}

	-- Compose top-level widget
	self.widget = wibox.widget({
		wibox.widget.imagebox(icons.system_poweroff),
		layout = wibox.container.margin,
		top = 2, bottom = 2,
	})

	local menu = awful.menu({
		theme = { width = 120 },
		items = {
			{ "reload", function() awesome.restart() end, icons.reload },
			{ "quit", function() awesome.quit() end, icons.quit },
			{ "---" },
			{ "lock screen", cb_lock_screen, icons.lock_screen },
			{ "suspend", cb_system_suspend, icons.system_suspend },
			{ "restart", cb_system_restart, icons.system_restart },
			{ "power off", cb_system_poweroff, icons.system_poweroff },
		},
	})

	self.widget:buttons(awful.util.table.join(
		awful.button({ }, 1, function()
			menu:toggle({ coords = {
				x = mouse.current_widget_geometry.x - 8,
				y = mouse.current_widget_geometry.height,
			} })
		end)
	))

	return self
end

return setmetatable(widget, {
	__call = widget.new,
})
