-- Awesome WM autostart
-- vim: expandtab:sw=4:ts=8:sts=4

local awful = require('awful')

-- Spawn a command.
local function spawn(cmd)
    return awful.spawn(string.gsub(cmd, "~", os.getenv("HOME")))
end

-- Span a command only once.
-- Optionally takes a matcher function that will be called before spawning
-- the command. If the matcher returns true, the command will not be spawned.
-- The default matcher will check if the command is already running.
local function once(cmd, matcher)
    if matcher == nil then
        matcher = function()
            -- Convert command to regexp match pattern
            local tmp = cmd:gsub("(['|*])", "\\%1")
            return os.execute("pgrep -fx '" .. tmp .. "'") == 0
        end
    end
    if matcher() then return end
    return spawn(cmd, matcher)
end

-- Basic X server configuration
once('rundom -r -i 7200 -d 3600 "ls -d ~/.local/share/backgrounds/* |shuf -n1 |feh --bg-fill -f -"',
     function() return os.execute("pgrep -fx 'rundom -r -i 7200 -d 3600 ls -d .*'") == 0 end)
once('picom --daemon')

-- Basic application set
once('xautolock -secure -time 6 -locker "alock -b shade -c glyph -i frame"')
once('gpg-agent --sh --enable-ssh-support --daemon')
once('urxvtd -f -q -o')

-- Delayed ignition startup
awesome.connect_signal("startup", function()
    once('keepassxc')
    once('wpa_gui -t -q -m 5')
    once('syslog-notify -u -c 25')
end)
