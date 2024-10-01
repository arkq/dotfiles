local awful = require('awful')

local function spawn(cmd)
	awful.spawn(string.gsub(cmd, "~", os.getenv("HOME")))
end

-- basic X server configuration
spawn('rundom -r -i 7200 -d 3600 "ls -d ~/.local/share/backgrounds/* |shuf -n1 |feh --bg-fill -f -"')
spawn('picom --daemon')

-- basic application set
spawn('xautolock -secure -time 6 -locker "alock -b shade -c glyph -i frame"')
spawn('gpg-agent --sh --enable-ssh-support --daemon')
spawn('urxvtd -f -q -o')

-- delayed ignition startup
awesome.connect_signal("startup", function()
	awful.spawn('syslog-notify -u -c 25')
end)
