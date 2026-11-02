# kDock: macOS Sequoia-style Modern Dock for KDE Plasma 6 (Wayland)

A native, high-performance macOS Sequoia-inspired Dock applet for KDE Plasma 6 built purely with Qt6, Kirigami, Plasma Components 3, and native Wayland protocols.

![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![KDE Plasma](https://img.shields.io/badge/KDE%20Plasma-6.8%2B-blue)
![Wayland](https://img.shields.io/badge/Wayland-Strict-green)
![PipeWire](https://img.shields.io/badge/Audio-PipeWire%2FWirePlumber-red)

---

## 🌟 Key Features

- **macOS Parabolic Smooth Magnification:** Continuous, cosine-squared bell curve magnification with zero edge artifacts and natural spacing interpolation.
- **macOS Sequoia Frosted Glass Aesthetics:** Continuous squircle corner radius, adaptive translucent backdrop, specular glass inner-bevel highlights, and ambient contact shadows.
- **Bounce Physics Animations:** Native vertical bounce animations with exponential decay damping on application launch and cyclic pulsing on attention requests (`demandsAttention`).
- **Running App Indicators:** Subtle glowing indicator dots and active focused pills positioned at the base of running applications.
- **macOS Floating Pill Tooltips:** Dark translucent glass tooltips with rounded capsules that dynamically follow magnified icons.
- **Folder Stacks:** Downloads and Documents folder stacks with grid overlay popups for quick file opening and drag-and-drop targeting.
- **Interactive Trash Bin:** Dynamic trash icon tracking file presence (`user-trash` vs `user-trash-full`), drag-and-drop deletion, empty trash contextual menu, and PipeWire sound feedback.
- **Low-Latency PipeWire Audio Feedback:** Plays subtle sound effects (trash empty, launch click, stack open) respecting WirePlumber virtual sinks and EasyEffects DSP filters.
- **Wayland Native & Zero Legacy Dependencies:** Exclusively utilizes `org.kde.taskmanager` (TasksModel) and layer-shell integration without any X11 dependencies.

---

## 📐 Mathematical Magnification Architecture

To guarantee the fluid feel of macOS without jarring boundary steps, `kDock` applies a cosine-squared transfer function:

$$S(d) = 1 + (S_{\max} - 1) \cdot \cos^2\left(\frac{\pi}{2} \cdot \frac{d}{R}\right) \quad \text{for } d < R$$

Where:
- $d = |x_i - x_{\text{cursor}}|$ represents distance from icon center to cursor.
- $R = \text{baseIconSize} \times \text{radiusFactor}$ defines the influence threshold.
- $S(d) = 1.0$ when $d \ge R$.
- The first derivative $\frac{dS}{dd} = 0$ at both $d=0$ and $d=R$, ensuring smooth acceleration and deceleration of the magnification zoom.

---

## 🚀 Installation & Testing

### Installation via `kpackagetool6`:
```bash
# Install to local user plasmoid directory
kpackagetool6 --type Plasma/Applet --install /path/to/kdock

# Or upgrade if already installed
kpackagetool6 --type Plasma/Applet --upgrade /path/to/kdock
```

### Live Preview with `plasmoidviewer`:
```bash
plasmoidviewer -a /path/to/kdock
```

### Running Automated Test Suite:
```bash
./tests/test_kdock_sanity.sh
```

---

## 🛠️ Configuration Options

Accessible through standard Plasma Applet Configuration dialog:
- **Dock Icon Size:** Adjust between 32px and 128px (default: 56px).
- **Magnification Factor:** Scale multiplier up to 2.2x.
- **Frosted Glass Style:** Adaptive (follows Plasma theme), Frosted Silver (Light), or Deep Graphite (Dark).
- **Stacks & Trash Toggles:** Independently show or hide folder stacks and the trash can.
- **PipeWire Audio Feedback:** Enable or disable subtle haptic sound cues.
