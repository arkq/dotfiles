---------------------------------------------------
-- Touchpad Widget for Awesome Window Manager
---------------------------------------------------

local beautiful = require("beautiful")
local naughty = require('naughty')
local utils = require('utils')
local wibox = require('wibox')

local widget = {}

function widget:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function widget:init(args)

	self.enabled = args.enabled or false

	self.icons = {
		on = utils.lookup_icon("touchpad-enabled-symbolic", beautiful.fg_normal),
		off = utils.lookup_icon("touchpad-disabled-symbolic", beautiful.fg_normal),
	}

	self.image = wibox.widget({
		widget = wibox.widget.imagebox,
		image = self:get_icon(),
	})

	-- Compose top-level widget
	self.widget = wibox.widget({
		{ self.image,
			layout = wibox.container.margin,
			top = 2, bottom = 2 },
		layout = wibox.layout.fixed.horizontal,
	})

	return self
end

function widget:get_icon()
	if self.enabled then
		return self.icons.on
	else
		return self.icons.off
	end
end

function widget:notify(preset)
	self.notification = naughty.notify({
		icon = self:get_icon(),
		text = "Touchpad " .. (self.enabled and "enabled" or "disabled"),
		replaces_id = (self.notification or {}).id,
		preset = preset,
	})
end

function widget:on()
	self.enabled = true
	self.image:set_image(self:get_icon())
	self:notify()
end

function widget:off()
	self.enabled = false
	self.image:set_image(self:get_icon())
	self:notify()
end

return setmetatable(widget, {
	__call = widget.new,
})
