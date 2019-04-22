/* See LICENSE file for copyright and license details. */

#include "htile.c"
#include "gaplessgrid.c"

/* mbp-mappings */
#define XF86AudioMute           0x1008ff12
#define XF86AudioLowerVolume    0x1008ff11
#define XF86AudioRaiseVolume    0x1008ff13
#define XF86TouchpadToggle      0x1008ffa9
#define XF86MonBrightnessUp 0x1008ff02
#define XF86MonBrightnessDown   0x1008ff03
#define XF86KbdBrightnessUp 0x1008ff05
#define XF86KbdBrightnessDown 0x1008ff06

/* appearance */
static const unsigned int borderpx  = 3;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int systraypinning = 1;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;     /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 0;        /* 0 means bottom bar */
static const char *fonts[]          = { "ShureTechMono Nerd Font Mono:size=14" };
static const char dmenufont[]       = "ShureTechMono Nerd Font Mono:size=14";

/* new colors */
static char normbgcolor[]       = "#222222";
static char normfgcolor[]       = "#bbbbbb";
static char normbordercolor[]   = "#4b4b4b";
static char selbordercolor[]  = "#1b1b1b";
static char selbgcolor[]      = "#2b2b2b";
static char selfgcolor[]      = "#eeeeee";

static char *colors[][3]      = {
	/*               fg           bg           border   */
	[SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
	[SchemeSel]  = { selfgcolor, selbgcolor,  selbordercolor },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            1,           -1 },
	{ "Firefox",  NULL,       NULL,       0,            0,           -1 },
    { "VirtualBox", NULL,     NULL,       0,            1,           -1 },
};

/* layout(s) */
static const float mfact     = 0.50; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
    { "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
    { "==|",      htile },
    { "|||",      gaplessgrid},
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m",
                    dmenumon, "-fn",
                    dmenufont, "-nb",
                    normbgcolor, "-nf",
                    normfgcolor, "-sb",
                    selbgcolor, "-sf",
                    selfgcolor,
                    NULL };
static const char *passmenu[]  = { "passmenu", NULL };
static const char *termcmd[]  = { "urxvt", NULL };
static const char *screensaver[]  = { "xscreensaver-command", "-lock", NULL };
static const char *wallpaper[] = { "/bin/sh", "-c", "$HOME/bin/wallpaper.sh -w -b $HOME/Wallpapers/widescreen_wallpapers", NULL};
static const char *volup[]          = { "pulseaudio-ctl", "up", NULL };
static const char *voldown[]        = { "pulseaudio-ctl", "down", NULL };
static const char *voltoggle[] = { "pulseaudio-ctl", "mute", NULL };
static const char *monbrightup[]    = { "light", "-A", "10", NULL };
static const char *monbrightdown[]  = { "light", "-U", "10", NULL };
static const char *kbdbrightup[]    = { "light", "-k", "-A", "10", NULL };
static const char *kbdbrightdown[]  = { "light", "-k", "-U", "10", NULL };
static const char *kbdbrightoff[] = { "light", "-k", "-S", "0", NULL };

static Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_p,      spawn,          {.v = passmenu } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ Mod1Mask|ControlMask,         XK_l,      spawn,          {.v = screensaver } },
	{ Mod1Mask|ControlMask,         XK_w,      spawn,          {.v = wallpaper } },
	{ MODKEY|ShiftMask,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_x,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
    { MODKEY,                       XK_b,      setlayout,      {.v = &layouts[3]} },
	{ MODKEY,                       XK_g,      setlayout,      {.v = &layouts[4]} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
    { 0,                            XF86AudioRaiseVolume,       spawn,              {.v = volup } },
    { 0,                            XF86AudioLowerVolume,       spawn,              {.v = voldown } },
    { 0,                            XF86AudioMute,              spawn,              {.v = voltoggle } },
    { 0,                            XF86MonBrightnessUp,        spawn,              {.v = monbrightup } },
    { 0,                            XF86MonBrightnessDown,      spawn,              {.v = monbrightdown } },
    { 0,                            XF86KbdBrightnessUp,        spawn,              {.v = kbdbrightup } },
    { 0,                            XF86KbdBrightnessDown,      spawn,              {.v = kbdbrightdown } },
    { ShiftMask, XF86KbdBrightnessDown, spawn, {.v = kbdbrightoff } },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

