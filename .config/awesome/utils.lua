---------------------------------------------------
-- Custom utility module
---------------------------------------------------

local lgi = require('lgi')
local gears = require('gears')
local gtk = lgi.require('Gtk')

local utils = {}

--- Lookup an icon in a GTK default icon theme.
-- @param string name Short or full name of the icon.
-- @param string color Optional color for icon recoloring.
-- @return surface|boolean Cairo surface or false on failure.
function utils.lookup_icon(name, color)

	local flags = { gtk.IconLookupFlags.GENERIC_FALLBACK }
	local icon = gtk.IconTheme.get_default():lookup_icon(name, 64, flags)

	if icon == nil then
		return false
	end

	-- Load icon into Cairo surface
	local surface = gears.surface(icon:get_filename())

	if color ~= nil then
		surface = gears.color.recolor_image(surface, color)
	end

	return surface
end

return utils
