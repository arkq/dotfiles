---------------------------------------------------
-- ALSA Volume Widget for Awesome Window Manager
---------------------------------------------------

local awful = require('awful')
local beautiful = require('beautiful')
local lgi = require('lgi')
local math = require('math')
local naughty = require('naughty')
local utils = require('utils')
local wibox = require('wibox')
local ALSA = lgi.require('AlsaMixer')

local widget = {}

function widget:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function widget:init(args)

	self.device = args.device or "default"
	self.control = args.control or "Master"

	self.mixer = ALSA.Mixer:new()
	self.mixer:attach(self.device)

	self.element = self.mixer:get_element(self.control, 0)
	self.db_range = self.element.playback_db_max - self.element.playback_db_min
	self.db_step = 10

	self.icons = {
		muted = utils.lookup_icon("audio-volume-muted-symbolic", beautiful.fg_normal),
		low = utils.lookup_icon("audio-volume-low-symbolic", beautiful.fg_normal),
		medium = utils.lookup_icon("audio-volume-medium-symbolic", beautiful.fg_normal),
		high = utils.lookup_icon("audio-volume-high-symbolic", beautiful.fg_normal),
	}

	self.image = wibox.widget({
		widget = wibox.widget.imagebox,
		image = self:get_icon(self.element),
	})

	-- Compose top-level widget
	self.widget = wibox.widget({
		self.image,
		layout = wibox.container.margin,
		top = 2, bottom = 2,
	})

	self.widget:buttons(awful.util.table.join(
		awful.button({ }, 1, function () self:info() end),
		awful.button({ }, 2, function () self:toggle() end),
		awful.button({ }, 4, function () self:raise() end),
		awful.button({ }, 5, function () self:lower() end)
	))

	self.widget:connect_signal('mouse::leave', function ()
		self:notify_hide()
	end)

	self.element.on_notify = function (elem)
		if self.notification then self:info() end
		self.image:set_image(self:get_icon(elem))
	end

	return self
end

function widget:info()
	awful.spawn.easy_async({ "amixer", "-D", self.device, "sget", self.control }, function (out)
		local info = out:match("^%s*(.-)%s*$")
		self:notify(nil, info, { timeout = 0 })
	end)
end

function widget:toggle()
	self.element.playback_switch = not self.element.playback_switch
end

function widget:lower()
	self.element.playback_db = math.max(
		self.element.playback_db_min,
		self.element.playback_db - self.db_step)
end

function widget:raise()
	self.element.playback_db = math.min(
		self.element.playback_db + self.db_step,
		self.element.playback_db_max)
end

function widget:get_volume_value(element)
	local db_relavive = element.playback_db - element.playback_db_min
	return 100 * db_relavive / self.db_range
end

function widget:get_icon(element)
	local v = self:get_volume_value(element)
	if not element.playback_switch or v == 0 then
		return self.icons.muted
	elseif v > 66 then
		return self.icons.high
	elseif v > 33 then
		return self.icons.medium
	else
		return self.icons.low
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

return setmetatable(widget, {
	__call = widget.new,
})
