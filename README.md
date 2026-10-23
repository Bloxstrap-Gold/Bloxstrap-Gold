# 👑 Bloxstrap Gold

<div align="center">

# 👑 BLOXSTRAP GOLD 👑
### *The Luxurious Roblox Bootstrapper with Multi-Instance Support for macOS & Windows*

[![Website](https://img.shields.io/badge/Website-bloxstrapgold.github.io-gold.svg)](https://bloxstrapgold.github.io)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows-lightgrey.svg)](#)
[![Multi-Instance](https://img.shields.io/badge/Multi--Instance-Built--in-orange.svg)](#)
[![Trial](https://img.shields.io/badge/Free%20Trial-7%20Days%20(Joke)-yellow.svg)](#)

**[🌐 Visit the Official Bloxstrap Gold Website](https://bloxstrapgold.github.io)** • **[⚡ View Tiers & Pricing](https://bloxstrapgold.github.io#pricing)**

</div>

---

## 📖 About Bloxstrap Gold

**Bloxstrap Gold** is an open-source, satirical remake of the popular [Bloxstrap](https://github.com/bloxstraplabs/bloxstrap) bootstrapper, expanding it with native **macOS** and **Windows** support, built-in **Multi-Instance Roblox launching**, **FastFlags tuning**, and a deadpan **"paid" subscription bit** that is 100% free forever under GPL-3.0.

> [!NOTE]
> **Is Bloxstrap Gold actually paid?**  
> **No.** It's a parody. The 7-day trial, the moving runaway payment button, and the $999.99/mo subscription are a bit. Bloxstrap Gold does not accept or store payment details, and clicking "Ignore Payment" permanently unlocks everything for free.

---

## ✨ Features

### 👑 Cross-Platform Clients
* **macOS Client (`Bloxstrap-Mac`)**: Native AppKit/Swift client designed to replicate Bloxstrap's authentic Fluent layout, breadcrumbs, `OptionControl` cards, and status bar.
* **Windows Client (`Bloxstrap`)**: Full WPF-based Bloxstrap with integrated Gold theme, multi-instance background watcher, and Gold tab.

### 🎮 Built-in Multi-Instance Roblox
* **macOS**: Isolated process launching using `-n` arguments with active RAM telemetry and single-click process termination.
* **Windows**: Kernel mutex interceptor (`ROBLOX_singletonMutex` and `ROBLOX_singletonEvent`) allowing unlimited concurrent Roblox clients without third-party injectors.

### 🚩 FastFlags Vault & Allowlist Engine
* Fully configurable FastFlags engine tested with the official Roblox allowlist:
  * **FPS Cap Overrides**: 60, 120, 144, 165, 240, or Uncapped (`DFIntTaskSchedulerTargetFps`).
  * **Retina 1:1 Rendering**: Crisp native pixel rendering on macOS displays (`DFFlagDisableDPIScale`).
  * **In-Game Telemetry**: Native engine FPS HUD display (`FFlagDebugDisplayFPS`).
  * **Graphics Backend**: Metal, Vulkan/MoltenVK, and Direct3D overrides.

### 🔊 Classic Sounds & Mods
* **Death Sound Restoration**: 1-click installer and preview for the classic 2006 "Oof" sound into `Roblox.app` with automatic backup and restore.
* **Custom Cursors**: Choose between Gold Edition, 2006 Classic, 2013, or Default Roblox cursors.

### 🎭 The "Gold VIP" Joke & Deep Linking
* **7-Day Free Trial**: Starts on first launch. Fast-forward anytime with test controls.
* **Runaway Evasive Button**: Expired trial shows the moving "PAY FOR IT" button, with a stationary "Pay later" button.
* **Deep Link Protocol (`bloxstrap-gold://activate?key=...`)**: 1-click activation directly from the [bloxstrapgold.github.io](https://bloxstrapgold.github.io) checkout modal.
* **Ignore Payment**: Clicking "Ignore Payment" permanently suppresses all subscription banners.

---

## 🚀 Getting Started

### 🍏 macOS (Native Swift Client)

#### 1. Compile & Launch
```bash
# Clone the repository
git clone https://github.com/bloxstrapgold/bloxstrapgold.git
cd bloxstrapgold

# Build the native app bundle
./Bloxstrap-Mac/build.sh

# Launch the app
open Bloxstrap-Mac/BloxstrapGold.app
```

#### 2. Create Installer DMG
```bash
./Bloxstrap-Mac/package_dmg.sh
# Output: Bloxstrap-Mac/BloxstrapGold-macOS.dmg
```

---

### 🪟 Windows (.NET 6.0 WPF Client)

Requires Windows 10/11 with the [.NET 6 SDK](https://dotnet.microsoft.com/download/dotnet/6.0):

```cmd
git clone https://github.com/bloxstrapgold/bloxstrapgold.git
cd bloxstrapgold

dotnet build Bloxstrap.sln -c Release
```

The output executable is generated at `Bloxstrap/bin/Release/net6.0-windows/Bloxstrap.exe`.

---

### 🌐 Website (GitHub Pages)

The website in `website/` is fully static (HTML, CSS, JS) and hosted on [GitHub Pages](https://bloxstrapgold.github.io).

To deploy or publish updates:
```bash
# 1-Click publish script:
./publish_website.sh https://github.com/<USERNAME>/<REPO>.git
```
Or simply push to `main` — the included GitHub Actions workflow [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml) automatically publishes updates to GitHub Pages.

---

## 📂 Repository Structure

```
bloxstrapgold/
├── Bloxstrap/                 # Windows C# / WPF source code
├── Bloxstrap-Mac/             # macOS Swift / AppKit source code
│   ├── Sources/               # Swift source files (AppState, FastFlags, MultiInstance, UI)
│   ├── build.sh               # Fast compilation script
│   ├── package_dmg.sh         # macOS DMG packager
│   └── AppIcon.icns           # Gold Crown icon asset
├── website/                   # bloxstrapgold.github.io website source
│   ├── index.html             # Landing page, pricing matrix, tier selector
│   ├── app.js                 # Cart simulation, audio player, deep link generator
│   └── style.css              # Obsidian and gold styling
├── bridge/                    # IPC specs and synchronization utilities
├── .github/workflows/         # Automated GitHub Actions (Pages deployment)
└── README.md
```

---

## 📜 Credits & Acknowledgments

Bloxstrap Gold builds upon the work of the open-source Roblox community:

* **[Bloxstrap](https://github.com/bloxstraplabs/bloxstrap)** — Created by [pizzaboxer](https://github.com/pizzaboxer) and contributors under GPL-3.0.
* **[multi-roblox-macos](https://github.com/Insadem/multi-roblox-macos)** — Mac multi-instance process isolation research by [Insadem](https://github.com/Insadem).
* **[MultipleRobloxInstances](https://github.com/Avaluate/MultipleRobloxInstances)** — Singleton mutex bypass research by **Avaluate / Fliktem**.
* **[Roblox Account Manager (RAM)](https://github.com/ic3w0lf22/Roblox-Account-Manager)** — Multi-account management research by **ic3w0lf22**.

---

## ⚖️ License & Disclaimer

Bloxstrap Gold is distributed under the **GNU General Public License v3.0 (GPL-3.0)**.  
Bloxstrap Gold is a parody project and is **not affiliated with, maintained by, or endorsed by Roblox Corporation**.
