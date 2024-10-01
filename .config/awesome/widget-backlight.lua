---------------------------------------------------
-- Backlight Widget for Awesome Window Manager
---------------------------------------------------

local gears = require('gears')
local naughty = require('naughty')
local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local math = require('math')
local utils = require('utils')

local backlight = {}

function backlight:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function backlight:init(args)

	self.controler = args.controler or "/sys/class/backlight/intel_backlight"
	self.icon = args.icon or utils.lookup_icon("display-brightness-symbolic")

	self.brightness_current = self.controler .. "/brightness"
	self.brightness_max = self.controler .. "/max_brightness"
	self.brightness = 1.0

	self.widget = wibox.widget {
		{ wibox.widget.imagebox(self.icon, false),
			layout = wibox.container.margin(_, 0, 0, 1),
			opacity = 0.2 },
		{ wibox.container.margin(wibox.widget.imagebox(self.icon, false,
			function (cr, width, height)
				if self.brightness <= 0.5 then
					gears.shape.rectangle(cr, width, (height - 2) * math.sin(self.brightness * math.pi) / 2)
				else
					gears.shape.rectangle(cr, width, (height - 2) * (1 - math.cos((self.brightness - 0.5) * math.pi) / 2))
				end
			end), 0, 0, 2),
			layout = wibox.container.rotate(_, "south") },
		layout = wibox.layout.stack(),
	}

	local f = io.open(self.brightness_max, "rb")
	self.brightness_max_value = tonumber(f:read("*all"))
	f:close()

	self:update(true)

	self.widget:connect_signal('mouse::enter', function() self:hover_show() end)
	self.widget:connect_signal('mouse::leave', function() self:hover_hide() end)

	return self
end

function backlight:hover_show()
	self:notify({ timeout = 0 })
end

function backlight:hover_hide()
	if self.notification then
		naughty.destroy(self.notification)
		self.notification = nil
	end
end

function backlight:notify(preset)
	self.notification = naughty.notify({
		icon = self.icon,
		text = "Brightness " .. math.abs(math.ceil(self.brightness * 100 - 0.5)) .. "%",
		replaces_id = (self.notification or {}).id,
		preset = preset,
	})
end

function backlight:update(startup)
	-- Delay execution until ACPI event will propagate
	gears.timer.start_new(0.05, function ()

		local f = io.open(self.brightness_current, "rb")
		local brightness = tonumber(f:read("*all"))
		f:close()

		self.brightness = brightness / self.brightness_max_value

		self.widget.children[2]:set_visible(false)
		self.widget.children[2]:set_visible(true)

		if not startup then
			self:notify()
		end

	end)
end

return setmetatable(backlight, {
	__call = backlight.new,
})
