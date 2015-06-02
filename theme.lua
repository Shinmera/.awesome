local awful = require("awful")

theme = {}
theme.themedir = awful.util.getdir("config") .. "/"
theme.wallpaper_cmd = {""}

-- Base
theme.font = "Consolas 10"
theme.fg_normal = "#FFFFFF"
theme.fg_focus = "#FFFFFF"
theme.fg_urgent = "#FFFFFF"
theme.bg_normal = "#585C56"
theme.bg_focus = "#AAB0A7"
theme.bg_urgent = "#FF0000"

-- Borders
theme.border_width = 1
theme.border_normal = theme.bg_normal
theme.border_focus = theme.bg_focus
theme.border_marked = theme.bg_urgent

-- Window bars
theme.titlebar_bg_focus = theme.bg_focus
theme.titlebar_bg_normal = theme.bg_normal

-- Widgets
theme.fg_widget = theme.fg_normal
theme.bg_widget = theme.bg_normal
theme.fg_center_widget = theme.fg_focus
theme.fg_off_widget = "#2A2B2A"
theme.border_widget = theme.bg_normal

return theme
