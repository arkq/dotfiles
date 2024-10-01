---------------------------------------------------
-- Custom utility module
---------------------------------------------------

local lgi = require('lgi')
local gtk = lgi.require('Gtk')

local utils = {}

--- Lookup an icon in a GTK default icon theme.
-- @param string name Short or full name of the icon.
-- @return string|boolean Full name of the icon, or false on failure.
function utils.lookup_icon(name)
	local flags = { gtk.IconLookupFlags.GENERIC_FALLBACK }
	local icon = gtk.IconTheme.get_default():lookup_icon(name, 64, flags)
	if icon ~= nil then
		return icon:get_filename()
	end
	return false
end

return utils
