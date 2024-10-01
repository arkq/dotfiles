---------------------------------------------------
-- Touchpad Widget for Awesome Window Manager
---------------------------------------------------

local naughty = require('naughty')
local wibox = require('wibox')
local utils = require('utils')

local touchpad = {}

function touchpad:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function touchpad:init(args)

	self.enabled = args.enabled
	self.icon_on = args.icon_on or utils.lookup_icon("touchpad-enabled-symbolic")
	self.icon_off = args.icon_off or utils.lookup_icon("touchpad-disabled-symbolic")

	self.widget = wibox.widget {
		{ wibox.widget.imagebox(self.enabled and self.icon_on or self.icon_off, false),
			layout = wibox.container.margin(_, 0, 0, 1)},
		layout = wibox.layout.fixed.horizontal,
	}

	self.widget:connect_signal('mouse::enter', function() self:hover_show() end)
	self.widget:connect_signal('mouse::leave', function() self:hover_hide() end)

	return self
end

function touchpad:hover_show()
	self:notify({ timeout = 0 })
end

function touchpad:hover_hide()
	if self.notification then
		naughty.destroy(self.notification)
		self.notification = nil
	end
end

function touchpad:notify(preset)
	self.notification = naughty.notify({
		icon = self.enabled and self.icon_on or self.icon_off,
		text = "Touchpad " .. (self.enabled and "enabled" or "disabled"),
		replaces_id = (self.notification or {}).id,
		preset = preset,
	})
end

function touchpad:on()
	self.enabled = true
	self.widget.children[1].widget:set_image(self.icon_on)
	self:notify()
end

function touchpad:off()
	self.enabled = false
	self.widget.children[1].widget:set_image(self.icon_off)
	self:notify()
end

return setmetatable(touchpad, {
	__call = touchpad.new,
})
