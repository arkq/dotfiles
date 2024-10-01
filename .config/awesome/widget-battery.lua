---------------------------------------------------
-- UPower Battery Widget for Awesome Window Manager
---------------------------------------------------

local lgi = require('lgi')
local UP = lgi.require('UPowerGlib')
local naughty = require('naughty')
local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local math = require('math')
local utils = require('utils')

local function get_level(device)
	return math.ceil(device.percentage - 0.5) .. "%"
end

local function get_level_icon(device)
	return utils.lookup_icon(device.icon_name)
end

local upower = {}

function upower:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function upower:init(args)

	local client = UP.Client:new()
	local device = client:get_display_device()

	if not device.is_present then
		-- Try to find any other working device
		for _, d in ipairs(client:get_devices()) do
			if d.is_present then
				device=d
				break
			end
		end
		if not device.is_present then
			return
		end
	end

	self.widget = wibox.widget {
		wibox.widget.textbox(get_level(device)),
		{ wibox.widget.imagebox(get_level_icon(device), false),
			layout = wibox.container.margin(_, 0, 0, 1) },
		layout = wibox.layout.fixed.horizontal,
	}

	self.widget:connect_signal('mouse::enter', function ()
		local text = "Battery Level " .. get_level(device)
		self:notify(nil, text, { icon = get_level_icon(device), timeout = 0 })
	end)

	self.widget:buttons(awful.util.table.join(
		awful.button({ }, 1, function ()
			self:notify(nil, device:to_text(), { timeout = 0 })
		end)
	))

	self.widget:connect_signal('mouse::leave', function ()
		self:notify_hide()
	end)

	device.on_notify = function (device)
		if device.warning_level == UP.DeviceLevel.LOW or
				device.warning_level == UP.DeviceLevel.CRITICAL or
				device.warning_level == UP.DeviceLevel.ACTION or
				device.warning_level == UP.DeviceLevel.LAST then
			local text = "Battery Level " .. get_level(device)
			self:notify("Low Battery", text, naughty.config.presets.critical)
		end
		self.widget.children[1].text = get_level(device)
		self.widget.children[2].widget:set_image(get_level_icon(device))
	end

	return self
end

function upower:notify(title, text, preset)
	self.notification = naughty.notify({
		title = title,
		text = text,
		replaces_id = (self.notification or {}).id,
		preset = preset,
	})
end

function upower:notify_hide()
	if self.notification then
		naughty.destroy(self.notification)
		self.notification = nil
	end
end

return setmetatable(upower, {
	__call = upower.new,
})
