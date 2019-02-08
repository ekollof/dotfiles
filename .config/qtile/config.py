
import os
import socket
import subprocess

from libqtile.config import Key, Screen, Group, Drag, Click
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook

from Xlib import X, display
from Xlib.ext import randr
from pprint import pprint

d = display.Display()
s = d.screen()
r = s.root
res = r.xrandr_get_screen_resources()._data

# Dynamic multiscreen! (Thanks XRandr)
num_screens = 0
for output in res['outputs']:
    print("Output %d:" % (output))
    mon = d.xrandr_get_output_info(output, res['config_timestamp'])._data
    print("%s: %d" % (mon['name'], mon['num_preferred']))
    if mon['num_preferred']:
        num_screens += 1

print("%d screens found!" % (num_screens))

try:
    from typing import List  # noqa: F401
except ImportError:
    pass


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])


@lazy.function
def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)


@lazy.function
def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)


GREY = "#444444"
DARK_GREY = "#333333"
BLUE = "#007fcf"
DARK_BLUE = "#005083"
ORANGE = "#dd6600"
DARK_ORANGE = "#582c00"

mod = "mod4"
hostname = socket.gethostname()
homedir = os.getenv("HOME")
wallpapercmd = "sh -c 'feh --randomize --bg-scale " + \
    "~/Wallpapers/lukesmith/Spacescapes'"

keys = [
    Key([mod], "Return", lazy.spawn("st")),
    # Switch window focus to other pane(s) of stack
    Key([mod], "space", lazy.layout.next()),

    # Swap panes of split stack
    Key([mod, "shift"], "space", lazy.layout.rotate()),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split()),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout()),
    Key([mod, "shift"], "x", lazy.window.kill()),

    Key([mod, "control"], "r", lazy.restart()),
    Key([mod, "control"], "q", lazy.shutdown()),
    Key([mod], "r", lazy.spawncmd()),

    Key([mod], "p", lazy.spawn("rofi -show run")),
    Key([mod, "shift"], "p", lazy.spawn("rofi-pass")),
    Key(["mod1", "control"], "l", lazy.spawn("slock")),
    Key([mod, "shift"], "w", lazy.spawn(wallpapercmd.format(homedir))),

    # Window controls
    Key(
        [mod], "h",
        lazy.layout.left()  # Switch between windows in current stack pane
    ),
    Key(
        [mod], "j",
        lazy.layout.up()    # Switch between windows in current stack pane
    ),
    Key(
        [mod], "k",
        lazy.layout.down()   # Switch between windows in current stack pane
    ),
    Key(
        [mod], "l",
        lazy.layout.right()  # Switch between windows in current stack pane
    ),
    Key(
        [mod, "shift"], "k",
        lazy.layout.shuffle_down()  # Move windows down in current stack
    ),
    Key(
        [mod, "shift"], "j",
        lazy.layout.shuffle_up()    # Move windows up in current stack
    ),
    Key(
        [mod, "shift"], "l",
        lazy.layout.grow(),  # Grow size of current window (XmonadTall)
        lazy.layout.increase_nmaster(),  # Increase number in master (Tile)
    ),
    Key(
        [mod, "shift"], "h",
        lazy.layout.shrink(),  # Shrink size of current window (XmonadTall)
        lazy.layout.decrease_nmaster(),   # Decrease number in master (Tile)
    ),
    Key(
        [mod, "shift"], "Left",  # Move window to workspace to the left
        window_to_prev_group
    ),
    Key(
        [mod, "shift"], "Right",  # Move window to workspace to the right
        window_to_next_group
    ),
    Key(
        [mod], "n",
        lazy.layout.normalize()   # Restore all windows to default size ratios
    ),
    Key(
        [mod], "m",
        lazy.layout.maximize()    # Toggle a window between minimum and maximum
    ),

    Key(
        [mod, "shift"], "KP_Enter",
        lazy.window.toggle_floating()  # Toggle floating
    ),
    Key(
        [mod, "shift"], "space",
        lazy.layout.rotate(),  # Swap panes of split stack (Stack)
        lazy.layout.flip()  # Switch which side main pane occupies (XmonadTall)
    ),
    # Stack controls
    Key(
        [mod], "space",
        lazy.layout.next()  # Switch window focus to other pane(s) of stack
    ),
    Key(
        [mod, "control"], "Return",
        lazy.layout.toggle_split()  # Toggle between split and unsplit sides
    ),

    # Laptop keys
    Key(
        [], "XF86AudioMute",
        lazy.spawn("pulseaudio-ctl mute")
    ),
    Key(
        [], "XF86AudioLowerVolume",
        lazy.spawn("pulseaudio-ctl up")
    ),
    Key(
        [], "XF86AudioRaiseVolume",
        lazy.spawn("pulseaudio-ctl up")
    ),
    Key(
        [], "XF86MonBrightnessUp",
        lazy.spawn("light -A 10")
    ),
    Key(
        [], "XF86MonBrightnessDown",
        lazy.spawn("light -U 10")
    ),
    Key(
        [], "XF86KbdBrightnessUp",
        lazy.spawn("light -k -A 10")
    ),
    Key(
        [], "XF86KbdBrightnessDown",
        lazy.spawn("light -k -U 10")
    ),

]

groups = [Group(i) for i in "12345678"]

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], i.name, lazy.group[i.name].toscreen()),
        # mod1 + shift + letter of group = switch to & move focused window
        # to group
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name)),
    ])


layout_theme = {
    "border_width": 2,
    "margin": 10,
    "border_focus": "007fcf",
    "border_normal": "1D2330"
}

border_args = {
    "border_width": 2
}

layouts = [
    layout.Max(**layout_theme),
    layout.MonadTall(**layout_theme),
    layout.MonadWide(**layout_theme),
    layout.Bsp(**layout_theme),
    layout.TreeTab(
        font="Iosevka Term",
        fontsize=10,
        sections=["FIRST", "SECOND"],
        section_fontsize=11,
        bg_color="141414",
        active_bg="90C435",
        active_fg="000000",
        inactive_bg="384323",
        inactive_fg="a0a0a0",
        padding_y=5,
        section_top=10,
        panel_width=320,
        **layout_theme
    ),
    # layout.Stack(stacks=2, **layout_theme),
    # layout.Columns(**layout_theme),
    # layout.RatioTile(**layout_theme),
    # layout.VerticalTile(**layout_theme),
    # layout.Tile(shift_windows=True, **layout_theme),
    # layout.Matrix(**layout_theme),
    # layout.Zoomy(**layout_theme),
    layout.Floating(**layout_theme),
]


widget_defaults = dict(
    font='Iosevka Term',
    fontsize=14,
    padding=0,
    background=BLUE
)
extension_defaults = widget_defaults.copy()

screens = []
for screen in range(0, num_screens):
    prompt = "{0}@{1}: ".format(os.environ["USER"], hostname)
    screens.append(
        Screen(
            top=bar.Bar(
                [
                    widget.Prompt(prompt=prompt, background=BLUE),
                    widget.TextBox(text=" ", fontsize=45, padding=-8,
                                   foreground=DARK_BLUE, background=BLUE),
                    widget.CurrentLayoutIcon(background=BLUE),
                    widget.TextBox(text=" ", fontsize=45, padding=-8,
                                   foreground=BLUE, background=DARK_BLUE),
                    widget.GroupBox(urgent_border=DARK_BLUE,
                                    disable_drag=True,
                                    highlight_method="block",
                                    this_screen_border=DARK_BLUE,
                                    other_screen_border=DARK_ORANGE,
                                    this_current_screen_border=BLUE,
                                    other_current_screen_border=ORANGE,
                                    background=DARK_BLUE,
                                    ),
                    widget.TextBox(text=" ", fontsize=45, padding=-8,
                                   foreground=DARK_BLUE,
                                   background=BLUE),
                    widget.TaskList(
                        markup=True,
                        markup_focused='<span background="#005083"' +
                                       ' foreground="#aaffaa">{}</span>',
                        background=BLUE,
                        border=DARK_BLUE,
                        urgent_border=DARK_BLUE,
                    ),
                    widget.TextBox(text=" ", fontsize=45, padding=-8,
                                   foreground=DARK_BLUE, background=BLUE),
                    widget.Systray(background=DARK_BLUE),
                    widget.TextBox(text=" ", fontsize=45, padding=-8,
                                   foreground=BLUE, background=DARK_BLUE),
                    widget.TextBox(text=" ⌚", foreground=BLUE, fontsize=18,
                                   background=BLUE),
                    widget.Clock(format='%Y-%m-%d %a %H:%M:%S',
                                 background=BLUE),
                    widget.TextBox(text=" ", fontsize=45, padding=-8,
                                   foreground=DARK_BLUE, background=BLUE),
                    widget.CurrentLayout(background=DARK_BLUE),
                ],
                21,
            ),
        )
    )

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    {'wmclass': 'confirm'},
    {'wmclass': 'dialog'},
    {'wmclass': 'download'},
    {'wmclass': 'error'},
    {'wmclass': 'file_progress'},
    {'wmclass': 'notification'},
    {'wmclass': 'splash'},
    {'wmclass': 'toolbar'},
    {'wmclass': 'confirmreset'},  # gitk
    {'wmclass': 'makebranch'},  # gitk
    {'wmclass': 'maketag'},  # gitk
    {'wname': 'branchdialog'},  # gitk
    {'wname': 'pinentry'},  # GPG key password entry
    {'wmclass': 'ssh-askpass'},  # ssh-askpass
])
auto_fullscreen = True
focus_on_window_activation = "smart"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, github issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "Qtile"
