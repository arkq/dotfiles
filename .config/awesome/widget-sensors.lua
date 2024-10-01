---------------------------------------------------
-- Sensors Widget for Awesome Window Manager
---------------------------------------------------

local naughty = require('naughty')
local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')
local utils = require('utils')

local sensors = {}

function sensors:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function sensors:init(args)

	self.icon = args.icon or utils.lookup_icon("thermometer-symbolic")
	self.icon_high = args.icon_high or utils.lookup_icon("thermometer-high-symbolic")
	self.sensor = args.sensor or "/sys/class/thermal/thermal_zone0/temp"
	self.temp = ""

	self.widget = wibox.widget {
		wibox.widget.textbox(),
		{ wibox.widget.imagebox(self.icon, false),
			layout = wibox.container.margin(_, 0, 0, 1) },
		layout = wibox.layout.fixed.horizontal,
	}

	self.widget:connect_signal('mouse::enter', function ()
		local text = "Temperature " .. self.temp .. "°C"
		self:notify(nil, text, { icon = self.icon, timeout = 0 })
	end)

	self.widget:buttons(awful.util.table.join(
		awful.button({ }, 1, function ()
			awful.spawn.easy_async({ "sensors", "--no-adapter" }, function (out)
				self:notify(nil, out, { timeout = 0 })
			end)
		end)
	))

	self.widget:connect_signal('mouse::leave', function ()
		self:notify_hide()
	end)

	gears.timer {
		timeout   = 10,
		call_now  = true,
		autostart = true,
		callback  = function()

			local v = ""
			local f = io.open(self.sensor, "rb")
			if f then v = f:read "*a" end
			f:close()

			self.temp = tonumber(v) / 1000
			self:update()

		end
	}

	return self
end

function sensors:notify(title, text, preset)
	self.notification = naughty.notify({
		title = title,
		text = text,
		replaces_id = (self.notification or {}).id,
		preset = preset,
	})
end

function sensors:notify_hide()
	if self.notification then
		naughty.destroy(self.notification)
		self.notification = nil
	end
end

function sensors:update()
	self.widget.children[1].text = self.temp .. "°C"
	if self.temp < 80 then
		self.widget.children[2].widget:set_image(self.icon)
	else
		self.widget.children[2].widget:set_image(self.icon_high)
	end
end

return setmetatable(sensors, {
	__call = sensors.new,
})
