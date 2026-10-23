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
    badge: 'Standard Edition',
    icon: '🪙',
    desc: 'Entry-level dual-instance bootstrapper with basic FPS uncapping and gold styling.',
    instanceLimit: 2,
    features: [
      'Up to 2 simultaneous Roblox client instances',
      '240 FPS target framerate cap',
      'Basic FastFlag presets (FPS & DPI scaling)',
      'Standard Roblox client crash handling',
      'Bronze Gold Discord Rich Presence badge',
      'Email support (replies in 3 to 5 business days if we feel like it)'
    ]
  },
  2: {
    id: 2,
    name: 'Gold Plus',
    badge: 'Plus Edition',
    icon: '👑',
    desc: 'Expanded 5-instance capacity, monitor-refresh framerates, and live telemetry.',
    instanceLimit: 5,
    featured: true,
    ribbon: 'Most Popular',
    features: [
      'Up to 5 simultaneous Roblox client instances',
      'Framerate uncapped to monitor refresh rate (144Hz / 240Hz)',
      '18k Polished Gold Discord Rich Presence badge',
      'Automated background instance memory cleanup',
      'Live server location and ping display (ipinfo.io)',
      'Priority ticket queue (strictly behind all Ultra members)'
    ]
  },
  3: {
    id: 3,
    name: 'Gold Deluxe',
    badge: 'Deluxe Edition',
    icon: '💎',
    desc: 'Unlimited instances, fully uncapped framerates, and raw FastFlag memory access.',
    instanceLimit: 999,
    ribbon: 'Ultimate',
    features: [
      'Unlimited simultaneous Roblox client instances',
      'Fully uncapped framerate (up to 9999 FPS target)',
      '24k Solid Gold Discord Rich Presence badge',
      'Full FastFlag JSON editor with custom flag injection',
      'Automatic token restore on disconnect (Error 273)',
      'Dedicated priority email support queue'
    ]
  },
  4: {
    id: 4,
    name: 'Gold ULTRA',
    badge: 'Ultra Edition',
    icon: '🌌',
    desc: 'The $200/mo apex tier. Infinite instance scaling, real-time CPU thread priority, instant reconnection, and VIP respect.',
    instanceLimit: 9999,
    ribbon: '$200/mo Apex',
    ultra: true,
    features: [
      'Infinite simultaneous instances with dedicated CPU core pinning',
      'Instant auto-reconnect on client disconnects & Error 273',
      'Fully uncapped 9999 FPS with zero-latency frame pacing',
      'Classic 2006 "OOF" death sound with studio audio EQ',
      'Obsidian & Liquid Gold animated Discord Rich Presence badge',
      'Real-time process priority scheduling (REALTIME_PRIORITY_CLASS)',
      'Instant place joining with matchmaking queue bypass',
      'Pre-configured God Vault FastFlags (Max Performance & Visuals)',
      'Background instance watchdog & automated freeze recovery',
      'Zero-cooldown server hopper with automated ping sorting',
      'Direct low-latency route selection for game servers',
      '4-minute direct line + VIP respect'
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
      1: { price: 7.99, monthlyEquiv: 31.96, savings: 'Billed weekly • Cancel anytime' },
      2: { price: 17.99, monthlyEquiv: 71.96, savings: 'Billed weekly • Cancel anytime' },
      3: { price: 34.99, monthlyEquiv: 139.96, savings: 'Billed weekly • Cancel anytime' },
      4: { price: 59.99, monthlyEquiv: 239.96, savings: 'Billed weekly • Maximum flexibility' }
    }
  },
  monthly: {
    cycleId: 'monthly',
    label: 'Monthly',
    periodText: '/ month',
    tiers: {
      1: { price: 24.99, monthlyEquiv: 24.99, savings: 'Standard monthly rate' },
      2: { price: 54.99, monthlyEquiv: 54.99, savings: 'Save 24% vs weekly' },
      3: { price: 109.99, monthlyEquiv: 109.99, savings: 'Save 21% vs weekly' },
      4: { price: 199.99, monthlyEquiv: 199.99, savings: 'The $200/mo apex standard' }
    }
  },
  quarterly: {
    cycleId: 'quarterly',
    label: 'Quarterly',
    periodText: '/ quarter',
    tiers: {
      1: { price: 59.99, monthlyEquiv: 19.99, savings: 'Save 20% (~$19.99/mo)' },
      2: { price: 139.99, monthlyEquiv: 46.66, savings: 'Save 15% (~$46.66/mo)' },
      3: { price: 279.99, monthlyEquiv: 93.33, savings: 'Save 15% (~$93.33/mo)' },
      4: { price: 499.99, monthlyEquiv: 166.66, savings: 'Save 17% (~$166.66/mo)' }
    }
  },
  yearly: {
    cycleId: 'yearly',
    label: 'Yearly',
    periodText: '/ year',
    tiers: {
      1: { price: 199.99, monthlyEquiv: 16.66, savings: 'Save 33% (~$16.66/mo)' },
      2: { price: 449.99, monthlyEquiv: 37.49, savings: 'Save 32% (~$37.49/mo)' },
      3: { price: 899.99, monthlyEquiv: 74.99, savings: 'Save 32% (~$74.99/mo)' },
      4: { price: 1599.99, monthlyEquiv: 133.33, savings: 'Save 33% (~$133.33/mo)' }
    }
  },
  lifetime: {
    cycleId: 'lifetime',
    label: 'Lifetime',
    periodText: 'one-time',
    tiers: {
      1: { price: 499.99, monthlyEquiv: null, savings: 'Pay once, permanent access' },
      2: { price: 1199.99, monthlyEquiv: null, savings: 'Pay once, permanent access' },
      3: { price: 2499.99, monthlyEquiv: null, savings: 'Pay once, permanent access' },
      4: { price: 4799.99, monthlyEquiv: null, savings: '3-year equivalent permanent sovereign license' }
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

// =============================================================================
// INITIALIZATION
// =============================================================================
document.addEventListener('DOMContentLoaded', () => {
  setupHeroParticles();
  setupHeroTelemetryTicker();
  setupRenewalPills();
  setupCurrencyAndTax();
  setupFastFlagsVault();
  setupPayingWindow();
  setupAppThemePreview();
  setupModals();
  setupFaq();
  setupWingetCopy();

  // Initial render of the tier cards side-by-side
  renderTierCards();
});

// =============================================================================
// HERO INTRO: PARTICLES, COCKPIT DECK & LIVE TELEMETRY
// =============================================================================
function setupHeroParticles() {
  const canvas = document.getElementById('heroParticlesCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  if (!ctx) return;

  let width = (canvas.width = window.innerWidth);
  let height = (canvas.height = window.innerHeight);

  window.addEventListener('resize', () => {
    width = canvas.width = window.innerWidth;
    height = canvas.height = window.innerHeight;
  });

  const particles = [];
  const colors = ['rgba(226, 192, 118, ', 'rgba(245, 215, 150, ', 'rgba(255, 240, 211, '];

  for (let i = 0; i < 48; i++) {
    particles.push({
      x: Math.random() * width,
      y: Math.random() * height,
      size: Math.random() * 2.2 + 0.8,
      speedY: Math.random() * 0.45 + 0.15,
      speedX: (Math.random() - 0.5) * 0.25,
      opacity: Math.random() * 0.65 + 0.2,
      baseColor: colors[Math.floor(Math.random() * colors.length)],
      pulse: Math.random() * Math.PI * 2,
      pulseSpeed: Math.random() * 0.03 + 0.01
    });
  }

  function render() {
    ctx.clearRect(0, 0, width, height);

    for (let i = 0; i < particles.length; i++) {
      const p = particles[i];
      p.y -= p.speedY;
      p.x += p.speedX;
      p.pulse += p.pulseSpeed;

      const currentOpacity = Math.max(0.08, p.opacity + Math.sin(p.pulse) * 0.18);

      if (p.y < -10) {
        p.y = height + 10;
        p.x = Math.random() * width;
      }
      if (p.x < -10) p.x = width + 10;
      if (p.x > width + 10) p.x = -10;

      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fillStyle = `${p.baseColor}${currentOpacity})`;
      ctx.shadowBlur = p.size * 4;
      ctx.shadowColor = 'rgba(226, 192, 118, 0.4)';
      ctx.fill();
    }

    requestAnimationFrame(render);
  }

  requestAnimationFrame(render);
}


function setupHeroTelemetryTicker() {
  const statEl = document.getElementById('heroStatInstances');
  if (!statEl) return;

  setInterval(() => {
    let current = parseInt(statEl.textContent.replace(/,/g, ''), 10) || 3420891;
    current += Math.floor(Math.random() * 3) + 1;
    statEl.textContent = current.toLocaleString();
  }, 4500);
}

// =============================================================================
// 1. RENEWAL PILL CYCLING & 4-CARD SIDE-BY-SIDE RENDERING
// =============================================================================
function updatePillGlider(activeBtn) {
  const track = document.getElementById('pillSliderTrack');
  const container = document.getElementById('renewalSegmentedPill') || (activeBtn ? activeBtn.parentElement : null);
  if (!track || !activeBtn || !container) return;

  const width = activeBtn.offsetWidth;
  const left = activeBtn.offsetLeft;

  if (width > 0) {
    track.style.width = `${width}px`;
    track.style.transform = `translateX(${left}px)`;
    track.style.opacity = '1';
    container.classList.add('glider-ready');
  }
}

function setupRenewalPills() {
  const pillBtns = document.querySelectorAll('.renewal-pill-btn');
  if (!pillBtns || pillBtns.length === 0) return;

  const initialActive = document.querySelector('.renewal-pill-btn.active');
  if (initialActive) {
    updatePillGlider(initialActive);
    requestAnimationFrame(() => updatePillGlider(initialActive));
    setTimeout(() => updatePillGlider(initialActive), 60);
    setTimeout(() => updatePillGlider(initialActive), 300);
  }

  pillBtns.forEach((btn) => {
    btn.addEventListener('click', () => {
      const targetCycle = btn.dataset.cycle;
      if (!targetCycle || !PRICING_MATRIX[targetCycle]) return;

      // Update active state on buttons
      pillBtns.forEach((b) => b.classList.remove('active'));
      btn.classList.add('active');
      updatePillGlider(btn);

      currentCycle = targetCycle;
      renderTierCards();
    });
  });

  window.addEventListener('resize', () => {
    const currentActive = document.querySelector('.renewal-pill-btn.active');
    if (currentActive) updatePillGlider(currentActive);
  });

  window.addEventListener('load', () => {
    const currentActive = document.querySelector('.renewal-pill-btn.active');
    if (currentActive) updatePillGlider(currentActive);
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
    card.className = `pricing-card price-anim ${meta.featured ? 'featured' : ''} ${meta.ultra ? 'ultra' : ''}`;

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
  const scannerBar = document.getElementById('payScannerBar');

  // Input syncing with 3D flippable virtual gold card
  const cardNameInput = document.getElementById('cardName');
  const cardNumberInput = document.getElementById('cardNumber');
  const cardExpInput = document.getElementById('cardExp');
  const cardCvcInput = document.getElementById('cardCvc');
  const virtualGoldCard = document.getElementById('virtualGoldCard');
  const virtualCardWrapper = document.getElementById('virtualCardWrapper');
  const cardGlare = document.getElementById('cardGlare');

  // 3D Card Mouse Tilt & Holographic Glare Tracking
  if (virtualCardWrapper && virtualGoldCard) {
    virtualCardWrapper.addEventListener('mousemove', (e) => {
      if (virtualGoldCard.classList.contains('flipped')) return;
      const rect = virtualCardWrapper.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      const centerX = rect.width / 2;
      const centerY = rect.height / 2;
      const rotateX = ((y - centerY) / centerY) * -12;
      const rotateY = ((x - centerX) / centerX) * 14;
      virtualGoldCard.style.transform = `rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;

      if (cardGlare) {
        const glareX = (x / rect.width) * 100;
        const glareY = (y / rect.height) * 100;
        cardGlare.style.background = `radial-gradient(circle at ${glareX}% ${glareY}%, rgba(255, 255, 255, 0.45) 0%, transparent 60%)`;
      }
    });

    virtualCardWrapper.addEventListener('mouseleave', () => {
      if (!virtualGoldCard.classList.contains('flipped')) {
        virtualGoldCard.style.transform = 'rotateX(0deg) rotateY(0deg)';
      }
    });
  }

  // CVC Flip Card to Back Face
  if (cardCvcInput && virtualGoldCard) {
    cardCvcInput.addEventListener('focus', () => {
      virtualGoldCard.classList.add('flipped');
      virtualGoldCard.style.transform = '';
    });
    cardCvcInput.addEventListener('blur', () => {
      virtualGoldCard.classList.remove('flipped');
      virtualGoldCard.style.transform = '';
    });
    cardCvcInput.addEventListener('input', (e) => {
      let val = e.target.value.replace(/\D/g, '').substring(0, 4);
      e.target.value = val;
      const vcCvcDisplay = document.getElementById('vcCvcDisplay');
      if (vcCvcDisplay) vcCvcDisplay.textContent = val ? val : '•••';
    });
  }

  // Cardholder Name live sync
  if (cardNameInput) {
    cardNameInput.addEventListener('input', (e) => {
      const val = e.target.value.trim();
      const vcName = document.getElementById('vcName');
      if (vcName) vcName.textContent = val ? val.toUpperCase() : 'YOUR NAME';
    });
  }

  // Card Number live formatting & Brand Detection
  if (cardNumberInput) {
    cardNumberInput.addEventListener('input', (e) => {
      let val = e.target.value.replace(/\D/g, '').substring(0, 16);
      let formatted = val.match(/.{1,4}/g)?.join(' ') || val;
      e.target.value = formatted;
      const vcNum = document.getElementById('vcNumber');
      if (vcNum) vcNum.textContent = formatted || '•••• •••• •••• ••••';

      const brandPill = document.getElementById('cardBrandPill');
      const networkBadge = document.getElementById('vcNetworkBadge');
      const brandLabel = document.getElementById('vcBrandLabel');

      if (val.startsWith('4')) {
        if (brandPill) brandPill.textContent = 'VISA';
        if (networkBadge) networkBadge.innerHTML = '<span class="badge-gold-foil">VISA</span>';
        if (brandLabel) brandLabel.textContent = 'BLOXSTRAP VISA';
      } else if (val.startsWith('5')) {
        if (brandPill) brandPill.textContent = 'MC';
        if (networkBadge) networkBadge.innerHTML = '<span class="badge-gold-foil">MC</span>';
        if (brandLabel) brandLabel.textContent = 'BLOXSTRAP MC';
      } else if (val.startsWith('3')) {
        if (brandPill) brandPill.textContent = 'AMEX';
        if (networkBadge) networkBadge.innerHTML = '<span class="badge-gold-foil">AMEX</span>';
        if (brandLabel) brandLabel.textContent = 'BLOXSTRAP AMEX';
      } else {
        if (brandPill) brandPill.textContent = 'VISA / MC';
        if (networkBadge) networkBadge.innerHTML = '<span class="badge-gold-foil">GOLD</span>';
        if (brandLabel) brandLabel.textContent = 'BLOXSTRAP GOLD';
      }
    });
  }

  // Card Expiration live formatting
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

  // Unified Payment Processing Simulation (Card, Apple Pay, Google Pay)
  window.triggerPaymentSimulation = function(gatewayName = 'Clearinghouse') {
    if (!buyPayBtn || buyPayBtn.classList.contains('processing')) return;

    const originalText = buyPayBtn.innerHTML;
    buyPayBtn.classList.add('processing');
    buyPayBtn.style.pointerEvents = 'none';

    if (scannerBar) scannerBar.classList.add('active');
    const errorBanner = document.getElementById('checkoutErrorBanner');
    if (errorBanner) errorBanner.classList.remove('show');

    // Stage 1: Network Contact
    buyPayBtn.innerHTML = `<span class="btn-spinner"></span> Contacting ${gatewayName}...`;

    // Stage 2: Issuer Authorization
    setTimeout(() => {
      buyPayBtn.innerHTML = '<span class="btn-spinner"></span> Authorizing with card issuer...';
    }, 900);

    // Stage 3: 3D Secure / Verification
    setTimeout(() => {
      buyPayBtn.innerHTML = '<span class="btn-spinner"></span> Finalizing 3D Secure protocol...';
    }, 1800);

    // Stage 4: Gate resolution (~35% chance card "goes through", 65% declines)
    setTimeout(() => {
      if (scannerBar) scannerBar.classList.remove('active');
      const isApproved = Math.random() < 0.35;

      if (isApproved) {
        buyPayBtn.innerHTML = '✓ Payment Approved!';
        buyPayBtn.style.background = 'linear-gradient(135deg, #10b981 0%, #059669 100%)';
        buyPayBtn.style.borderColor = '#10b981';
        buyPayBtn.style.color = '#ffffff';

        // Fire celebratory golden confetti!
        launchConfetti();

        setTimeout(() => {
          buyPayBtn.classList.remove('processing');
          buyPayBtn.innerHTML = originalText;
          buyPayBtn.style.background = '';
          buyPayBtn.style.borderColor = '';
          buyPayBtn.style.color = '';
          buyPayBtn.style.pointerEvents = 'auto';
          startFreeTrial(true);
        }, 750);
      } else {
        buyPayBtn.classList.remove('processing');
        buyPayBtn.innerHTML = originalText;
        buyPayBtn.style.pointerEvents = 'auto';

        // Shake the virtual card
        if (virtualGoldCard) {
          virtualGoldCard.animate([
            { transform: 'translateX(0)' },
            { transform: 'translateX(-9px)' },
            { transform: 'translateX(9px)' },
            { transform: 'translateX(-5px)' },
            { transform: 'translateX(0)' }
          ], { duration: 380, easing: 'ease-in-out' });
        }

        if (errorBanner) {
          errorBanner.classList.add('show');
          errorBanner.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
      }
    }, 2600);
  };

  if (buyPayBtn) {
    buyPayBtn.addEventListener('click', (e) => {
      e.preventDefault();
      window.triggerPaymentSimulation('Payment Network');
    });
  }

  // Express Checkout Buttons
  const applePayBtn = document.getElementById('expressApplePayBtn');
  const googlePayBtn = document.getElementById('expressGooglePayBtn');
  const gold1ClickBtn = document.getElementById('expressGoldPayBtn');

  if (applePayBtn) {
    applePayBtn.addEventListener('click', () => {
      window.triggerPaymentSimulation('Apple Pay Enclave');
    });
  }

  if (googlePayBtn) {
    googlePayBtn.addEventListener('click', () => {
      window.triggerPaymentSimulation('Google Pay Gateway');
    });
  }

  if (gold1ClickBtn) {
    gold1ClickBtn.addEventListener('click', () => {
      startFreeTrial(false);
    });
  }

  // STATIONARY "PAY LATER" BUTTON:
  // Directly beneath the pay button. Never moves. Triggers the 7-day free trial.
  if (payLaterBtn) {
    payLaterBtn.addEventListener('click', () => {
      startFreeTrial(false);
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
      const generatedKey = document.getElementById('generatedLicenseKey')?.textContent || 'GOLD-7DAY-ULTRA-XKW6-5TKI-WBFN';
      unlockVaultWithKey(generatedKey);
      closeCheckout();
      const vaultSec = document.getElementById('fastflags');
      if (vaultSec) vaultSec.scrollIntoView({ behavior: 'smooth' });
    });
  }
}

// Confetti Particle System
function launchConfetti() {
  const canvas = document.getElementById('confettiCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  const particles = [];
  const colors = ['#ffd700', '#f5d796', '#e2c076', '#10b981', '#ffffff', '#caa452'];

  for (let i = 0; i < 65; i++) {
    particles.push({
      x: canvas.width / 2 + (Math.random() - 0.5) * 220,
      y: canvas.height / 2 + (Math.random() - 0.5) * 80,
      vx: (Math.random() - 0.5) * 14,
      vy: Math.random() * -12 - 4,
      size: Math.random() * 8 + 4,
      color: colors[Math.floor(Math.random() * colors.length)],
      rotation: Math.random() * 360,
      rotSpeed: (Math.random() - 0.5) * 10,
      life: 1.0,
      decay: Math.random() * 0.015 + 0.009
    });
  }

  function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    let active = false;

    particles.forEach((p) => {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.35;
      p.rotation += p.rotSpeed;
      p.life -= p.decay;

      if (p.life > 0 && p.y < canvas.height) {
        active = true;
        ctx.save();
        ctx.translate(p.x, p.y);
        ctx.rotate((p.rotation * Math.PI) / 180);
        ctx.fillStyle = p.color;
        ctx.globalAlpha = Math.max(0, p.life);
        ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size * 0.65);
        ctx.restore();
      }
    });

    if (active) {
      requestAnimationFrame(render);
    } else {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
    }
  }

  render();
}

function openCheckout(tierId = 2, cycle = 'yearly') {
  selectedCheckoutTier = tierId;
  selectedCheckoutCycle = cycle;

  const modal = document.getElementById('checkoutModal');
  const formView = document.getElementById('checkoutFormView');
  const successView = document.getElementById('checkoutSuccessView');
  const errorBanner = document.getElementById('checkoutErrorBanner');
  const buyPayBtn = document.getElementById('buyPayBtn');
  const virtualGoldCard = document.getElementById('virtualGoldCard');
  const scannerBar = document.getElementById('payScannerBar');

  if (!modal) return;

  // Reset views
  if (formView) formView.style.display = '';
  if (successView) successView.classList.remove('show');
  if (errorBanner) errorBanner.classList.remove('show');
  if (scannerBar) scannerBar.classList.remove('active');
  if (virtualGoldCard) {
    virtualGoldCard.classList.remove('flipped');
    virtualGoldCard.style.transform = '';
  }
  if (buyPayBtn) {
    buyPayBtn.classList.remove('processing');
    buyPayBtn.style.pointerEvents = 'auto';
    buyPayBtn.style.background = '';
    buyPayBtn.style.borderColor = '';
    buyPayBtn.style.color = '';
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
  const receiptLimitEl = document.getElementById('receiptInstanceLimit');

  if (summaryTier) summaryTier.textContent = `${meta.name} (${meta.badge})`;
  if (summaryCycle) summaryCycle.textContent = `${cycleData.label} Plan (${cycleData.periodText})`;
  if (basePriceEl) basePriceEl.textContent = `${curr.symbol}${basePrice.toFixed(2)}`;

  if (receiptLimitEl) {
    receiptLimitEl.textContent = meta.instanceLimit >= 9999 ? 'Infinite Alts' : (meta.instanceLimit >= 999 ? 'Unlimited' : `Up to ${meta.instanceLimit} clients`);
  }

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
  if (buyPayBtn) {
    buyPayBtn.innerHTML = `
      <span class="btn-pay-text" id="btnPayText">Pay ${curr.symbol}${totalPrice.toFixed(2)}</span>
      <span class="btn-pay-glow"></span>
    `;
  }

  modal.classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeCheckout() {
  const modal = document.getElementById('checkoutModal');
  if (modal) modal.classList.remove('open');
  document.body.style.overflow = '';
}

function generateEnterpriseKey(tierId = selectedCheckoutTier) {
  const tierTags = {
    1: 'BASIC',
    2: 'PLUS',
    3: 'DELUXE',
    4: 'ULTRA'
  };
  const tag = tierTags[tierId] || 'PLUS';
  const seg = () => Math.random().toString(36).substring(2, 6).toUpperCase();
  return `GOLD-7DAY-${tag}-${seg()}-${seg()}-${seg()}`;
}

function startFreeTrial(isApproved = false) {
  const formView = document.getElementById('checkoutFormView');
  const successView = document.getElementById('checkoutSuccessView');
  const licenseKeyEl = document.getElementById('generatedLicenseKey');
  const deepLinkActivateBtn = document.getElementById('deepLinkActivateBtn');
  const titleEl = document.getElementById('checkoutSuccessTitle');
  const subtitleEl = document.getElementById('checkoutSuccessSubtitle');

  const meta = TIERS_META[selectedCheckoutTier] || TIERS_META[2];

  // Generate tier-tagged multi-segment enterprise key
  const generatedKey = generateEnterpriseKey(selectedCheckoutTier);

  if (titleEl) {
    titleEl.textContent = isApproved ? 'Payment Approved!' : 'Your 7-day free trial has started.';
  }

  if (subtitleEl) {
    subtitleEl.textContent = isApproved
      ? `Transaction authorized at $0.00. Your Bloxstrap Gold ${meta.name} license is provisioned below:`
      : 'Download Bloxstrap Gold below and enjoy built-in multi-instance support and the gold theme.';
  }

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
