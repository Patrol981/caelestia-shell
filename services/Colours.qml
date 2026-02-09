pragma Singleton
pragma ComponentBehavior: Bound

import qs.config
import qs.utils
import Caelestia
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool showPreview
    property string scheme
    property string flavour
    readonly property bool light: showPreview ? previewLight : currentLight
    property bool currentLight
    property bool previewLight
    readonly property M3Palette palette: showPreview ? preview : current
    readonly property M3TPalette tPalette: M3TPalette {}
    readonly property M3Palette current: M3Palette {}
    readonly property M3Palette preview: M3Palette {}
    readonly property Transparency transparency: Transparency {}
    readonly property alias wallLuminance: analyser.luminance

    function getLuminance(c: color): real {
        if (c.r == 0 && c.g == 0 && c.b == 0)
            return 0;
        return Math.sqrt(0.299 * (c.r ** 2) + 0.587 * (c.g ** 2) + 0.114 * (c.b ** 2));
    }

    function alterColour(c: color, a: real, layer: int): color {
        const luminance = getLuminance(c);

        const offset = (!light || layer == 1 ? 1 : -layer / 2) * (light ? 0.2 : 0.3) * (1 - transparency.base) * (1 + wallLuminance * (light ? (layer == 1 ? 3 : 1) : 2.5));
        const scale = (luminance + offset) / luminance;
        const r = Math.max(0, Math.min(1, c.r * scale));
        const g = Math.max(0, Math.min(1, c.g * scale));
        const b = Math.max(0, Math.min(1, c.b * scale));

        return Qt.rgba(r, g, b, a);
    }

    function layer(c: color, layer: var): color {
        if (!transparency.enabled)
            return c;

        return layer === 0 ? Qt.alpha(c, transparency.base) : alterColour(c, transparency.layers, layer ?? 1);
    }

    function on(c: color): color {
        if (c.hslLightness < 0.5)
            return Qt.hsla(c.hslHue, c.hslSaturation, 0.9, 1);
        return Qt.hsla(c.hslHue, c.hslSaturation, 0.1, 1);
    }

    function load(data: string, isPreview: bool): void {
        const colours = isPreview ? preview : current;
        const scheme = JSON.parse(data);

        if (!isPreview) {
            root.scheme = scheme.name;
            flavour = scheme.flavour;
            currentLight = scheme.mode === "light";
        } else {
            previewLight = scheme.mode === "light";
        }

        for (const [name, colour] of Object.entries(scheme.colours)) {
            const propName = name.startsWith("term") ? name : `m3${name}`;
            if (colours.hasOwnProperty(propName))
                colours[propName] = `#${colour}`;
        }
    }

    function setMode(mode: string): void {
        Quickshell.execDetached(["caelestia", "scheme", "set", "--notify", "-m", mode]);
    }

    FileView {
        path: `${Paths.state}/scheme.json`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text(), false)
    }

    ImageAnalyser {
        id: analyser

        source: Wallpapers.current
    }

    component Transparency: QtObject {
        readonly property bool enabled: Appearance.transparency.enabled
        readonly property real base: Appearance.transparency.base - (root.light ? 0.1 : 0)
        readonly property real layers: Appearance.transparency.layers
    }

    component M3TPalette: QtObject {
        readonly property color m3primary_paletteKeyColor: root.layer(root.palette.m3primary_paletteKeyColor)
        readonly property color m3secondary_paletteKeyColor: root.layer(root.palette.m3secondary_paletteKeyColor)
        readonly property color m3tertiary_paletteKeyColor: root.layer(root.palette.m3tertiary_paletteKeyColor)
        readonly property color m3neutral_paletteKeyColor: root.layer(root.palette.m3neutral_paletteKeyColor)
        readonly property color m3neutral_variant_paletteKeyColor: root.layer(root.palette.m3neutral_variant_paletteKeyColor)
        readonly property color m3background: root.layer(root.palette.m3background, 0)
        readonly property color m3onBackground: root.layer(root.palette.m3onBackground)
        readonly property color m3surface: root.layer(root.palette.m3surface, 0)
        readonly property color m3surfaceDim: root.layer(root.palette.m3surfaceDim, 0)
        readonly property color m3surfaceBright: root.layer(root.palette.m3surfaceBright, 0)
        readonly property color m3surfaceContainerLowest: root.layer(root.palette.m3surfaceContainerLowest)
        readonly property color m3surfaceContainerLow: root.layer(root.palette.m3surfaceContainerLow)
        readonly property color m3surfaceContainer: root.layer(root.palette.m3surfaceContainer)
        readonly property color m3surfaceContainerHigh: root.layer(root.palette.m3surfaceContainerHigh)
        readonly property color m3surfaceContainerHighest: root.layer(root.palette.m3surfaceContainerHighest)
        readonly property color m3onSurface: root.layer(root.palette.m3onSurface)
        readonly property color m3surfaceVariant: root.layer(root.palette.m3surfaceVariant, 0)
        readonly property color m3onSurfaceVariant: root.layer(root.palette.m3onSurfaceVariant)
        readonly property color m3inverseSurface: root.layer(root.palette.m3inverseSurface, 0)
        readonly property color m3inverseOnSurface: root.layer(root.palette.m3inverseOnSurface)
        readonly property color m3outline: root.layer(root.palette.m3outline)
        readonly property color m3outlineVariant: root.layer(root.palette.m3outlineVariant)
        readonly property color m3shadow: root.layer(root.palette.m3shadow)
        readonly property color m3scrim: root.layer(root.palette.m3scrim)
        readonly property color m3surfaceTint: root.layer(root.palette.m3surfaceTint)
        readonly property color m3primary: root.layer(root.palette.m3primary)
        readonly property color m3onPrimary: root.layer(root.palette.m3onPrimary)
        readonly property color m3primaryContainer: root.layer(root.palette.m3primaryContainer)
        readonly property color m3onPrimaryContainer: root.layer(root.palette.m3onPrimaryContainer)
        readonly property color m3inversePrimary: root.layer(root.palette.m3inversePrimary)
        readonly property color m3secondary: root.layer(root.palette.m3secondary)
        readonly property color m3onSecondary: root.layer(root.palette.m3onSecondary)
        readonly property color m3secondaryContainer: root.layer(root.palette.m3secondaryContainer)
        readonly property color m3onSecondaryContainer: root.layer(root.palette.m3onSecondaryContainer)
        readonly property color m3tertiary: root.layer(root.palette.m3tertiary)
        readonly property color m3onTertiary: root.layer(root.palette.m3onTertiary)
        readonly property color m3tertiaryContainer: root.layer(root.palette.m3tertiaryContainer)
        readonly property color m3onTertiaryContainer: root.layer(root.palette.m3onTertiaryContainer)
        readonly property color m3error: root.layer(root.palette.m3error)
        readonly property color m3onError: root.layer(root.palette.m3onError)
        readonly property color m3errorContainer: root.layer(root.palette.m3errorContainer)
        readonly property color m3onErrorContainer: root.layer(root.palette.m3onErrorContainer)
        readonly property color m3success: root.layer(root.palette.m3success)
        readonly property color m3onSuccess: root.layer(root.palette.m3onSuccess)
        readonly property color m3successContainer: root.layer(root.palette.m3successContainer)
        readonly property color m3onSuccessContainer: root.layer(root.palette.m3onSuccessContainer)
        readonly property color m3primaryFixed: root.layer(root.palette.m3primaryFixed)
        readonly property color m3primaryFixedDim: root.layer(root.palette.m3primaryFixedDim)
        readonly property color m3onPrimaryFixed: root.layer(root.palette.m3onPrimaryFixed)
        readonly property color m3onPrimaryFixedVariant: root.layer(root.palette.m3onPrimaryFixedVariant)
        readonly property color m3secondaryFixed: root.layer(root.palette.m3secondaryFixed)
        readonly property color m3secondaryFixedDim: root.layer(root.palette.m3secondaryFixedDim)
        readonly property color m3onSecondaryFixed: root.layer(root.palette.m3onSecondaryFixed)
        readonly property color m3onSecondaryFixedVariant: root.layer(root.palette.m3onSecondaryFixedVariant)
        readonly property color m3tertiaryFixed: root.layer(root.palette.m3tertiaryFixed)
        readonly property color m3tertiaryFixedDim: root.layer(root.palette.m3tertiaryFixedDim)
        readonly property color m3onTertiaryFixed: root.layer(root.palette.m3onTertiaryFixed)
        readonly property color m3onTertiaryFixedVariant: root.layer(root.palette.m3onTertiaryFixedVariant)
    }

       component M3Palette: QtObject {
        // Tonal palette key colors (used if anything relies on them)
        property color m3primary_paletteKeyColor: "#c9a04d"          // main gold
        property color m3secondary_paletteKeyColor: "#d7c5a3"        // softer gold
        property color m3tertiary_paletteKeyColor: "#95e6cb"         // teal (notification accent)
        property color m3neutral_paletteKeyColor: "#6e6a86"          // gray-purple
        property color m3neutral_variant_paletteKeyColor: "#3a3845"  // darker neutral

        // Background and surfaces - based on #1d1b1b and slightly lighter variants
        property color m3background: "#1d1b1b"
        property color m3onBackground: "#f5deb3"      // wheat text on background

        property color m3surface: "#1d1b1b"
        property color m3surfaceDim: "#161414"
        property color m3surfaceBright: "#272323"

        property color m3surfaceContainerLowest: "#141212"
        property color m3surfaceContainerLow: "#1f1b1b"
        property color m3surfaceContainer: "#242020"
        property color m3surfaceContainerHigh: "#2a2625"
        property color m3surfaceContainerHighest: "#312d2b"

        property color m3onSurface: "#f5deb3"         // main foreground (wheat)
        property color m3surfaceVariant: "#3a3845"    // for borders, separators
        property color m3onSurfaceVariant: "#d7c5a3"  // softer foreground

        property color m3inverseSurface: "#f5deb3"    // light card
        property color m3inverseOnSurface: "#1d1b1b"  // dark text on light

        property color m3outline: "#6e6a86"           // slider trough etc
        property color m3outlineVariant: "#3a3845"

        property color m3shadow: "#000000"
        property color m3scrim: "#000000"

        // Tint for elevated surfaces
        property color m3surfaceTint: "#c9a04d"

        // Primary - matches hover state (wheat bg, dark text)
        property color m3primary: "#f5deb3"           // wheat
        property color m3onPrimary: "#1d1b1b"         // dark text on wheat
        property color m3primaryContainer: "#3a3324"  // dark gold container
        property color m3onPrimaryContainer: "#f5deb3"

        property color m3inversePrimary: "#c9a04d"    // deeper gold for inverse

        // Secondary - softer golds, used for less prominent elements
        property color m3secondary: "#d7c5a3"
        property color m3onSecondary: "#1d1b1b"
        property color m3secondaryContainer: "#2a2520"
        property color m3onSecondaryContainer: "#d7c5a3"

        // Tertiary - teal (from #custom-notification)
        property color m3tertiary: "#95e6cb"
        property color m3onTertiary: "#071a14"
        property color m3tertiaryContainer: "#193329"
        property color m3onTertiaryContainer: "#b7f0d9"

        // Error - keep fairly standard Material red
        property color m3error: "#ffb4ab"
        property color m3onError: "#690005"
        property color m3errorContainer: "#93000a"
        property color m3onErrorContainer: "#ffdad6"

        // Success - reuse teal family for "good" states
        property color m3success: "#95e6cb"
        property color m3onSuccess: "#071a14"
        property color m3successContainer: "#193329"
        property color m3onSuccessContainer: "#b7f0d9"

        // Fixed variants (for components that use "fixed" scheme)
        property color m3primaryFixed: "#f5deb3"
        property color m3primaryFixedDim: "#c9a04d"
        property color m3onPrimaryFixed: "#1d1b1b"
        property color m3onPrimaryFixedVariant: "#3a3324"

        property color m3secondaryFixed: "#f5deb3"
        property color m3secondaryFixedDim: "#d7c5a3"
        property color m3onSecondaryFixed: "#1d1b1b"
        property color m3onSecondaryFixedVariant: "#2a2520"

        property color m3tertiaryFixed: "#b7f0d9"
        property color m3tertiaryFixedDim: "#95e6cb"
        property color m3onTertiaryFixed: "#071a14"
        property color m3onTertiaryFixedVariant: "#193329"

        // Terminal-like palette (term0-term15) tuned to match the bar
        property color term0: "#1d1b1b"   // black - background
        property color term1: "#c96f5f"   // red   - warm muted
        property color term2: "#95e6cb"   // green - teal accent
        property color term3: "#c9a04d"   // yellow/gold
        property color term4: "#6e6a86"   // blue  - gray-purple
        property color term5: "#a070d5"   // magenta/purple
        property color term6: "#b7f0d9"   // cyan  - light teal
        property color term7: "#f5deb3"   // white - main fg

        property color term8: "#3a3632"   // bright black
        property color term9: "#e08a6e"   // bright red
        property color term10: "#a9f0d5"   // bright green/teal
        property color term11: "#e8c57e"   // bright yellow
        property color term12: "#8a86a0"   // bright blue
        property color term13: "#c28be8"   // bright magenta
        property color term14: "#c2f5e0"   // bright cyan
        property color term15: "#ffffff"   // bright white
    }

    // component M3Palette: QtObject {
    //     property color m3primary_paletteKeyColor: "#a8627b"
    //     property color m3secondary_paletteKeyColor: "#8e6f78"
    //     property color m3tertiary_paletteKeyColor: "#986e4c"
    //     property color m3neutral_paletteKeyColor: "#807477"
    //     property color m3neutral_variant_paletteKeyColor: "#837377"
    //     property color m3background: "#191114"
    //     property color m3onBackground: "#efdfe2"
    //     property color m3surface: "#191114"
    //     property color m3surfaceDim: "#191114"
    //     property color m3surfaceBright: "#403739"
    //     property color m3surfaceContainerLowest: "#130c0e"
    //     property color m3surfaceContainerLow: "#22191c"
    //     property color m3surfaceContainer: "#261d20"
    //     property color m3surfaceContainerHigh: "#31282a"
    //     property color m3surfaceContainerHighest: "#3c3235"
    //     property color m3onSurface: "#efdfe2"
    //     property color m3surfaceVariant: "#514347"
    //     property color m3onSurfaceVariant: "#d5c2c6"
    //     property color m3inverseSurface: "#efdfe2"
    //     property color m3inverseOnSurface: "#372e30"
    //     property color m3outline: "#9e8c91"
    //     property color m3outlineVariant: "#514347"
    //     property color m3shadow: "#000000"
    //     property color m3scrim: "#000000"
    //     property color m3surfaceTint: "#ffb0ca"
    //     property color m3primary: "#ffb0ca"
    //     property color m3onPrimary: "#541d34"
    //     property color m3primaryContainer: "#6f334a"
    //     property color m3onPrimaryContainer: "#ffd9e3"
    //     property color m3inversePrimary: "#8b4a62"
    //     property color m3secondary: "#e2bdc7"
    //     property color m3onSecondary: "#422932"
    //     property color m3secondaryContainer: "#5a3f48"
    //     property color m3onSecondaryContainer: "#ffd9e3"
    //     property color m3tertiary: "#f0bc95"
    //     property color m3onTertiary: "#48290c"
    //     property color m3tertiaryContainer: "#b58763"
    //     property color m3onTertiaryContainer: "#000000"
    //     property color m3error: "#ffb4ab"
    //     property color m3onError: "#690005"
    //     property color m3errorContainer: "#93000a"
    //     property color m3onErrorContainer: "#ffdad6"
    //     property color m3success: "#B5CCBA"
    //     property color m3onSuccess: "#213528"
    //     property color m3successContainer: "#374B3E"
    //     property color m3onSuccessContainer: "#D1E9D6"
    //     property color m3primaryFixed: "#ffd9e3"
    //     property color m3primaryFixedDim: "#ffb0ca"
    //     property color m3onPrimaryFixed: "#39071f"
    //     property color m3onPrimaryFixedVariant: "#6f334a"
    //     property color m3secondaryFixed: "#ffd9e3"
    //     property color m3secondaryFixedDim: "#e2bdc7"
    //     property color m3onSecondaryFixed: "#2b151d"
    //     property color m3onSecondaryFixedVariant: "#5a3f48"
    //     property color m3tertiaryFixed: "#ffdcc3"
    //     property color m3tertiaryFixedDim: "#f0bc95"
    //     property color m3onTertiaryFixed: "#2f1500"
    //     property color m3onTertiaryFixedVariant: "#623f21"
    //     property color term0: "#353434"
    //     property color term1: "#ff4c8a"
    //     property color term2: "#ffbbb7"
    //     property color term3: "#ffdedf"
    //     property color term4: "#b3a2d5"
    //     property color term5: "#e98fb0"
    //     property color term6: "#ffba93"
    //     property color term7: "#eed1d2"
    //     property color term8: "#b39e9e"
    //     property color term9: "#ff80a3"
    //     property color term10: "#ffd3d0"
    //     property color term11: "#fff1f0"
    //     property color term12: "#dcbc93"
    //     property color term13: "#f9a8c2"
    //     property color term14: "#ffd1c0"
    //     property color term15: "#ffffff"
    // }
}
