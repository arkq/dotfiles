---------------------------------------------------
-- Sensors Widget for Awesome Window Manager
---------------------------------------------------

local awful = require('awful')
local beautiful = require("beautiful")
local gears = require('gears')
local naughty = require('naughty')
local utils = require('utils')
local wibox = require('wibox')

local widget = {}

function widget:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function widget:init(args)

	self.sensor = args.sensor or "/sys/class/thermal/thermal_zone0/temp"
	self.delay = args.delay or 10
	self.temp = 30

	self.icons = {
		normal = utils.lookup_icon("thermometer-symbolic", beautiful.fg_normal),
		high = utils.lookup_icon("thermometer-high-symbolic", beautiful.bg_urgent),
	}

	self.image = wibox.widget({
		widget = wibox.widget.imagebox,
		image = self:get_icon(),
	})

	self.label = wibox.widget({
		widget = wibox.widget.textbox,
	})

	-- Compose top-level widget
	self.widget = wibox.widget({
		{ self.image,
			layout = wibox.container.margin,
			top = 2, bottom = 2, right = 2 },
		self.label,
		layout = wibox.layout.fixed.horizontal,
	})

	self.widget:buttons(awful.util.table.join(
		awful.button({ }, 1, function ()
			awful.spawn.easy_async({ "sensors", "--no-adapter" }, function (out)
				local info = out:match("^%s*(.-)%s*$")
				self:notify(nil, info, { timeout = 0 })
			end)
		end)
	))

	self.widget:connect_signal('mouse::leave', function ()
		self:notify_hide()
	end)

	gears.timer {
		timeout   = self.delay,
		call_now  = true,
		autostart = true,
		callback  = function()

			local v = ""
			local f = io.open(self.sensor, "rb"); if f then
				v = f:read("*all")
				f:close()
			end

			self.temp = tonumber(v) / 1000
			self:update()

		end
	}

	return self
end

function widget:get_icon()
	if self.temp < 80 then
		return self.icons.normal
	else
		return self.icons.high
	end
end

function widget:notify(title, text, preset)
	self.notification = naughty.notify({
		title = title,
		text = text,
		replaces_id = (self.notification or {}).id,
		preset = preset,
	})
end

function widget:notify_hide()
	if self.notification then
		naughty.destroy(self.notification)
		self.notification = nil
	end
end

function widget:update()
	self.label.text = self.temp .. "°C"
	self.image:set_image(self:get_icon())
end

return setmetatable(widget, {
	__call = widget.new,
})
