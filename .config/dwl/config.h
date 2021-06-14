/*
================================================================================
Configuration for dwl (wayland desktop compositor).
Copy/link this into the build directory for dwl before compiling.
For the AUR package, replace the provided `config.h` with this file.
================================================================================
*/

/* appearance */
static const int sloppyfocus        = 1;  /* focus follows mouse */
static const unsigned int borderpx  = 3;  /* border pixel of windows */
static const float rootcolor[]      = {0.3, 0.3, 0.3, 1.0};
static const float bordercolor[]    = {0.5, 0.5, 0.5, 1.0};
static const float focuscolor[]     = {1.0, 0.0, 0.0, 1.0};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
    /* app_id     title       tags mask     isfloating   monitor   x    y   width   height */
    /* x, y, width, height = 0 ->  use default */
    /* examples:
    { "Gimp",     NULL,       0,            1,           -1        0    0    500     400 },
    { "firefox",  NULL,       1 << 8,       0,           -1       200  100    0       0 },
    */
    { "floating-terminal", NULL, 0, 1, -1 },
    { "zathura", NULL, 0, 1, -1 },
    { "imv", NULL, 0, 1, -1 },
    { "drracket", NULL, 0, 1, -1, 360, 100, 1200, 880 },
    { "gimp", NULL, 0, 1, -1 },
    { "inkscape", NULL, 0, 1, -1 },
    { "mscore", NULL, 0, 1, -1 },
    { "mypaint", NULL, 0, 1, -1, 360, 100, 1200, 880 },
    { "matplotlib", NULL, 0, 1, -1 },  /* FIXME: not working */
};

/* layout(s) */
static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[]=",      tile },
    { "><>",      NULL },    /* no layout function means floating behavior */
    { "[M]",      monocle },
};

/* monitors
 * The order in which monitors are defined determines their position.
 * Non-configured monitors are always added to the left. */
static const MonitorRule monrules[] = {
    /* name       mfact nmaster scale layout       rotate/reflect x y */
    /* mfact sets the default column ratio */
    /* example of a HiDPI laptop monitor:
    { "eDP1",    0.5,  1,      2,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL, 0, 0 },
    */
    { NULL,       0.5, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL, 0, 0 },
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
    /* can specify fields: rules, model, layout, variant, options */
    /* example:
    .options = "ctrl:nocaps",
    */
    .layout = "us",
    .options = "altwin:swap_lalt_lwin",
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int natural_scrolling = 0;

/* Alt = WLR_MODIFIER_ALT; Super/Win = WLR_MODIFIER_LOGO */
#define MODKEY WLR_MODIFIER_LOGO
#define TAGKEYS(KEY,SKEY,TAG) \
    { MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[]  = { "alacritty", NULL };
static const char *quickterm[] = { "alacritty", "--class", "floating-terminal,floating-terminal", NULL };
static const char *guilauncher[] = { "alacritty", "--class", "floating-terminal,floating-terminal", "--working-directory", "/usr/share/applications", "-e", "fzfmenu.sh", NULL };
static const char *fileopener[] = { "alacritty", "--class", "floating-terminal,floating-terminal", "-e", "fzfopen.sh", NULL };
static const char *mocpwindow[] = { "alacritty", "--class", "floating-terminal,floating-terminal", "-e", "mocp", NULL };

static const Key keys[] = {
    /* Note that Shift changes certain key codes: c -> C, 2 -> at, etc. */
    /* modifier                  key                 function        argument */
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return,     spawn,          {.v = termcmd} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_D,          spawn,          {.v = guilauncher} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_O,          spawn,          {.v = fileopener} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_F,          spawn,          {.v = quickterm} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_M,          spawn,          {.v = mocpwindow} },
    { MODKEY,                    XKB_KEY_j,          focusstack,     {.i = +1} },
    { MODKEY,                    XKB_KEY_k,          focusstack,     {.i = -1} },
    { MODKEY,                    XKB_KEY_i,          incnmaster,     {.i = +1} },
    { MODKEY,                    XKB_KEY_d,          incnmaster,     {.i = -1} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_L,          setmfact,       {.f = +0.05} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_H,          setmfact,       {.f = -0.05} },
    { MODKEY,                    XKB_KEY_Return,     zoom,           {0} },
    { MODKEY,                    XKB_KEY_Tab,        view,           {0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_C,          killclient,     {0} },
    { MODKEY,                    XKB_KEY_t,          setlayout,      {.v = &layouts[0]} },
    { MODKEY,                    XKB_KEY_f,          setlayout,      {.v = &layouts[1]} },
    { MODKEY,                    XKB_KEY_space,      togglefloating, {0} },
    { MODKEY,                    XKB_KEY_e,          togglefullscreen, {0} },
    { MODKEY,                    XKB_KEY_0,          view,           {.ui = ~0} },
    { MODKEY,                    XKB_KEY_comma,      focusmon,       {.i = WLR_DIRECTION_LEFT} },
    { MODKEY,                    XKB_KEY_period,     focusmon,       {.i = WLR_DIRECTION_RIGHT} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,       tagmon,         {.i = WLR_DIRECTION_LEFT} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,    tagmon,         {.i = WLR_DIRECTION_RIGHT} },
    TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                     0),
    TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                         1),
    TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                 2),
    TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                     3),
    TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                    4),
    TAGKEYS(          XKB_KEY_6, XKB_KEY_caret,                      5),
    TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                  6),
    TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                   7),
    TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                  8),
    { MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_q,          quit,           {0} },
    { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
    CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
    CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
    { MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
    { MODKEY, BTN_MIDDLE, togglefloating, {0} },
    { MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
