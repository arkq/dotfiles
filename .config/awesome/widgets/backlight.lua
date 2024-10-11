---------------------------------------------------
-- Backlight Widget for Awesome Window Manager
---------------------------------------------------

local beautiful = require('beautiful')
local gears = require('gears')
local math = require('math')
local naughty = require('naughty')
local utils = require('utils')
local wibox = require('wibox')

local widget = {}

function widget:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function widget:init(args)

	self.controler = args.controler or "/sys/class/backlight/intel_backlight"
	self.brightness_current = self.controler .. "/brightness"
	self.brightness_max = self.controler .. "/max_brightness"
	self.brightness_max_value = 1.0
	self.brightness = 1.0

	self.icon = utils.lookup_icon("display-brightness-symbolic", beautiful.fg_normal)

	self.image_bg = wibox.widget({
		widget = wibox.widget.imagebox,
		image = self.icon,
	})

	self.image_fg = wibox.widget({
		widget = wibox.widget.imagebox,
		image = self.icon,
		clip_shape = function (cr, width, height)
			gears.shape.rectangle(cr, width, height * self.brightness)
		end,
	})

	-- Compose top-level widget
	self.widget = wibox.widget({
		{ self.image_bg,
			layout = wibox.container.margin,
			top = 2, bottom = 2,
			opacity = 0.2 },
		{ { self.image_fg,
				layout = wibox.container.margin,
				top = 2, bottom = 2 },
			layout = wibox.container.mirror,
			reflection = { vertical = true } },
		layout = wibox.layout.stack,
	})

	local f = io.open(self.brightness_max, "rb"); if f then
		self.brightness_max_value = tonumber(f:read("*all"))
		f:close()
	end

	self:update(true)

	return self
end

function widget:notify(preset)
	self.notification = naughty.notify({
		icon = self.icon,
		text = "Brightness " .. math.abs(math.ceil(self.brightness * 100 - 0.5)) .. "%",
		replaces_id = (self.notification or {}).id,
		preset = preset,
	})
end

function widget:update(startup)
	-- Delay execution until ACPI event will propagate
	gears.timer.start_new(0.05, function ()

		local f = io.open(self.brightness_current, "rb")
		if not f then return end

		local brightness = tonumber(f:read("*all"))
		f:close()

		self.brightness = brightness / self.brightness_max_value

		self.image_fg:set_visible(false)
		self.image_fg:set_visible(true)

		if not startup then
			self:notify()
		end

	end)
end

return setmetatable(widget, {
	__call = widget.new,
})
