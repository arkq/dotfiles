---------------------------------------------------
-- UPower Battery Widget for Awesome Window Manager
---------------------------------------------------

local awful = require('awful')
local beautiful = require('beautiful')
local lgi = require('lgi')
local math = require('math')
local naughty = require('naughty')
local utils = require('utils')
local wibox = require('wibox')
local UP = lgi.require('UPowerGlib')

local function get_level(device)
	if not device.is_present then return "" end
	return math.ceil(device.percentage - 0.5) .. "%"
end

local function get_level_icon(device)
	local icon = "battery-missing-symbolic"
	if device.icon_name ~= "" then icon = device.icon_name end
	return utils.lookup_icon(icon, beautiful.fg_normal)
end

local widget = {}

function widget:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function widget:init(args)

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
	end

	self.image = wibox.widget({
		widget = wibox.widget.imagebox,
		image = get_level_icon(device),
	})

	self.label = wibox.widget({
		widget = wibox.widget.textbox,
		text = get_level(device),
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
			local info = device:to_text():match("^%s*(.-)%s*$")
			self:notify(nil, info, { timeout = 0 })
		end)
	))

	self.widget:connect_signal('mouse::leave', function ()
		self:notify_hide()
	end)

	device.on_notify = function (dev)
		if dev.warning_level == UP.DeviceLevel.LOW or
				dev.warning_level == UP.DeviceLevel.CRITICAL or
				dev.warning_level == UP.DeviceLevel.ACTION or
				dev.warning_level == UP.DeviceLevel.LAST then
			local text = "Battery Level " .. get_level(dev)
			self:notify("Low Battery", text, naughty.config.presets.critical)
		end
		self.label.text = get_level(device)
		self.image:set_image(get_level_icon(device))
	end

	return self
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

return setmetatable(widget, {
	__call = widget.new,
})
