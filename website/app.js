/**
 * Bloxstrap Gold — Core Logic & Interactive Engine
 * 
 * Includes:
 * 1. Scaled Pricing & Side-by-Side Tier Rendering (Weekly > Monthly > Quarterly > Yearly > Lifetime)
 * 2. Segmented Renewal Pill Switching
 * 3. Evasive "Pay" Button (Smooth darting movement, no bubbles, fails with exact prompt error)
 * 4. Stationary "Pay later" button (unfreezes 7-day trial & license key)
 * 5. FastFlags Vault gated by license key starting with "GOLD-"
 * 6. Official Roblox Client FastFlag Allowlist Validator (Sept 2025 allowlist database)
 * 7. Live ClientAppSettings.json builder with Copy and Download JSON
 * 8. Multi-Instance Process Isolation Simulator
 * 9. Bloxstrap App Window Theme & Tab Switcher
 */

// =============================================================================
// PRICING & TIER DATA
// =============================================================================
const TIERS_META = {
  1: {
    id: 1,
    name: 'Gold Basic',
    badge: 'Barely Gold Edition',
    icon: '🪙',
    desc: 'For people who can only afford to farm on one alt while their main lags.',
    instanceLimit: 2,
    features: [
      'Up to 2 instances (1 for you, 1 alt that will probably crash)',
      'Hard 240 FPS limit (you don\'t deserve uncapped yet)',
      'Standard Roblox crash screens (good luck reconnecting)',
      'Low-tier bronze Discord status that basically says "I tried"',
      'Basic FastFlags only (nothing that actually helps your ping)',
      'Email support (replies in 3 to 5 business days if we feel like it)'
    ]
  },
  2: {
    id: 2,
    name: 'Gold Plus',
    badge: 'Aggressively Mid Edition',
    icon: '👑',
    desc: '5 instances. Your fans will sound like a jet engine, but at least your friends think you have money.',
    instanceLimit: 5,
    featured: true,
    ribbon: 'Most Popular',
    features: [
      'Up to 5 instances (your CPU is going to melt)',
      'FPS locked to your monitor refresh rate (why would you need more?)',
      '18k gold Discord badge (everyone will know you couldn\'t afford Ultra)',
      'Standard memory cleanup (still starts leaking RAM after 2 hours)',
      'Server ping display (so you can watch yourself lag in real-time)',
      'Priority ticket queue (strictly behind all Ultra members)'
    ]
  },
  3: {
    id: 3,
    name: 'Gold Deluxe',
    badge: 'Almost Rich Edition',
    icon: '💎',
    desc: 'Unlimited instances, but you\'re still missing the god-tier privileges and everyone knows it.',
    instanceLimit: 999,
    ribbon: 'Upper Class',
    features: [
      'Unlimited instances (until Windows runs out of pagefile and dies)',
      'Uncapped 9999 FPS target (renders frames your eyes physically can\'t see)',
      'Solid gold Discord badge (looks nice, but everyone knows Ultra exists)',
      'Manual FastFlag editor (you have to write your own JSON, no hand-holding)',
      'Auto-reconnect prompt when Roblox kicks you with Error 273',
      'You still don\'t get the Ultra badge, which is frankly embarrassing'
    ]
  },
  4: {
    id: 4,
    name: 'Gold ULTRA',
    badge: 'God Complex Edition',
    icon: '🌌',
    desc: 'For people with more money than sense. Infinite alts, zero lag, and Roblox legally required to respect you.',
    instanceLimit: 9999,
    ribbon: '$200/mo Apex',
    ultra: true,
    features: [
      'Infinite instances with zero RAM guilt (we bully Windows into prioritizing your alts)',
      'Roblox Error 273 & 268 bypass (reconnects before the server even knows you got kicked)',
      'Uncapped 9999 FPS (draws frames your monitor physically cannot display just to flex)',
      'Original 2006 "OOF" sound with max bass boost (replaces modern death squish)',
      'Obsidian & Liquid Gold Discord Rich Presence (friends will ask why you spent $200 on Bloxstrap)',
      'P-Core CPU priority (pushes Chrome and Discord to the background so Roblox gets 100% CPU)',
      'Instant Place Join (skips server loading screen animations and matchmaking queues)',
      'Pre-tuned god-tier FastFlags (all 12 allowlisted flags dialed in so you never drop a frame)',
      'Anti-freeze crash protector (if one alt freezes, the other 40 keep farming)',
      'Zero-cooldown server hopping (hops servers faster than Roblox\'s API can rate-limit you)',
      'Direct route optimizer (picks the fastest server and bullies it into letting you in)',
      'The right to look down on everyone on Basic, Plus, and Deluxe',
      'Everything in the lower tiers, but without the shame'
    ]
  }
};

// Strictly scaled pricing: Weekly rate ($/mo equiv) > Monthly ($/mo) > Quarterly ($/mo equiv) > Yearly ($/mo equiv) > Lifetime
const PRICING_MATRIX = {
  weekly: {
    cycleId: 'weekly',
    label: 'Weekly',
    periodText: '/ week',
    tiers: {
      1: { price: 2.99, monthlyEquiv: 11.96, savings: 'Billed weekly • Minimal commitment' },
      2: { price: 4.99, monthlyEquiv: 19.96, savings: 'Billed weekly • Mid-tier tax' },
      3: { price: 7.99, monthlyEquiv: 31.96, savings: 'Billed weekly • Expensive, still not Ultra' },
      4: { price: 59.99, monthlyEquiv: 239.96, savings: 'Billed weekly • $60/wk just to flex on alts' }
    }
  },
  monthly: {
    cycleId: 'monthly',
    label: 'Monthly',
    periodText: '/ month',
    tiers: {
      1: { price: 6.99, monthlyEquiv: 6.99, savings: 'Save 42% vs weekly • Still budget' },
      2: { price: 12.99, monthlyEquiv: 12.99, savings: 'Save 35% vs weekly • Aggressively mid' },
      3: { price: 19.99, monthlyEquiv: 19.99, savings: 'Save 38% vs weekly • Upper peasant tier' },
      4: { price: 199.99, monthlyEquiv: 199.99, savings: 'The full $200/mo god complex' }
    }
  },
  quarterly: {
    cycleId: 'quarterly',
    label: 'Quarterly',
    periodText: '/ quarter',
    tiers: {
      1: { price: 16.99, monthlyEquiv: 5.66, savings: 'Save 19% (~$5.66/mo) • Budget quarterly' },
      2: { price: 29.99, monthlyEquiv: 9.99, savings: 'Save 23% (~$9.99/mo) • Mid quarterly' },
      3: { price: 46.99, monthlyEquiv: 15.66, savings: 'Save 22% (~$15.66/mo) • Deluxe quarterly' },
      4: { price: 499.99, monthlyEquiv: 166.66, savings: 'Save 17% (~$166.66/mo) • Sovereign quarterly' }
    }
  },
  yearly: {
    cycleId: 'yearly',
    label: 'Yearly',
    periodText: '/ year',
    tiers: {
      1: { price: 49.99, monthlyEquiv: 4.16, savings: 'Save 40% on being budget (~$4.16/mo)' },
      2: { price: 89.99, monthlyEquiv: 7.49, savings: 'Save 42% on being mid (~$7.49/mo)' },
      3: { price: 139.99, monthlyEquiv: 11.66, savings: 'Save 41% on being almost rich (~$11.66/mo)' },
      4: { price: 1599.99, monthlyEquiv: 133.33, savings: 'Save 33% on pure sovereign supremacy' }
    }
  },
  lifetime: {
    cycleId: 'lifetime',
    label: 'Lifetime',
    periodText: 'one-time',
    tiers: {
      1: { price: 99.99, monthlyEquiv: null, savings: 'Pay once, stay budget forever' },
      2: { price: 189.99, monthlyEquiv: null, savings: 'Pay once, stay mid forever' },
      3: { price: 349.99, monthlyEquiv: null, savings: 'Pay once, almost rich forever' },
      4: { price: 2999.99, monthlyEquiv: null, savings: 'One-time $3,000 investment in Roblox supremacy' }
    }
  }
};

const CURRENCIES = {
  USD: { symbol: '$', rate: 1.0 },
  EUR: { symbol: '€', rate: 0.92 },
  GBP: { symbol: '£', rate: 0.79 }
};

// =============================================================================
// OFFICIAL ROBLOX CLIENT ALLOWLIST DATABASE (SEPTEMBER 2025 STANDARD)
// =============================================================================
const FASTFLAG_DATABASE = [
  {
    name: 'DFIntTaskSchedulerTargetFps',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Uncaps target client framerate. Accepted values: 60, 144, 240, 9999.'
  },
  {
    name: 'DFFlagDisableDPIScale',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Disables Windows display scaling for crisp 1:1 pixel rendering at high resolutions.'
  },
  {
    name: 'FIntDebugForceMSAASamples',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Forces multi-sample anti-aliasing sample count (1, 2, 4) to eliminate geometric jagged edges.'
  },
  {
    name: 'DFFlagTextureQualityOverrideEnabled',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Enables manual override of Roblox texture streaming downsampling.'
  },
  {
    name: 'DFIntTextureQualityOverride',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Sets texture resolution level: 0 (potato/performance), 1 (medium), 2 (high), 3 (ultra native).'
  },
  {
    name: 'FFlagHandleAltEnterFullscreenManually',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Enables manual Alt+Enter exclusive fullscreen switching for improved input latency.'
  },
  {
    name: 'FFlagDebugDisplayFPS',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Activates Roblox native on-screen telemetry overlay showing client render framerate.'
  },
  {
    name: 'FFlagDebugGraphicsPreferD3D11',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Directs the client rendering engine to prioritize the Direct3D 11 backend.'
  },
  {
    name: 'FFlagDebugGraphicsPreferVulkan',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Directs the client rendering engine to prioritize Vulkan API on supported GPUs.'
  },
  {
    name: 'FIntFRMMaxGrassDistance',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Controls maximum distance (in studs) at which procedural grass blades are rendered.'
  },
  {
    name: 'FFlagFixGraphicsQuality',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Prevents automatic engine downscaling during heavy particle simulation scenes.'
  },
  {
    name: 'DFIntCanHideGuiGroupId',
    status: 'allowed',
    tag: 'Allowlisted',
    desc: 'Allows hiding user interface components for specific developer and group test scenarios.'
  },
  {
    name: 'FFlagSimHumanoidTimestepModel',
    status: 'blocked',
    tag: 'Ignored / Blocked',
    desc: 'Silently discarded on startup. Physics and timestep tampering is strictly locked by client security.'
  },
  {
    name: 'FFlagDebugDisableTelemetry',
    status: 'blocked',
    tag: 'Ignored / Blocked',
    desc: 'Excluded from official client allowlist. Local overrides are ignored by the bootstrapper.'
  },
  {
    name: 'FFlagNewLightEngine',
    status: 'blocked',
    tag: 'Ignored / Blocked',
    desc: 'Internal developer flag. Dropped on startup if found in ClientAppSettings.json.'
  },
  {
    name: 'FFlagEnableInGameMenuChrome',
    status: 'blocked',
    tag: 'Ignored / Blocked',
    desc: 'Server-authoritative UI flag. Local client overrides are not processed.'
  }
];

// =============================================================================
// GLOBAL APP STATE
// =============================================================================
let currentCycle = 'yearly';
let currentCurrency = 'USD';
let currentRegion = 'us';
let selectedCheckoutTier = 2;
let selectedCheckoutCycle = 'yearly';

// Multi-instance state
let runningInstances = [
  { id: 1, account: 'RobloxAccount_1', game: 'Pet Simulator 99', ram: 420, fps: 165 },
  { id: 2, account: 'RobloxAccount_2', game: 'Blox Fruits', ram: 380, fps: 144 }
];

// =============================================================================
// INITIALIZATION
// =============================================================================
document.addEventListener('DOMContentLoaded', () => {
  setupRenewalPills();
  setupCurrencyAndTax();
  setupFastFlagsVault();
  setupPayingWindow();
  setupMultiInstanceSimulator();
  setupAppThemePreview();
  setupModals();
  setupFaq();
  setupWingetCopy();

  // Initial render of the 3 tier cards side-by-side
  renderTierCards();
});

// =============================================================================
// 1. RENEWAL PILL CYCLING & 3-CARD SIDE-BY-SIDE RENDERING
// =============================================================================
function setupRenewalPills() {
  const pillBtns = document.querySelectorAll('.renewal-pill-btn');
  if (!pillBtns || pillBtns.length === 0) return;

  pillBtns.forEach((btn) => {
    btn.addEventListener('click', () => {
      const targetCycle = btn.dataset.cycle;
      if (!targetCycle || !PRICING_MATRIX[targetCycle]) return;

      // Update active state on buttons
      pillBtns.forEach((b) => b.classList.remove('active'));
      btn.classList.add('active');

      currentCycle = targetCycle;
      renderTierCards();
    });
  });
}

function setupCurrencyAndTax() {
  const regionSelector = document.getElementById('regionSelector');
  const currencySelector = document.getElementById('currencySelector');

  if (regionSelector) {
    regionSelector.addEventListener('change', (e) => {
      currentRegion = e.target.value;
      renderTierCards();
    });
  }

  if (currencySelector) {
    currencySelector.addEventListener('change', (e) => {
      currentCurrency = e.target.value;
      renderTierCards();
    });
  }
}

function renderTierCards() {
  const grid = document.getElementById('pricingCardsGrid');
  if (!grid) return;

  const cycleData = PRICING_MATRIX[currentCycle] || PRICING_MATRIX.yearly;
  const curr = CURRENCIES[currentCurrency] || CURRENCIES.USD;

  grid.innerHTML = '';

  // Render Tier 1, Tier 2, Tier 3, and Tier 4 side-by-side
  [1, 2, 3, 4].forEach((tierId) => {
    const meta = TIERS_META[tierId];
    const plan = cycleData.tiers[tierId];
    if (!meta || !plan) return;

    const basePrice = (plan.price * curr.rate).toFixed(2);
    const monthlyEquiv = plan.monthlyEquiv ? (plan.monthlyEquiv * curr.rate).toFixed(2) : null;

    let taxNotice = '';
    if (currentRegion === 'us') {
      taxNotice = 'State sales tax calculated at checkout';
    } else {
      taxNotice = '20% VAT included in price';
    }

    const card = document.createElement('div');
    card.className = `pricing-card ${meta.featured ? 'featured' : ''} ${meta.ultra ? 'ultra' : ''}`;

    card.innerHTML = `
      ${meta.ribbon ? `<div class="card-ribbon">${meta.ribbon}</div>` : ''}
      <div class="plan-cycle-name">${meta.name}</div>
      <div style="font-size: 0.8rem; color: #94a3b8; margin-bottom: 0.75rem;">${meta.badge}</div>

      <div class="plan-price-wrap">
        <span class="price-currency">${curr.symbol}</span>
        <span class="price-value">${basePrice}</span>
        <span class="price-period">${cycleData.periodText}</span>
      </div>

      <div class="plan-scale-indicator">
        <div class="monthly-equiv">
          ${monthlyEquiv ? `~${curr.symbol}${monthlyEquiv} / mo equiv.` : `<span class="lifetime-text">Permanent Lifetime License</span>`}
        </div>
        <span class="savings-tag" style="color: var(--gold-light); font-size: 0.78rem;">${plan.savings}</span>
      </div>

      <div class="tax-disclaimer-text">${taxNotice}</div>

      <ul class="plan-features-list">
        ${meta.features.map(f => `
          <li class="plan-feature-item">
            <span class="check-icon">✓</span>
            <span>${f}</span>
          </li>
        `).join('')}
      </ul>

      <button class="btn-plan-select" onclick="openCheckout(${tierId}, '${currentCycle}')">
        Get ${meta.name}
      </button>
    `;

    grid.appendChild(card);
  });
}

// =============================================================================
// 2. CHECKOUT MODAL & EVASIVE "PAY" BUTTON LOGIC
// =============================================================================
function setupPayingWindow() {
  const buyPayBtn = document.getElementById('buyPayBtn');
  const payLaterBtn = document.getElementById('payLaterBtn');
  const closeCheckoutBtn = document.getElementById('closeCheckoutBtn');
  const checkoutModal = document.getElementById('checkoutModal');
  const successUnlockVaultBtn = document.getElementById('successUnlockVaultBtn');

  // Input syncing with 3D virtual gold card
  const cardNameInput = document.getElementById('cardName');
  const cardNumberInput = document.getElementById('cardNumber');
  const cardExpInput = document.getElementById('cardExp');

  if (cardNameInput) {
    cardNameInput.addEventListener('input', (e) => {
      const val = e.target.value.trim();
      const vcName = document.getElementById('vcName');
      if (vcName) vcName.textContent = val ? val.toUpperCase() : 'YOUR NAME';
    });
  }

  if (cardNumberInput) {
    cardNumberInput.addEventListener('input', (e) => {
      let val = e.target.value.replace(/\D/g, '').substring(0, 16);
      let formatted = val.match(/.{1,4}/g)?.join(' ') || val;
      e.target.value = formatted;
      const vcNum = document.getElementById('vcNumber');
      if (vcNum) vcNum.textContent = formatted || '•••• •••• •••• ••••';
    });
  }

  if (cardExpInput) {
    cardExpInput.addEventListener('input', (e) => {
      let val = e.target.value.replace(/\D/g, '').substring(0, 4);
      if (val.length >= 3) {
        val = val.substring(0, 2) + '/' + val.substring(2);
      }
      e.target.value = val;
      const vcExp = document.getElementById('vcExp');
      if (vcExp) vcExp.textContent = val || 'MM/YY';
    });
  }

  // Click-to-copy handler on generated license key
  const licenseKeyBox = document.getElementById('generatedLicenseKey');
  const copyFeedback = document.getElementById('copyKeyFeedback');
  if (licenseKeyBox) {
    licenseKeyBox.addEventListener('click', () => {
      const keyText = licenseKeyBox.textContent.trim();
      navigator.clipboard.writeText(keyText).then(() => {
        if (copyFeedback) {
          copyFeedback.textContent = '✓ Copied license key to clipboard!';
          setTimeout(() => { if (copyFeedback) copyFeedback.textContent = ''; }, 2500);
        }
      });
    });
  }

  // REALISTIC PAYMENT PROCESSING LOGIC:
  // The button stays firmly stationary (no running away).
  // Clicking simulates real gateway handshakes before declining with prompt's exact error string.
  if (buyPayBtn) {
    buyPayBtn.addEventListener('click', (e) => {
      e.preventDefault();
      if (buyPayBtn.classList.contains('processing')) return;

      const originalText = buyPayBtn.innerHTML;
      buyPayBtn.classList.add('processing');
      buyPayBtn.style.pointerEvents = 'none';

      const errorBanner = document.getElementById('checkoutErrorBanner');
      if (errorBanner) errorBanner.classList.remove('show');

      // Stage 1: Network Contact
      buyPayBtn.innerHTML = '<span class="btn-spinner"></span> Contacting payment network...';

      // Stage 2: Issuer Authorization
      setTimeout(() => {
        buyPayBtn.innerHTML = '<span class="btn-spinner"></span> Authorizing with card issuer...';
      }, 900);

      // Stage 3: 3D Secure / Verification
      setTimeout(() => {
        buyPayBtn.innerHTML = '<span class="btn-spinner"></span> Finalizing 3D Secure protocol...';
      }, 1800);

      // Stage 4: Decline & Prompt-Mandated Error Message
      setTimeout(() => {
        buyPayBtn.classList.remove('processing');
        buyPayBtn.innerHTML = originalText;
        buyPayBtn.style.pointerEvents = 'auto';

        if (errorBanner) {
          errorBanner.classList.add('show');
          errorBanner.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
      }, 2600);
    });
  }

  // STATIONARY "PAY LATER" BUTTON:
  // Directly beneath the pay button. Never moves. Triggers the 7-day free trial.
  if (payLaterBtn) {
    payLaterBtn.addEventListener('click', () => {
      startFreeTrial();
    });
  }

  if (closeCheckoutBtn) {
    closeCheckoutBtn.addEventListener('click', closeCheckout);
  }

  if (checkoutModal) {
    checkoutModal.addEventListener('click', (e) => {
      if (e.target === checkoutModal) closeCheckout();
    });
  }

  if (successUnlockVaultBtn) {
    successUnlockVaultBtn.addEventListener('click', () => {
      const generatedKey = document.getElementById('generatedLicenseKey')?.textContent || 'GOLD-7DAY-8849-F291-C84B-9102-E7A4';
      unlockVaultWithKey(generatedKey);
      closeCheckout();
      const vaultSec = document.getElementById('fastflags');
      if (vaultSec) vaultSec.scrollIntoView({ behavior: 'smooth' });
    });
  }
}

function openCheckout(tierId = 2, cycle = 'yearly') {
  selectedCheckoutTier = tierId;
  selectedCheckoutCycle = cycle;

  const modal = document.getElementById('checkoutModal');
  const formView = document.getElementById('checkoutFormView');
  const successView = document.getElementById('checkoutSuccessView');
  const errorBanner = document.getElementById('checkoutErrorBanner');
  const buyPayBtn = document.getElementById('buyPayBtn');

  if (!modal) return;

  // Reset views
  if (formView) formView.style.display = '';
  if (successView) successView.classList.remove('show');
  if (errorBanner) errorBanner.classList.remove('show');
  if (buyPayBtn) {
    buyPayBtn.classList.remove('processing');
    buyPayBtn.style.pointerEvents = 'auto';
  }

  // Calculate prices
  const meta = TIERS_META[tierId] || TIERS_META[2];
  const cycleData = PRICING_MATRIX[cycle] || PRICING_MATRIX.yearly;
  const tierPriceObj = cycleData.tiers[tierId] || cycleData.tiers[2];
  const curr = CURRENCIES[currentCurrency] || CURRENCIES.USD;

  const basePrice = tierPriceObj.price * curr.rate;
  let taxRate = currentRegion === 'us' ? 0.08 : 0.00;
  let taxAmount = currentRegion === 'us' ? basePrice * taxRate : 0.00;
  let totalPrice = basePrice + taxAmount;

  // Populate checkout modal UI
  const summaryTier = document.getElementById('checkoutSummaryTier');
  const summaryCycle = document.getElementById('checkoutSummaryCycle');
  const basePriceEl = document.getElementById('checkoutBasePrice');
  const taxPriceEl = document.getElementById('checkoutTaxPrice');
  const taxLabelEl = document.getElementById('checkoutTaxLabel');
  const totalPriceEl = document.getElementById('checkoutTotalPrice');

  if (summaryTier) summaryTier.textContent = `${meta.name} (${meta.badge})`;
  if (summaryCycle) summaryCycle.textContent = `${cycleData.label} Plan (${cycleData.periodText})`;
  if (basePriceEl) basePriceEl.textContent = `${curr.symbol}${basePrice.toFixed(2)}`;

  if (taxPriceEl && taxLabelEl) {
    if (currentRegion === 'us') {
      taxLabelEl.textContent = 'Estimated Tax (8%):';
      taxPriceEl.textContent = `${curr.symbol}${taxAmount.toFixed(2)}`;
    } else {
      taxLabelEl.textContent = 'VAT (20% Included):';
      taxPriceEl.textContent = `${curr.symbol}0.00`;
    }
  }

  if (totalPriceEl) totalPriceEl.textContent = `${curr.symbol}${totalPrice.toFixed(2)}`;
  if (buyPayBtn) buyPayBtn.textContent = `Pay ${curr.symbol}${totalPrice.toFixed(2)}`;

  modal.classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeCheckout() {
  const modal = document.getElementById('checkoutModal');
  if (modal) modal.classList.remove('open');
  document.body.style.overflow = '';
}

function generateEnterpriseKey() {
  const seg = () => Math.random().toString(36).substring(2, 6).toUpperCase();
  return `GOLD-7DAY-${seg()}-${seg()}-${seg()}-${seg()}`;
}

function startFreeTrial() {
  const formView = document.getElementById('checkoutFormView');
  const successView = document.getElementById('checkoutSuccessView');
  const licenseKeyEl = document.getElementById('generatedLicenseKey');
  const deepLinkActivateBtn = document.getElementById('deepLinkActivateBtn');

  // Generate authentic multi-segment enterprise key
  const generatedKey = generateEnterpriseKey();

  if (licenseKeyEl) {
    licenseKeyEl.textContent = generatedKey;
  }

  if (deepLinkActivateBtn) {
    deepLinkActivateBtn.href = `bloxstrap-gold://activate?key=${encodeURIComponent(generatedKey)}`;
  }

  if (formView) formView.style.display = 'none';
  if (successView) successView.classList.add('show');
}

// =============================================================================
// 3. FASTFLAGS VAULT & OFFICIAL ALLOWLIST VALIDATOR
// =============================================================================
function setupFastFlagsVault() {
  const vaultUnlockBtn = document.getElementById('vaultUnlockBtn');
  const vaultKeyInput = document.getElementById('vaultKeyInput');
  const vaultRelockBtn = document.getElementById('vaultRelockBtn');
  const allowlistSearchInput = document.getElementById('allowlistSearchInput');
  const allowlistClearBtn = document.getElementById('allowlistClearBtn');
  const copyVaultJsonBtn = document.getElementById('copyVaultJsonBtn');
  const downloadVaultJsonBtn = document.getElementById('downloadVaultJsonBtn');

  // Check if previously unlocked in this session
  const storedKey = sessionStorage.getItem('bloxstrap_gold_vault_key');
  if (storedKey && isValidGoldKey(storedKey)) {
    unlockVaultWithKey(storedKey, false);
  }

  if (vaultUnlockBtn && vaultKeyInput) {
    const handleUnlock = () => {
      const enteredKey = vaultKeyInput.value.trim();
      if (isValidGoldKey(enteredKey)) {
        unlockVaultWithKey(enteredKey, true);
      } else {
        triggerKeyError();
      }
    };

    vaultUnlockBtn.addEventListener('click', handleUnlock);
    vaultKeyInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') handleUnlock();
    });
  }

  if (vaultRelockBtn) {
    vaultRelockBtn.addEventListener('click', lockVault);
  }

  // Allowlist search filter
  if (allowlistSearchInput) {
    allowlistSearchInput.addEventListener('input', (e) => {
      renderAllowlistFlags(e.target.value);
    });
  }

  if (allowlistClearBtn && allowlistSearchInput) {
    allowlistClearBtn.addEventListener('click', () => {
      allowlistSearchInput.value = '';
      renderAllowlistFlags('');
    });
  }

  // Preset inputs that update ClientAppSettings.json live
  const presetControls = [
    'vTargetFps',
    'vDisableDpi',
    'vMsaaSamples',
    'vTextureQuality',
    'vAltEnter',
    'vDebugFps'
  ];

  presetControls.forEach((id) => {
    const el = document.getElementById(id);
    if (el) {
      el.addEventListener('input', updateVaultJsonPreview);
      el.addEventListener('change', updateVaultJsonPreview);
    }
  });

  // Copy JSON button
  if (copyVaultJsonBtn) {
    copyVaultJsonBtn.addEventListener('click', () => {
      const codeBlock = document.getElementById('vaultJsonOutput');
      if (!codeBlock) return;
      navigator.clipboard.writeText(codeBlock.textContent).then(() => {
        const originalText = copyVaultJsonBtn.textContent;
        copyVaultJsonBtn.textContent = '✓ Copied!';
        setTimeout(() => {
          copyVaultJsonBtn.textContent = originalText;
        }, 1500);
      });
    });
  }

  // Download ClientAppSettings.json button
  if (downloadVaultJsonBtn) {
    downloadVaultJsonBtn.addEventListener('click', () => {
      const codeBlock = document.getElementById('vaultJsonOutput');
      if (!codeBlock) return;
      const blob = new Blob([codeBlock.textContent], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'ClientAppSettings.json';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    });
  }

  // Initial render of allowlist cards & JSON
  renderAllowlistFlags('');
  updateVaultJsonPreview();
}

function isValidGoldKey(key) {
  if (!key) return false;
  return key.trim().toUpperCase().startsWith('GOLD-') && key.trim().length >= 6;
}

function unlockVaultWithKey(key, shouldAnimate = true) {
  sessionStorage.setItem('bloxstrap_gold_vault_key', key.toUpperCase());

  const lockedCard = document.getElementById('vaultLockedCard');
  const unlockedCard = document.getElementById('vaultUnlockedCard');
  const activeKeyDisplay = document.getElementById('activeVaultKeyDisplay');
  const keyError = document.getElementById('vaultKeyError');

  if (keyError) keyError.classList.remove('show');
  if (activeKeyDisplay) activeKeyDisplay.textContent = key.toUpperCase();

  if (lockedCard) lockedCard.style.display = 'none';
  if (unlockedCard) {
    unlockedCard.style.display = 'block';
    if (shouldAnimate) {
      unlockedCard.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }
}

function lockVault() {
  sessionStorage.removeItem('bloxstrap_gold_vault_key');
  const lockedCard = document.getElementById('vaultLockedCard');
  const unlockedCard = document.getElementById('vaultUnlockedCard');
  const keyInput = document.getElementById('vaultKeyInput');

  if (keyInput) keyInput.value = '';
  if (unlockedCard) unlockedCard.style.display = 'none';
  if (lockedCard) lockedCard.style.display = 'block';
}

function triggerKeyError() {
  const lockIcon = document.getElementById('vaultLockIcon');
  const keyError = document.getElementById('vaultKeyError');

  if (lockIcon) {
    lockIcon.classList.remove('shake');
    void lockIcon.offsetWidth; // trigger reflow
    lockIcon.classList.add('shake');
  }

  if (keyError) {
    keyError.classList.add('show');
  }
}

function renderAllowlistFlags(filterQuery = '') {
  const container = document.getElementById('allowlistResultsList');
  if (!container) return;

  const query = filterQuery.toLowerCase().trim();
  const matchedFlags = FASTFLAG_DATABASE.filter(f => {
    if (!query) return true;
    return f.name.toLowerCase().includes(query) || f.desc.toLowerCase().includes(query);
  });

  if (matchedFlags.length === 0) {
    container.innerHTML = `
      <div style="grid-column: 1 / -1; padding: 2rem; text-align: center; color: #64748b; font-size: 0.9rem;">
        No FastFlags matching "${filterQuery}". Unlisted flags are blocked by Roblox client allowlist.
      </div>
    `;
    return;
  }

  container.innerHTML = matchedFlags.map(f => {
    const isAllowed = f.status === 'allowed';
    return `
      <div class="allowlist-flag-card ${isAllowed ? 'allowed' : 'blocked'}">
        <div class="flag-header-row">
          <span class="flag-name-text">${f.name}</span>
          <span class="flag-status-pill ${isAllowed ? 'pill-allowed' : 'pill-blocked'}">
            ${isAllowed ? '✓ ALLOWLISTED' : '✕ BLOCKED / IGNORED'}
          </span>
        </div>
        <div class="flag-desc-text">${f.desc}</div>
      </div>
    `;
  }).join('');
}

function updateVaultJsonPreview() {
  const targetFps = parseInt(document.getElementById('vTargetFps')?.value || '9999', 10);
  const disableDpi = document.getElementById('vDisableDpi')?.checked ?? true;
  const msaaSamples = parseInt(document.getElementById('vMsaaSamples')?.value || '4', 10);
  const textureQuality = parseInt(document.getElementById('vTextureQuality')?.value || '3', 10);
  const altEnter = document.getElementById('vAltEnter')?.checked ?? true;
  const debugFps = document.getElementById('vDebugFps')?.checked ?? true;

  const config = {
    DFIntTaskSchedulerTargetFps: targetFps,
    DFFlagDisableDPIScale: disableDpi,
    FIntDebugForceMSAASamples: msaaSamples,
    DFFlagTextureQualityOverrideEnabled: true,
    DFIntTextureQualityOverride: textureQuality,
    FFlagHandleAltEnterFullscreenManually: altEnter,
    FFlagDebugDisplayFPS: debugFps
  };

  const codeEl = document.getElementById('vaultJsonOutput');
  if (codeEl) {
    codeEl.textContent = JSON.stringify(config, null, 2);
  }
}

// =============================================================================
// 4. MULTI-INSTANCE SIMULATOR
// =============================================================================
function setupMultiInstanceSimulator() {
  const addBtn = document.getElementById('addInstanceBtn');
  const launchAllBtn = document.getElementById('launchAllBtn');

  if (addBtn) {
    addBtn.addEventListener('click', () => {
      addSimulatedInstance();
    });
  }

  if (launchAllBtn) {
    launchAllBtn.addEventListener('click', () => {
      launchMaxInstances();
    });
  }

  renderInstanceList();
}

function renderInstanceList() {
  const listEl = document.getElementById('simulatedInstancesList');
  const countEl = document.getElementById('simulatedInstanceCount');
  const ramEl = document.getElementById('simulatedTotalRam');

  if (!listEl) return;

  listEl.innerHTML = '';

  let totalRam = 0;
  runningInstances.forEach((inst) => {
    totalRam += inst.ram;
    const item = document.createElement('div');
    item.className = 'sim-instance-item';
    item.innerHTML = `
      <div class="sim-instance-badge">
        <span class="sim-instance-dot"></span>
        <span style="font-weight: 700; color: #fff;">${inst.account}</span>
      </div>
      <div class="sim-game-name">${inst.game}</div>
      <div class="sim-ram-usage tabular">${inst.ram} MB RAM &bull; ${inst.fps} FPS</div>
      <button class="sim-btn-kill" onclick="killSimulatedInstance(${inst.id})">&times;</button>
    `;
    listEl.appendChild(item);
  });

  if (countEl) countEl.textContent = `${runningInstances.length} Active`;
  if (ramEl) ramEl.textContent = `${(totalRam / 1024).toFixed(2)} GB RAM`;
}

function addSimulatedInstance() {
  const maxLimit = TIERS_META[selectedCheckoutTier]?.instanceLimit || 5;
  const errorEl = document.getElementById('instanceLimitError');

  if (runningInstances.length >= maxLimit) {
    if (errorEl) {
      errorEl.textContent = `Instance limit reached for ${TIERS_META[selectedCheckoutTier].name} (Max ${maxLimit}). Upgrade tier for more.`;
      setTimeout(() => { if (errorEl) errorEl.textContent = ''; }, 3500);
    }
    return;
  }

  const nextId = runningInstances.length > 0 ? Math.max(...runningInstances.map(i => i.id)) + 1 : 1;
  const games = ['Blox Fruits', 'Pet Simulator 99', 'Arsenal', 'Jailbreak', 'Rivals', 'BedWars'];
  const randomGame = games[Math.floor(Math.random() * games.length)];
  const randomRam = Math.floor(Math.random() * 80) + 360;
  const randomFps = Math.floor(Math.random() * 40) + 140;

  runningInstances.push({
    id: nextId,
    account: `RobloxAccount_${nextId}`,
    game: randomGame,
    ram: randomRam,
    fps: randomFps
  });

  renderInstanceList();
}

function launchMaxInstances() {
  const maxLimit = TIERS_META[selectedCheckoutTier]?.instanceLimit || 5;
  while (runningInstances.length < Math.min(maxLimit, 8)) {
    addSimulatedInstance();
  }
}

window.killSimulatedInstance = function(id) {
  runningInstances = runningInstances.filter(i => i.id !== id);
  renderInstanceList();
};

// =============================================================================
// 5. INTERACTIVE BLOXSTRAP APP THEME PREVIEW
// =============================================================================
function setupAppThemePreview() {
  const themeBtns = document.querySelectorAll('.theme-toggle-btn');
  const appWindow = document.getElementById('bloxstrapAppWindow');
  const tabBtns = document.querySelectorAll('.app-tab-btn');

  themeBtns.forEach((btn) => {
    btn.addEventListener('click', () => {
      themeBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const theme = btn.dataset.theme;
      if (appWindow) {
        if (theme === 'gold') {
          appWindow.classList.add('gold-theme');
          appWindow.classList.remove('standard-theme');
        } else {
          appWindow.classList.remove('gold-theme');
          appWindow.classList.add('standard-theme');
        }
      }
    });
  });

  tabBtns.forEach((btn) => {
    btn.addEventListener('click', () => {
      tabBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const targetTab = btn.dataset.tab;
      document.querySelectorAll('.app-tab-content').forEach((pane) => {
        pane.style.display = (pane.id === `tab-${targetTab}`) ? 'block' : 'none';
      });
    });
  });
}

// =============================================================================
// 6. MODALS, FAQ, WINGET
// =============================================================================
function setupModals() {
  const openTosLinks = document.querySelectorAll('.open-tos-link');
  const closeTosBtn = document.getElementById('closeTosBtn');
  const tosModal = document.getElementById('tosModal');

  const openPrivacyLinks = document.querySelectorAll('.open-privacy-link');
  const closePrivacyBtn = document.getElementById('closePrivacyBtn');
  const privacyModal = document.getElementById('privacyModal');

  openTosLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      if (tosModal) tosModal.classList.add('open');
    });
  });

  if (closeTosBtn && tosModal) {
    closeTosBtn.addEventListener('click', () => tosModal.classList.remove('open'));
    tosModal.addEventListener('click', (e) => {
      if (e.target === tosModal) tosModal.classList.remove('open');
    });
  }

  openPrivacyLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      if (privacyModal) privacyModal.classList.add('open');
    });
  });

  if (closePrivacyBtn && privacyModal) {
    closePrivacyBtn.addEventListener('click', () => privacyModal.classList.remove('open'));
    privacyModal.addEventListener('click', (e) => {
      if (e.target === privacyModal) privacyModal.classList.remove('open');
    });
  }
}

function setupFaq() {
  const faqQuestions = document.querySelectorAll('.faq-question');
  faqQuestions.forEach((q) => {
    q.addEventListener('click', () => {
      const item = q.closest('.faq-item');
      if (item) item.classList.toggle('open');
    });
  });
}

function setupWingetCopy() {
  const wingetCopyBtn = document.getElementById('wingetCopyBtn');
  if (wingetCopyBtn) {
    wingetCopyBtn.addEventListener('click', () => {
      navigator.clipboard.writeText('winget install bloxstrap').then(() => {
        wingetCopyBtn.textContent = 'Copied!';
        setTimeout(() => { wingetCopyBtn.textContent = 'Copy'; }, 1500);
      });
    });
  }
}

// Global exposure for onclick handlers in HTML
window.openCheckout = openCheckout;
window.closeCheckout = closeCheckout;
