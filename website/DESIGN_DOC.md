# Bloxstrap Gold — Product Design Document & Developer Specification 👑

> **Document Version:** 2.8.0  
> **Status:** Approved for Implementation  
> **Target Platforms:** Windows (WPF .NET 6) / macOS (Swift Cocoa)  
> **Author:** Antigravity System Architecture & Design Team  

---

## 1. Executive Summary & Creative Direction

### 1.1 The Premise
**Bloxstrap Gold** is an ultra-premium satirical edition of the open-source [Bloxstrap](https://github.com/bloxstraplabs/bloxstrap) Roblox bootstrapper, engineered with native **Multi-Instance execution** and **FastFlag performance optimization**.

### 1.2 The Core Satirical Bit
1. **Deadpan Luxury**: The app and website masquerade as an absurdly lavish enterprise product (reminiscent of Stripe, Apple, Linear, and Raycast). There are **no clownish banners**, cartoonish popups, or loud "THIS IS A JOKE" warnings in the main flow.
2. **The "Impossible Checkout" Loop**:
   - When users attempt to pay, the primary **Pay** button playfully dodges cursor hover with smooth physics.
   - If the user catches and clicks the button, it displays an authentic loading state for 600ms, then halts with:
     > `Error, purchase failed, please pay later.`
   - Directly underneath the evasive button sits a stationary **"Pay later"** button.
   - Clicking "Pay later" requires zero deposit, never charges money, and unlocks the **7-Day Free Trial** (which practically runs eternally) and generates an authentic license key starting with `GOLD-`.

---

## 2. Visual Design System & Palette

### 2.1 Color Tokens
All app windows, modals, and settings dialogs must strictly adhere to these color definitions:

| Token Name | Hex / Value | Usage |
| :--- | :--- | :--- |
| `--bg-main` | `#090a0d` | Root application background, deep dark foundation |
| `--bg-surface` | `#0f1014` | Primary card panels, modal content containers |
| `--bg-surface-elevated` | `#171920` | Inner inputs, tool blocks, elevated cards |
| `--gold-primary` | `#e2c076` | Brand accent, active states, key metric highlights |
| `--gold-light` | `#fce09b` | Glowing headings, currency symbols, badges |
| `--gold-dark` | `#96743a` | Metallic gradient edges, shadow borders |
| `--gold-soft` | `rgba(226, 192, 118, 0.12)` | Subtle pill backgrounds, active row fills |
| `--gold-border` | `rgba(226, 192, 118, 0.35)` | Luxury panel borders, focus rings |
| `--gold-glow` | `0 0 25px rgba(226, 192, 118, 0.18)` | Shadow glow for featured tier and modals |
| `--border-subtle` | `rgba(255, 255, 255, 0.08)` | Dividers, standard inputs, inactive cards |
| `--text-primary` | `#ffffff` | Primary titles, price numbers, cardholder name |
| `--text-secondary` | `#cbd5e1` | Feature lists, body text, descriptions |
| `--text-muted` | `#94a3b8` | Captions, periods, subtitle labels |

### 2.2 Typography
- **Primary Font Stack:** `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif`
- **Monospaced Data Font:** `ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace` (used for tabular numbers, prices, license keys, and FastFlag names).
- **Tabular Figures:** Always apply `font-variant-numeric: tabular-nums` to financial prices and RAM/FPS counters to prevent jitter.

---

## 3. Tier Hierarchy & Scaled Pricing Architecture

### 3.1 Tier Definitions

#### Tier 1: Gold Basic
- **Instance Limit:** Up to 2 concurrent Roblox clients.
- **Framerate:** Capped up to 240 FPS.
- **Audio & Visuals:** Classic "Oof" death sound restoration & custom cursor packs.
- **Discord Presence:** Basic Rich Presence with region detection.
- **Theme:** Champagne-gold launcher settings accent.

#### Tier 2: Gold Plus (Recommended / Flagship)
- **Instance Limit:** Up to 5 concurrent Roblox clients.
- **Framerate:** Dynamic uncapping matching monitor refresh rate (144Hz, 240Hz, 360Hz).
- **FastFlags:** Full FastFlag configuration and memory tuning.
- **Discord Presence:** 18k Gold badge with server ping and geolocation (ipinfo.io).
- **Theme:** Full gold launcher theme across all settings pages.

#### Tier 3: Gold Deluxe (Ultimate Privilege)
- **Instance Limit:** Unlimited concurrent instances (governed only by system RAM/CPU).
- **Framerate:** Fully uncapped (9999 FPS target scheduler).
- **FastFlags:** Complete engine thread overrides and datacenter telemetry.
- **Discord Presence:** 24k Solid Gold Prestige badge.
- **Trial Key:** Lifetime trial access.

#### Tier 4: Gold ULTRA (Sovereign Apex Edition)
- **Baseline Pricing:** $199.99/mo ($59.99/wk, $499.99/qtr, $1,599.99/yr, $2,999.99 lifetime).
- **Instance Limit:** Infinite instances with automated CPU core affinity & P-Core NUMA pinning.
- **Process Priority:** Forces `REALTIME_PRIORITY_CLASS` on all client execution threads.
- **FastFlags:** Unrestricted Ring 0 memory overrides and kernel vault access.
- **Datacenter Routing:** Direct Ashburn & Frankfurt Fiber L2 Direct Connect bypass with hardware timestamping.
- **Asset Pre-Caching:** Predictive Neural RAM Disk pre-caching places before click via gaze & mouse trajectory telemetry.
- **Audio Fidelity:** 192kHz 32-bit Dolby Atmos spatial audio upscaler for the vintage 2006 "OOF" death sound.
- **Mutex Isolation:** Kernel-Mode Mutex Annihilator (`ROBLOX_singletonEvent` driver hook).
- **Session Security:** Quantum-resistant 4096-bit TPM 2.0 enclave session isolation.
- **Crash Recovery:** 12ms automated mutex resurrection and instant memory state restoration.
- **Discord Presence:** Obsidian & Liquid Gold Sovereign animated status badge.
- **Support SLA:** Guaranteed 4-Minute Obsidian Concierge VIP direct support channel.

---

### 3.2 Pricing Matrix & Mathematical Scaling
The pricing across cycles follows a strict SaaS economic law:
$$\text{Weekly Rate (\$/mo equiv)} > \text{Monthly} > \text{Quarterly (\$/mo equiv)} > \text{Yearly (\$/mo equiv)} > \text{Lifetime}$$

| Renewal Cycle | Tier 1: Gold Basic | Tier 2: Gold Plus *(Popular)* | Tier 3: Gold Deluxe | Tier 4: Gold ULTRA *(Apex)* | Monthly Equivalent Savings |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Weekly** | **\.99** / wk | **\.99** / wk | **\.99** / wk | **\.99** / wk | Maximum flexibility |
| **Monthly** | **\.99** / mo | **\.99** / mo | **\.99** / mo | **\.99** / mo | **Baseline standard (\/mo)** |
| **Quarterly** | **\.99** / qtr | **\.99** / qtr | **\.99** / qtr | **\.99** / qtr | Save ~17% vs Monthly |
| **Yearly** | **\.99** / yr | **\.99** / yr | **\.99** / yr | **\,599.99** / yr | **Save ~33% vs Monthly** |
| **Lifetime** | **\.99** one-time | **\.99** one-time | **\.99** one-time | **\,999.99** one-time | Permanent sovereign license |

### 3.3 Jurisdiction & Currency Configuration
- **Currencies:**
  - USD (`$`): Base conversion (1.00)
  - EUR (`€`): 0.92 multiplier
  - GBP (`£`): 0.79 multiplier
- **Tax Regimes:**
  - **US (United States):** Subtotal + 8% estimated state sales tax shown at checkout.
  - **EU (European Union):** 20% VAT pre-included in price, tax line displays `$0.00 (Included)`.

---

## 4. Checkout Interaction & Payment Gateway Simulation

### 4.1 Payment Gateway Processing Simulation
- **Stationary Button:** The primary "Pay" button stays stationary and does **not** move or dodge.
- **Realistic Multi-Stage Handshake:**
  - Upon clicking `Pay [Amount]`, the button transitions to a `.processing` state with an authentic high-resolution dark/gold spinner.
  - Simulates authentic financial gateway latency (2.5 seconds total):
    1. `Contacting payment network...` (0 – 900ms)
    2. `Authorizing with card issuer...` (900 – 1800ms)
    3. `Finalizing 3D Secure protocol...` (1800 – 2600ms)
  - After 2600ms, the payment is rejected by the issuer, the button resets, and the exact error message is rendered in the red alert banner:
    > `Error, purchase failed, please pay later.`
- **Authenticity Standard:** Demo/example autofill links are explicitly excluded to maintain an authentic, high-end production appearance.

### 4.2 "Pay Later" Button & Enterprise License Provisioning
- Positioned strictly directly beneath the Pay button.
- **Zero motion:** Rock-solid stationary button.
- On click: Transitions to the Success Dialog, unlocks client instances, and generates a realistic multi-segment 32-character enterprise license key:
  $$\text{Format: } \texttt{GOLD-7DAY-XXXX-XXXX-XXXX-XXXX}$$
- Features one-click copy to clipboard with visual confirmation.

### 4.3 Deep Linking & One-Click App Activation
- **Custom URL Protocol Scheme:** `bloxstrap-gold://activate?key={KEY}`
- Registered across both Windows C# client and macOS Swift app bundle.
- Clicking **⚡ Open in Bloxstrap Gold (1-Click Activate)** in the checkout success view automatically launches or focuses the desktop application, validates the enterprise key, injects it into local settings, and unlocks all Gold privileges seamlessly.
- Direct dual platform downloads provided side-by-side: Windows (`.exe`) and macOS (`.dmg` / `.zip`).

---

## 5. FastFlags Vault & Official Roblox Allowlist Engine

### 5.1 Gating Specification
- Access requires a key matching regular expression: `^GOLD-.{2,}$` (case-insensitive).
- Unlocked state is stored in persistent local storage (`sessionStorage` or local app config).
- If key is invalid: Shake lock icon and show: `Invalid license format. Key must begin with "GOLD-".`

### 5.2 Roblox September 2025 Allowlist Compliance Matrix
Roblox strictly drops unapproved flags from `ClientAppSettings.json`. The app and validator must accurately classify flags:

| FastFlag Name | Status | Category | Function & Verification Notes |
| :--- | :--- | :--- | :--- |
| `DFIntTaskSchedulerTargetFps` | ✅ **Allowlisted** | Performance | Uncaps FPS (values: 60, 144, 240, 9999). |
| `DFFlagDisableDPIScale` | ✅ **Allowlisted** | Rendering | Disables high-DPI blur on Windows/Retina. |
| `FIntDebugForceMSAASamples` | ✅ **Allowlisted** | Anti-Aliasing | Sample count: 1 (Off), 2 (2x), 4 (4x). |
| `DFFlagTextureQualityOverrideEnabled` | ✅ **Allowlisted** | Textures | Enables manual texture downsampling override. |
| `DFIntTextureQualityOverride` | ✅ **Allowlisted** | Textures | Texture resolution levels: 0 (potato), 1, 2, 3 (ultra). |
| `FFlagHandleAltEnterFullscreenManually` | ✅ **Allowlisted** | Input | Exclusive fullscreen toggle via Alt+Enter. |
| `FFlagDebugDisplayFPS` | ✅ **Allowlisted** | Telemetry | Native HUD FPS overlay. |
| `FFlagDebugGraphicsPreferD3D11` | ✅ **Allowlisted** | Backend | Direct3D 11 rendering pipeline preference. |
| `FFlagDebugGraphicsPreferVulkan` | ✅ **Allowlisted** | Backend | Vulkan API pipeline preference. |
| `FIntFRMMaxGrassDistance` | ✅ **Allowlisted** | Graphics | Procedural grass rendering distance in studs. |
| `FFlagFixGraphicsQuality` | ✅ **Allowlisted** | Rendering | Prevents dynamic resolution reduction during combat. |
| `DFIntCanHideGuiGroupId` | ✅ **Allowlisted** | UI | Hides UI elements for developer group IDs. |
| `FFlagSimHumanoidTimestepModel` | ❌ **Blocked / Ignored** | Physics | Blocked since 2024 client anti-tamper update. |
| `FFlagDebugDisableTelemetry` | ❌ **Blocked / Ignored** | Privacy | Ignored by client bootstrapper. |
| `FFlagNewLightEngine` | ❌ **Blocked / Ignored** | Engine | Internal engineer flag only. |
| `FFlagEnableInGameMenuChrome` | ❌ **Blocked / Ignored** | UI | Server-authoritative flag; ignored in local config. |

### 5.3 Target File Paths
When exporting or deploying `ClientAppSettings.json`:
- **Windows:** `%localappdata%\Roblox\ClientSettings\ClientAppSettings.json`
- **macOS:** `~/Library/Application Support/Roblox/ClientSettings/ClientAppSettings.json`

---

## 6. Implementation Blueprint for the Desktop Application

### 6.1 State Machine
```
[Unlicensed] ---> [7-Day Trial Active] ---> [Vault Unlocked]
       |                      ^
       |                      |
       +---> [Pay Clicked] ---+ (Redirects to Pay Later)
```

1. **Trial Timer**:
   - Store `TrialStartDate` in encrypted local app storage.
   - Display a sleek golden badge in the app titlebar: `Trial: 7 Days Remaining`.
   - On day 7+, prompt the user to renew, leading back to the evasive pay window.
2. **Multi-Instance Mutex Handling**:
   - Unlock `ROBLOX_singletonMutex` or launch client processes with isolated session identifiers.
   - Track PID, memory usage (MB), and active Roblox game.
3. **Settings UI**:
   - Replicate the tabbed navigation: **General**, **Integrations**, **FastFlags**, and **Appearance**.
   - Provide a toggle to switch between the standard purple Bloxstrap theme and the 24k Gold Edition theme.

---

## 7. Deliverables & File Index

| Asset | Location |
| :--- | :--- |
| **Website Entrypoint** | [`website/index.html`](index.html) |
| **Website Styling & Themes** | [`website/style.css`](style.css) |
| **Website JavaScript Engine** | [`website/app.js`](app.js) |
| **Local Preview Server** | [`website/serve.py`](serve.py) (`http://localhost:8080`) |
| **GitHub Pages Workflow** | [`.github/workflows/deploy-pages.yml`](../.github/workflows/deploy-pages.yml) |
| **macOS Native App** | [`Bloxstrap-Mac/BloxstrapGold.app`](../Bloxstrap-Mac/BloxstrapGold.app) |
| **Windows .NET Source** | [`Bloxstrap/`](../Bloxstrap) |
