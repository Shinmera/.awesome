--- Startup
local awful = require("awful")
awful.rules = require("awful.rules")
local naughty = require("naughty")
local vicious = require("vicious")
local wibox = require("wibox")
local beautiful = require("beautiful")

--- Error handling
if awesome.startup_errors then
    naughty.notify({preset=naughty.config.presets.critical,
                    title="Augh shit.",
                    text=awesome.startup_errors})
end
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
                             if in_error then return end
                             in_error = true
                             
                             naughty.notify({preset=naughty.config.presets.critical,
                                             title="FUCK!",
                                             text=err})
                             in_error = false
   end)
end

--- Settings
terminal = "xfce4-terminal"
filemanager = "nemo --no-desktop"
modkey = "Mod1"

beautiful.init(awful.util.getdir("config") .. "/theme.lua")

local layouts = {
   awful.layout.suit.tile
}

local tags = awful.tag({"main","www","dev","bkg","exp"}, 1, layouts[1])
for s=2, screen.count() do
   ext_tags = awful.tag({"ext"}, s, layouts[1])
end

--- Helpers
local view_tag_proper = function(tag)
   awful.tag.viewonly(tag)
   local master = awful.client.getmaster()
   if master then
      client.focus = awful.client.getmaster()
      if client.focus then client.focus:raise() end
   end
end

local view_prev_proper = function()
   local tag = tags[awful.tag.getidx(awful.tag.selected(1))-1]
   if tag then view_tag_proper(tag) end
end

local view_next_proper = function()
   local tag = tags[awful.tag.getidx(awful.tag.selected(1))+1]
   if tag then view_tag_proper(tag) end
end

--- Status bar
-- Clock
clock = wibox.widget.textbox()
vicious.register(clock, vicious.widgets.date, " %Y.%m.%d %H:%M:%S ", 1)
-- CPU
cpugraph = awful.widget.graph()
cpugraph:set_height(16):set_width(64)
cpugraph:set_color(beautiful.fg_widget)
cpugraph:set_background_color(beautiful.fg_off_widget)
vicious.register(cpugraph, vicious.widgets.cpu, "$1", 2)
cputext = wibox.widget.textbox()
vicious.register(cputext, vicious.widgets.cpu, " CPU $1% ", 2)
-- Memory
membar = awful.widget.graph()
membar:set_height(16):set_width(64)
membar:set_color(beautiful.fg_widget)
membar:set_background_color(beautiful.fg_off_widget)
vicious.register(membar, vicious.widgets.mem, "$1", 10)
memtext = wibox.widget.textbox()
vicious.register(memtext, vicious.widgets.mem, " MEM $1% ", 10)
-- Battery
batbar = awful.widget.graph()
batbar:set_height(16):set_width(64)
batbar:set_color(beautiful.fg_widget)
batbar:set_background_color(beautiful.fg_off_widget)
vicious.register(batbar, vicious.widgets.bat, "$2", 60, "BAT0")
battext = wibox.widget.textbox()
vicious.register(battext, vicious.widgets.bat, " BAT $2% ", 60, "BAT0")
-- Misc
taglist = awful.widget.taglist(1, awful.widget.taglist.filter.all,
                               awful.util.table.join(
                                  awful.button({}, 1, view_tag_proper),
                                  awful.button({modkey}, 1, awful.client.movetotag),
                                  awful.button({}, 4, view_next_proper),
                                  awful.button({}, 5, view_prev_proper)))
prompt = awful.widget.prompt()
systray = wibox.widget.systray()
-- Bar
local left_layout = wibox.layout.fixed.horizontal()
left_layout:add(taglist)
left_layout:add(prompt)

local right_layout = wibox.layout.fixed.horizontal()
right_layout:add(cputext)
right_layout:add(cpugraph)
right_layout:add(memtext)
right_layout:add(membar)
right_layout:add(battext)
right_layout:add(batbar)
right_layout:add(clock)
right_layout:add(systray)

local layout = wibox.layout.align.horizontal()
layout:set_left(left_layout)
layout:set_right(right_layout)

bar = awful.wibox({position="top",
             height=16,
             screen=1,
             fg=beautiful.fg_normal,
             bg=beautiful.bg_normal})
bar:set_widget(layout)
--- Rules
-- Global
root.keys(awful.util.table.join(
             -- Tabs and Windows
             awful.key({modkey, "Control"}, "Left", view_prev_proper),
             awful.key({modkey, "Control"}, "Right", view_next_proper),
             awful.key({modkey}, "Tab", function()
                   awful.client.focus.byidx(1)
                   if client.focus then client.focus:raise() end
             end),
             -- Launching
             awful.key({modkey}, "Return", function() awful.util.spawn(terminal) end),
             awful.key({modkey}, "d", function() awful.util.spawn(filemanager) end),
             awful.key({modkey}, "r", function() prompt:run() end),
             -- Awesome itself
             awful.key({modkey, "Control"}, "r", awesome.restart),
             awful.key({modkey, "Control"}, "q", awesome.quit)
))
-- Window
local currently_titlebar=false
windowkeys = awful.util.table.join(
   awful.key({modkey}, "f", awful.client.floating.toggle),
   awful.key({modkey}, "Escape", function(c)
         awful.client.focus.byidx(-1)
         if client.focus then client.focus:raise() end
         c:kill()
end))

windowbuttons = awful.util.table.join(
   awful.button({}, 1, function(c)
         client.focus = c
         c:raise()
   end),
   awful.button({modkey}, 1, awful.mouse.client.move),
   awful.button({modkey}, 3, awful.mouse.client.resize))

awful.rules.rules = {
   {rule={}, properties={
       focus=true,
       size_hints_honor=false,
       keys=windowkeys, buttons=windowbuttons,
       border_width=beautiful.border_width,
       border_color=beautiful.border_color
   }}
}

--- Signal handling
client.connect_signal("manage", function(c, startup)
                         local wants_titlebar = true
                         
                         -- Classes
                         if c.class == "Wine" then
                            c.border_width = 0
                            c.floating = true
                            wants_titlebar = false
                         elseif c.class == "Thunderbird" then c.tag = tags["main"]
                         elseif c.class == "Opera" then       c.tag = tags["www"]
                         elseif c.class == "Emacs" then       c.tag = tags["dev"]
                         elseif c.name == "wpa_gui" then      c.tag = tags["bkg"]
                         elseif c.name == "pavucontrol" then  c.tag = tags["bkg"]
                         end
                         
                         -- Setup title bar
                         if wants_titlebar then
                            local title = awful.titlebar.widget.titlewidget(c)
                            title:set_align("center")
                            awful.titlebar(c):set_widget(title)
                         end
                            
                         -- Fix placement
                         if not startup then
                            awful.client.setslave(c)
                            if not c.size_hints.program_position
                            and not c.size_hints.user_position then
                               awful.placement.no_overlap(c)
                               awful.placement.no_offscreen(c)
                            end
                         end
end)

client.connect_signal("focus", function(c) c.border_color=beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color=beautiful.border_normal end)

--- Launch externals
awful.util.spawn_with_shell(awful.util.getdir("config") .. "/startup.sh")
