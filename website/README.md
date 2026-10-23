# Bloxstrap Gold — Official Satirical Website 👑

This is the satirical website for **Bloxstrap Gold**, the comedy-bit luxury edition of the open-source [Bloxstrap](https://github.com/bloxstraplabs/bloxstrap) Roblox bootstrapper with built-in multi-instance execution.

## Overview & Architecture
- **Aesthetic**: Deadpan luxury aesthetic inspired by Stripe, Apple, and Linear, elevated with champagne-gold gradients, metallic glassmorphism, and 3D virtual gold credit cards.
- **The Bit & Safety**: 
  - Strictly non-commercial parody.
  - Zero financial transactions are accepted or processed.
  - All form interactions are executed entirely client-side.
  - **Evasive "Pay" Button**: Hovering or moving near the button playfully darts away with randomized offsets. If clicked, it shows a momentary authentic loading spinner and halts with: *"Error, purchase failed, please pay later."*
  - **Stationary "Pay Later" Button**: Positioned directly beneath the pay button. Clicking it instantly provisions the **7-Day Eternal Free Trial** and generates an authentic license key starting with `GOLD-` (e.g. `GOLD-7DAY-2099`).
- **Gated FastFlags Vault & Allowlist Engine**:
  - Gated behind any license key beginning with `GOLD-[rest of key]`.
  - **Official Roblox Allowlist Validator**: Cross-references flags against Roblox's official client configuration allowlist (September 29, 2025 standard). Displays live allowlisted vs ignored/blocked badges.
  - **Interactive Presets & JSON Generator**: Configures real allowlisted flags (`DFIntTaskSchedulerTargetFps`, `DFFlagDisableDPIScale`, `FIntDebugForceMSAASamples`, `DFIntTextureQualityOverride`, etc.) and provides instant **Copy JSON** and **Download ClientAppSettings.json** buttons.
- **Segmented Renewal Pill & Side-by-Side Tier Matrix**:
  - Pill selector: `[ Weekly ] [ Monthly ] [ Quarterly ] [ Yearly (Save ~40%) ] [ Lifetime ]`
  - Real scaling: Weekly rate ($/mo equiv) > Monthly ($/mo) > Quarterly ($/mo equiv) > Yearly ($/mo equiv) > Lifetime.
  - Toggling renewal cycles dynamically updates all 3 tiers side-by-side:
    - **Gold Basic** (2 Instances, 240 FPS limit, Basic Presets)
    - **Gold Plus** (5 Instances, Monitor Refresh FPS, 18k Discord Badge, ipinfo.io telemetry) — *Most Popular*
    - **Gold Deluxe** (Unlimited Instances, Uncapped FPS, 24k Solid Gold Badge, Datacenter telemetry, Priority Threads)
  - Region & Tax selector (US state sales tax at checkout vs EU 20% VAT included).
  - Currency toggle: USD ($), EUR (€), GBP (£).
- **Interactive Multi-Instance Session Simulator**:
  - Spawn and terminate concurrent simulated Roblox clients with live RAM and FPS telemetry.
- **Bloxstrap Settings Previewer**:
  - Live toggle between Gold Edition Theme and Standard Bloxstrap Theme across General, Integrations, FastFlags, and Appearance tabs.

## GitHub Pages Deployment
This repository is configured for automatic GitHub Pages deployment:
- Includes `.nojekyll` to disable Jekyll processing.
- Includes `404.html` with automatic redirect.
- Automated GitHub Actions workflow located at `.github/workflows/deploy-pages.yml` deploys the `website/` directory on every push to `main`.

## Local Preview
Run the included Python preview server:
```bash
python3 website/serve.py
```
Then open [http://localhost:8080](http://localhost:8080) in your browser.
