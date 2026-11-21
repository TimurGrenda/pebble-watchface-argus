#pragma once

#include <pebble.h>

/*
 * Argus colour theme.
 *
 * ARGUS_LIGHT_THEME 1 -> light watchface (black ink on white)
 * ARGUS_LIGHT_THEME 0 -> original dark watchface
 *
 * Can also be overridden from the build, e.g. -DARGUS_LIGHT_THEME=0.
 */
#ifndef ARGUS_LIGHT_THEME
#define ARGUS_LIGHT_THEME 1
#endif

#if ARGUS_LIGHT_THEME

#define THEME_BG          GColorWhite     /* window background                   */
#define THEME_FG          GColorBlack     /* primary text and icons              */
#define THEME_MUTED       GColorDarkGray  /* week numbers, normal wind marks     */
#define THEME_HAIRLINE    GColorLightGray /* chart axes, ticks, night hatching   */

#define THEME_ALERT       GColorRed                /* BT lost, quiet mode, temp  */
#define THEME_ACCENT_BLUE GColorCobaltBlue         /* precipitation, holidays    */
#define THEME_WEEKEND     GColorDarkCandyAppleRed  /* weekend day numbers        */
#define THEME_WIND_HIGH   GColorWindsorTan         /* gusts over Beaufort 8      */

#define THEME_BATT_OK     GColorIslamicGreen
#define THEME_BATT_WARN   GColorChromeYellow

/* The weather status cloud is shaded with a lighter and a darker tone.
   On white the lighter tone washes out, so the two are swapped. */
#define THEME_CLOUD_SHADE(is_light) (!(is_light))

#else /* original dark theme */

#define THEME_BG          GColorBlack
#define THEME_FG          GColorWhite
#define THEME_MUTED       GColorLightGray
#define THEME_HAIRLINE    GColorDarkGray

#define THEME_ALERT       GColorRed
#define THEME_ACCENT_BLUE GColorVividCerulean
#define THEME_WEEKEND     GColorSunsetOrange
#define THEME_WIND_HIGH   GColorYellow

#define THEME_BATT_OK     GColorGreen
#define THEME_BATT_WARN   GColorChromeYellow

#define THEME_CLOUD_SHADE(is_light) (is_light)

#endif
