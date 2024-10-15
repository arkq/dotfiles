---------------------------------------------------
-- CPU Widget for Awesome Window Manager
---------------------------------------------------

local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local utils = require('utils')
local wibox = require('wibox')

local widget = {}

function widget:new(args)
	return setmetatable({}, {__index = self}):init(args or {})
end

function widget:init(args)

	self.stat = args.stat or "/proc/stat"
	self.delay = args.delay or 5
	self.width = args.width or 50

	self.graph = wibox.widget({
		widget = wibox.widget.graph,
		background_color = beautiful.bg_normal,
		color = "linear:0,0:0,20:0,#FF0000:0.3,#FFFF00:0.6," .. beautiful.fg_normal,
		forced_width = self.width,
		max_value = 100,
	})

	self.image = wibox.widget({
		widget = wibox.widget.imagebox,
		image = utils.lookup_icon("cpu-symbolic", beautiful.fg_normal),
	})

	-- Compose top-level widget
	self.widget = wibox.widget({
		{ self.image,
			layout = wibox.container.margin,
			top = 2, bottom = 2, right = 2 },
		{ { self.graph,
				layout = wibox.container.mirror,
				reflection = { horizontal = true } },
			layout = wibox.container.margin,
			top = 2, bottom = 2 },
		layout = wibox.layout.fixed.horizontal,
	})

	self.widget:buttons(awful.util.table.join(
		awful.button({ }, 1, function ()
			-- Get top N processes sorted by CPU usage
			awful.spawn.easy_async({ "ps", "--sort=-pcpu", "aux" }, function (out)
				local info = ""
				for i, v in pairs(gears.string.split(out, "\n")) do
					if string.len(v) > 120 then v = v:sub(0, 120) .. "..." end
					info = info .. v
					if i >= 15 then break end
					info = info .. "\n"
				end
				self:notify(nil, info, { timeout = 0 })
			end)
		end)
	))

	self.widget:connect_signal('mouse::leave', function ()
		self:notify_hide()
	end)

	local prev_idle = 10e60
	local prev_total = 10e60

	gears.timer {
		timeout   = self.delay,
		call_now  = true,
		autostart = true,
		callback  = function()

			local line = ""
			local f = io.open(self.stat, "rb"); if f then
				line = f:read("*line")
				f:close()
			end

			local i = 1
			local idle = 1
			local total = 1
			for v in line:gmatch("%d+") do
				-- The idle time is in the 4th column
				if i == 4 then idle = 0 + v end
				total = total + v
				i = i + 1
			end

			idle = idle - prev_idle
			total = total - prev_total
			self.graph:add_value((total - idle) / total * 100)

			prev_idle = prev_idle + idle
			prev_total = prev_total + total

		end
	}

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
