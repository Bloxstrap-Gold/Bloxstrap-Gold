import AppKit
import AVFoundation
@preconcurrency import WebKit

class FlippedContainerView: NSView {
    override var isFlipped: Bool { return true }
}

public class MainWindowController: NSWindowController, WKNavigationDelegate {
    // Top Gold VIP Banner & Evasive Runway
    private var trialBannerView: NSView!
    private var bannerTitleLabel: NSTextField!
    private var bannerStatusLabel: NSTextField!
    private var bannerBadgeLabel: NSTextField!
    private var bannerDismissBtn: NSButton!
    private var runawayCanvas: RunawayCanvasView!
    
    // Breadcrumb navigation bar (exact Bloxstrap style)
    private var breadcrumbView: NSView!
    private var breadcrumbLabel: NSTextField!
    
    // Sidebar & Navigation (exact Bloxstrap NavigationFluent)
    private var sidebarView: NSView!
    private var sidebarButtons: [NSButton] = []
    private var contentContainerView: NSView!
    private var currentTabIndex: Int = 0
    private var tabViews: [NSView] = []
    
    // Bottom Status Bar (exact Bloxstrap RootStatusBar)
    private var statusBarView: NSView!
    private var statusToastLabel: NSTextField!
    private var robloxStatusDot: NSTextField!
    private var robloxStatusLabel: NSTextField!
    
    // Store Web Preview controls
    private var storeWebView: WKWebView?
    
    // Multi-Instance controls
    private var instanceCountBadge: NSTextField!
    private var instanceRamBadge: NSTextField!
    private var instancesStackView: NSStackView!
    private var instanceTimer: Timer?
    
    // FastFlags controls
    private var keyLockContainer: NSView!
    private var keyInputField: NSTextField!
    private var fastFlagsUnlockedContainer: NSView!
    private var fpsPopup: NSPopUpButton!
    private var backendPopup: NSPopUpButton!
    private var unlockedBadgeLabel: NSTextField!
    
    // General Tab Controls
    private var tierPopup: NSPopUpButton!
    private var tierBadgeLabel: NSTextField!
    
    private let pageTitles: [String] = [
        "Bloxstrap Gold",
        "Store / Buy",
        "Integrations",
        "Mods",
        "FastFlags",
        "Appearance",
        "About"
    ]
    
    public init() {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 80, width: 1000, height: 640),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Bloxstrap Menu 👑"
        window.backgroundColor = NSColor(calibratedRed: 0.035, green: 0.039, blue: 0.051, alpha: 1.0)
        window.minSize = NSSize(width: 920, height: 580)
        
        super.init(window: window)
        setupUI()
        
        // Initial first-run greeting
        if !AppState.shared.data.hasSeenGoldGreeting {
            AppState.shared.data.hasSeenGoldGreeting = true
            AppState.shared.save()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                let alert = self.createGoldAlert(
                    title: "👑 Welcome to Bloxstrap Gold",
                    message: "You have 7 days of \"free trial\" access.\n\nMulti-instance Roblox, FastFlags, uncapped FPS, and the classic oof sound are unlocked and ready to use.\n\nVisit bloxstrapgold.github.io to explore tiers or test the checkout bit.",
                    style: .informational
                )
                alert.addButton(withTitle: "Start 7-Day Free Trial")
                alert.runModal()
            }
        }
        
        // Polling timer for active Roblox processes
        instanceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateInstanceList()
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        instanceTimer?.invalidate()
    }
    
    private func createGoldAlert(title: String, message: String, style: NSAlert.Style = .informational) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        if let icon = NSApp.applicationIconImage {
            alert.icon = icon
        } else if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
                  let icon = NSImage(contentsOf: iconURL) {
            alert.icon = icon
        }
        return alert
    }
    
    private func setupUI() {
        guard let contentView = window?.contentView else { return }
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor(calibratedRed: 0.035, green: 0.039, blue: 0.051, alpha: 1.0).cgColor
        
        let bounds = contentView.bounds
        
        // ==========================================
        // 1. TOP GOLD BANNER (EXACT BLOXSTRAP STYLE)
        // ==========================================
        trialBannerView = NSView(frame: NSRect(x: 14, y: bounds.height - 68, width: bounds.width - 28, height: 54))
        trialBannerView.wantsLayer = true
        trialBannerView.layer?.cornerRadius = 6
        trialBannerView.autoresizingMask = [.width, .minYMargin]
        contentView.addSubview(trialBannerView)
        
        let crownIcon = NSTextField(labelWithString: "👑")
        crownIcon.font = .systemFont(ofSize: 20)
        crownIcon.frame = NSRect(x: 12, y: 15, width: 26, height: 24)
        trialBannerView.addSubview(crownIcon)
        
        bannerTitleLabel = NSTextField(labelWithString: "BLOXSTRAP GOLD EDITION")
        bannerTitleLabel.font = .boldSystemFont(ofSize: 12.5)
        bannerTitleLabel.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        bannerTitleLabel.frame = NSRect(x: 42, y: 28, width: 260, height: 18)
        trialBannerView.addSubview(bannerTitleLabel)
        
        bannerBadgeLabel = NSTextField(labelWithString: "VIP TRIAL")
        bannerBadgeLabel.font = .boldSystemFont(ofSize: 9)
        bannerBadgeLabel.alignment = .center
        bannerBadgeLabel.frame = NSRect(x: 308, y: 28, width: 75, height: 16)
        bannerBadgeLabel.wantsLayer = true
        bannerBadgeLabel.layer?.cornerRadius = 3
        trialBannerView.addSubview(bannerBadgeLabel)
        
        bannerStatusLabel = NSTextField(labelWithString: "")
        bannerStatusLabel.font = .systemFont(ofSize: 10.5)
        bannerStatusLabel.textColor = NSColor(calibratedRed: 0.80, green: 0.84, blue: 0.90, alpha: 1.0)
        bannerStatusLabel.frame = NSRect(x: 42, y: 9, width: 380, height: 16)
        trialBannerView.addSubview(bannerStatusLabel)
        
        // Action: Buy Gold on Website (bloxstrapgold.github.io)
        let buyGoldBannerBtn = createSmallButton(title: "🛒 Buy Gold", frame: NSRect(x: trialBannerView.bounds.width - 370, y: 13, width: 95, height: 28))
        buyGoldBannerBtn.autoresizingMask = [.minXMargin]
        buyGoldBannerBtn.target = self
        buyGoldBannerBtn.action = #selector(onOpenStore)
        trialBannerView.addSubview(buyGoldBannerBtn)
        
        // Action: Ignore Payment
        let ignoreBtn = createSmallButton(title: "Ignore Payment", frame: NSRect(x: trialBannerView.bounds.width - 268, y: 13, width: 110, height: 28))
        ignoreBtn.autoresizingMask = [.minXMargin]
        ignoreBtn.target = self
        ignoreBtn.action = #selector(onIgnorePaymentClicked)
        trialBannerView.addSubview(ignoreBtn)
        
        // Action: Fast-Forward (Bloxstrap style)
        let simulateExpireBtn = createSmallButton(title: "⚡ Expire (7d)", frame: NSRect(x: trialBannerView.bounds.width - 150, y: 13, width: 102, height: 28))
        simulateExpireBtn.autoresizingMask = [.minXMargin]
        simulateExpireBtn.target = self
        simulateExpireBtn.action = #selector(onSimulateExpiry)
        trialBannerView.addSubview(simulateExpireBtn)
        
        bannerDismissBtn = NSButton(frame: NSRect(x: trialBannerView.bounds.width - 28, y: 30, width: 18, height: 18))
        bannerDismissBtn.title = "✕"
        bannerDismissBtn.bezelStyle = .inline
        bannerDismissBtn.font = .systemFont(ofSize: 10, weight: .bold)
        bannerDismissBtn.toolTip = "Hide this banner"
        bannerDismissBtn.autoresizingMask = [.minXMargin]
        bannerDismissBtn.target = self
        bannerDismissBtn.action = #selector(onDismissBanner)
        trialBannerView.addSubview(bannerDismissBtn)
        
        // ==========================================
        // 2. RUNAWAY EVASIVE BUTTON CANVAS
        // ==========================================
        runawayCanvas = RunawayCanvasView(frame: NSRect(x: 14, y: bounds.height - 134, width: bounds.width - 28, height: 58))
        runawayCanvas.autoresizingMask = [.width, .minYMargin]
        
        runawayCanvas.onPaymentFailed = { [weak self] in
            guard let self = self else { return }
            let failAlert = self.createGoldAlert(
                title: "Error, purchase failed, please pay later.",
                message: "Transaction declined by card issuer. Code: ERR-BIT-402.",
                style: .critical
            )
            failAlert.addButton(withTitle: "OK, Pay Later")
            failAlert.runModal()
            self.showConfirmIgnoreDialog()
        }
        
        runawayCanvas.onPayLaterClick = { [weak self] in
            self?.showConfirmIgnoreDialog()
        }
        
        contentView.addSubview(runawayCanvas)
        
        // ==========================================
        // 3. BOTTOM STATUS BAR (BLOXSTRAP ROOTSTATUSBAR)
        // ==========================================
        statusBarView = NSView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: 44))
        statusBarView.wantsLayer = true
        statusBarView.layer?.backgroundColor = NSColor(calibratedRed: 0.050, green: 0.055, blue: 0.068, alpha: 0.98).cgColor
        statusBarView.layer?.borderColor = NSColor(white: 1.0, alpha: 0.08).cgColor
        statusBarView.layer?.borderWidth = 1.0
        statusBarView.autoresizingMask = [.width, .maxYMargin]
        contentView.addSubview(statusBarView)
        
        let isInstalled = MultiInstanceManager.shared.isRobloxInstalled
        robloxStatusDot = NSTextField(labelWithString: isInstalled ? "🟢" : "🟡")
        robloxStatusDot.font = .systemFont(ofSize: 10)
        robloxStatusDot.frame = NSRect(x: 16, y: 14, width: 16, height: 16)
        statusBarView.addSubview(robloxStatusDot)
        
        robloxStatusLabel = NSTextField(labelWithString: isInstalled ? "Roblox.app Detected" : "Roblox Not Found")
        robloxStatusLabel.font = .systemFont(ofSize: 11, weight: .medium)
        robloxStatusLabel.textColor = isInstalled ? NSColor(calibratedRed: 0.063, green: 0.725, blue: 0.506, alpha: 1.0) : NSColor.systemYellow
        robloxStatusLabel.frame = NSRect(x: 36, y: 13, width: 170, height: 18)
        statusBarView.addSubview(robloxStatusLabel)
        
        // Green Toast Message for "Settings saved!"
        statusToastLabel = NSTextField(labelWithString: "")
        statusToastLabel.font = .boldSystemFont(ofSize: 11)
        statusToastLabel.textColor = NSColor(calibratedRed: 0.063, green: 0.725, blue: 0.506, alpha: 1.0)
        statusToastLabel.frame = NSRect(x: 230, y: 13, width: 280, height: 18)
        statusToastLabel.isHidden = true
        statusBarView.addSubview(statusToastLabel)
        
        // Save & Close buttons on right edge (exact Bloxstrap layout)
        let saveBtn = NSButton(frame: NSRect(x: statusBarView.bounds.width - 195, y: 7, width: 95, height: 30))
        saveBtn.title = "Save"
        saveBtn.bezelStyle = .rounded
        saveBtn.font = .boldSystemFont(ofSize: 12)
        saveBtn.wantsLayer = true
        saveBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 1.0).cgColor
        saveBtn.contentTintColor = .black
        saveBtn.target = self
        saveBtn.action = #selector(onSaveSettings)
        saveBtn.autoresizingMask = [.minXMargin]
        statusBarView.addSubview(saveBtn)
        
        let closeBtn = NSButton(frame: NSRect(x: statusBarView.bounds.width - 92, y: 7, width: 80, height: 30))
        closeBtn.title = "Close"
        closeBtn.bezelStyle = .rounded
        closeBtn.font = .systemFont(ofSize: 12)
        closeBtn.target = self
        closeBtn.action = #selector(onCloseWindow)
        closeBtn.autoresizingMask = [.minXMargin]
        statusBarView.addSubview(closeBtn)
        
        // ==========================================
        // 4. MAIN BODY: SIDEBAR + BREADCRUMB + CONTENT AREA
        // ==========================================
        let mainBodyY: CGFloat = 52
        let mainBodyHeight = bounds.height - 126
        
        // Left Sidebar (NavigationFluent style)
        sidebarView = NSView(frame: NSRect(x: 14, y: mainBodyY, width: 200, height: mainBodyHeight))
        sidebarView.wantsLayer = true
        sidebarView.layer?.backgroundColor = NSColor(calibratedRed: 0.055, green: 0.062, blue: 0.078, alpha: 0.95).cgColor
        sidebarView.layer?.borderColor = NSColor(white: 1.0, alpha: 0.08).cgColor
        sidebarView.layer?.borderWidth = 1.0
        sidebarView.layer?.cornerRadius = 6
        sidebarView.autoresizingMask = [.height, .maxXMargin]
        contentView.addSubview(sidebarView)
        
        setupSidebar()
        
        // Breadcrumb Navigation Header (above content)
        breadcrumbView = NSView(frame: NSRect(x: 226, y: mainBodyY + mainBodyHeight - 24, width: bounds.width - 240, height: 22))
        breadcrumbView.autoresizingMask = [.width, .minYMargin]
        contentView.addSubview(breadcrumbView)
        
        breadcrumbLabel = NSTextField(labelWithString: "Bloxstrap Menu  ›  Bloxstrap Gold")
        breadcrumbLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        breadcrumbLabel.textColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 0.9)
        breadcrumbLabel.frame = NSRect(x: 4, y: 2, width: 450, height: 18)
        breadcrumbView.addSubview(breadcrumbLabel)
        
        // Right Content Container
        contentContainerView = NSView(frame: NSRect(x: 226, y: mainBodyY, width: bounds.width - 240, height: mainBodyHeight - 26))
        contentContainerView.wantsLayer = true
        contentContainerView.layer?.backgroundColor = NSColor(calibratedRed: 0.055, green: 0.062, blue: 0.078, alpha: 0.95).cgColor
        contentContainerView.layer?.borderColor = NSColor(white: 1.0, alpha: 0.08).cgColor
        contentContainerView.layer?.borderWidth = 1.0
        contentContainerView.layer?.cornerRadius = 6
        contentContainerView.autoresizingMask = [.width, .height]
        contentView.addSubview(contentContainerView)
        
        // Build all 7 content tab views
        tabViews = [
            buildGeneralTab(bounds: contentContainerView.bounds),
            buildStoreTab(bounds: contentContainerView.bounds),
            buildIntegrationsTab(bounds: contentContainerView.bounds),
            buildModsTab(bounds: contentContainerView.bounds),
            buildFastFlagsTab(bounds: contentContainerView.bounds),
            buildAppearanceTab(bounds: contentContainerView.bounds),
            buildAboutTab(bounds: contentContainerView.bounds)
        ]
        
        for tabView in tabViews {
            tabView.autoresizingMask = [.width, .height]
            tabView.isHidden = true
            contentContainerView.addSubview(tabView)
        }
        
        // Select initial tab
        selectTab(index: 0)
        
        // Refresh trial state & UI
        refreshTrialState()
    }
    
    // --- 1-CLICK DEEP LINK ACTIVATION (bloxstrap-gold://activate?key=...) ---
    public func handleDeepLinkActivation(key: String) {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard trimmedKey.hasPrefix("GOLD-") && trimmedKey.count >= 6 else { return }
        
        AppState.shared.setPaymentIgnored(true)
        _ = AppState.shared.verifyAndApplyKey(trimmedKey)
        
        refreshTrialState()
        updateFastFlagsVisibility()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        let alert = createGoldAlert(
            title: "👑 Activated via Bloxstrap Gold Protocol",
            message: "License Key: \(trimmedKey)\n\nBloxstrap Gold has been activated directly from bloxstrapgold.github.io. Free Forever mode is active.",
            style: .informational
        )
        alert.addButton(withTitle: "Launch Roblox")
        alert.addButton(withTitle: "Done")
        let res = alert.runModal()
        if res == .alertFirstButtonReturn {
            onLaunchRoblox()
        }
    }
    
    @objc private func onIgnorePaymentClicked() {
        showConfirmIgnoreDialog()
    }
    
    // --- CONFIRM IGNORE DIALOG (STOP PROMPTING TO PAY AT TOP) ---
    private func showConfirmIgnoreDialog() {
        let alert = createGoldAlert(
            title: "Confirm ignore?",
            message: "Would you like to ignore the payment and continue using Bloxstrap Gold for free?",
            style: .warning
        )
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        
        let res = alert.runModal()
        if res == .alertFirstButtonReturn {
            AppState.shared.setPaymentIgnored(true)
            refreshTrialState()
            
            let successAlert = createGoldAlert(
                title: "👑 Free Forever Mode Active",
                message: "Payment permanently ignored. You will never be asked to pay again.",
                style: .informational
            )
            successAlert.addButton(withTitle: "Nice")
            successAlert.runModal()
        } else {
            let stayAlert = createGoldAlert(
                title: "Nice try",
                message: "We appreciate your enthusiasm for paying $999.99/mo, but we still don't have a way to charge you. Enjoy the app for free.",
                style: .informational
            )
            stayAlert.addButton(withTitle: "OK")
            stayAlert.runModal()
        }
    }
    
    // --- SIDEBAR SETUP (BLOXSTRAP NAVIGATIONFLUENT) ---
    private func setupSidebar() {
        // Navigation Menu Items with authentic Bloxstrap icons
        let menuItems: [(icon: String, title: String)] = [
            ("🏆", "Bloxstrap Gold"),
            ("🛒", "Store / Buy"),
            ("➕", "Integrations"),
            ("🔧", "Mods"),
            ("🚩", "FastFlags"),
            ("🎨", "Appearance"),
            ("❓", "About")
        ]
        
        var yPos: CGFloat = sidebarView.bounds.height - 48
        for (i, item) in menuItems.enumerated() {
            let btn = NSButton(frame: NSRect(x: 6, y: yPos, width: 188, height: 36))
            btn.title = "  \(item.icon)  \(item.title)"
            btn.font = .systemFont(ofSize: 12, weight: .medium)
            btn.alignment = .left
            btn.isBordered = false
            btn.wantsLayer = true
            btn.layer?.cornerRadius = 5
            btn.tag = i
            btn.target = self
            btn.action = #selector(onSidebarButtonClicked(_:))
            btn.autoresizingMask = [.width, .minYMargin]
            
            sidebarView.addSubview(btn)
            sidebarButtons.append(btn)
            yPos -= 42
        }
    }
    
    @objc private func onSidebarButtonClicked(_ sender: NSButton) {
        selectTab(index: sender.tag)
    }
    
    @objc public func showAboutTab() {
        selectTab(index: 6)
    }
    
    @objc public func onOpenStore() {
        selectTab(index: 1)
    }
    
    @objc public func onOpenStoreInBrowser() {
        if let url = URL(string: "https://bloxstrapgold.github.io#pricing") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func selectTab(index: Int) {
        currentTabIndex = index
        breadcrumbLabel.stringValue = "Bloxstrap Menu  ›  \(pageTitles[index])"
        
        for (i, btn) in sidebarButtons.enumerated() {
            let isSelected = i == index
            btn.layer?.backgroundColor = isSelected ? NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 0.18).cgColor : NSColor.clear.cgColor
            btn.layer?.borderColor = isSelected ? NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 0.4).cgColor : NSColor.clear.cgColor
            btn.layer?.borderWidth = isSelected ? 1.0 : 0.0
            btn.contentTintColor = isSelected ? NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0) : NSColor(calibratedRed: 0.75, green: 0.78, blue: 0.85, alpha: 1.0)
            btn.font = .systemFont(ofSize: 12, weight: isSelected ? .bold : .medium)
        }
        
        for (i, v) in tabViews.enumerated() {
            v.isHidden = (i != index)
        }
        
        if index == 0 {
            updateInstanceList()
        }
    }
    
    // --- TRIAL STATUS ENGINE (STOPS PROMPTING WHEN PAYMENT IS IGNORED) ---
    public func refreshTrialState() {
        let isPaymentIgnored = AppState.shared.data.isPaymentIgnored
        let isBannerDismissed = AppState.shared.data.isBannerDismissed
        let isExpired = AppState.shared.isExpired
        let days = AppState.shared.daysRemaining
        
        // If user ignored payment OR dismissed banner: STOP PROMPTING COMPLETELY!
        if isPaymentIgnored || isBannerDismissed {
            trialBannerView.isHidden = true
            runawayCanvas.isHidden = true
            adjustBodyLayout(mode: .cleanFull)
            return
        }
        
        trialBannerView.isHidden = false
        
        if !isExpired {
            // Normal 7-day trial active
            trialBannerView.layer?.backgroundColor = NSColor(calibratedRed: 0.10, green: 0.09, blue: 0.05, alpha: 0.95).cgColor
            trialBannerView.layer?.borderColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 0.45).cgColor
            trialBannerView.layer?.borderWidth = 1.0
            
            bannerTitleLabel.stringValue = "BLOXSTRAP GOLD EDITION"
            bannerTitleLabel.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
            
            bannerStatusLabel.stringValue = "Your free trial runs out in \(days) day\(days == 1 ? "" : "s"). Visit bloxstrapgold.github.io to buy."
            bannerStatusLabel.textColor = NSColor(calibratedRed: 0.80, green: 0.84, blue: 0.90, alpha: 1.0)
            
            bannerBadgeLabel.stringValue = "VIP TRIAL"
            bannerBadgeLabel.textColor = .black
            bannerBadgeLabel.layer?.backgroundColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 0.9).cgColor
            
            runawayCanvas.isHidden = true
            adjustBodyLayout(mode: .bannerOnly)
            
        } else {
            // Expired: Show warning & runaway pay button
            trialBannerView.layer?.backgroundColor = NSColor(calibratedRed: 0.18, green: 0.06, blue: 0.06, alpha: 0.95).cgColor
            trialBannerView.layer?.borderColor = NSColor(calibratedRed: 0.937, green: 0.267, blue: 0.267, alpha: 0.75).cgColor
            trialBannerView.layer?.borderWidth = 1.5
            
            bannerTitleLabel.stringValue = "⚠️ Trial expired. That'll be $999.99/mo."
            bannerTitleLabel.textColor = NSColor(calibratedRed: 1.0, green: 0.85, blue: 0.85, alpha: 1.0)
            
            bannerStatusLabel.stringValue = "Buy on bloxstrapgold.github.io, catch the moving button, or click \"Pay later\"."
            bannerStatusLabel.textColor = NSColor(calibratedRed: 0.95, green: 0.75, blue: 0.75, alpha: 1.0)
            
            bannerBadgeLabel.stringValue = "EXPIRED"
            bannerBadgeLabel.textColor = .white
            bannerBadgeLabel.layer?.backgroundColor = NSColor(calibratedRed: 0.937, green: 0.267, blue: 0.267, alpha: 0.9).cgColor
            
            runawayCanvas.isHidden = false
            adjustBodyLayout(mode: .bannerWithRunaway)
        }
    }
    
    private enum LayoutMode {
        case cleanFull
        case bannerOnly
        case bannerWithRunaway
    }
    
    private func adjustBodyLayout(mode: LayoutMode) {
        guard let contentView = window?.contentView else { return }
        let bounds = contentView.bounds
        
        let bodyTop: CGFloat
        switch mode {
        case .cleanFull:
            bodyTop = bounds.height - 14
        case .bannerOnly:
            bodyTop = bounds.height - 78
        case .bannerWithRunaway:
            bodyTop = bounds.height - 144
        }
        
        let mainBodyY: CGFloat = 52
        let newHeight = max(100, bodyTop - mainBodyY)
        sidebarView.frame = NSRect(x: 14, y: mainBodyY, width: 200, height: newHeight)
        breadcrumbView.frame = NSRect(x: 226, y: mainBodyY + newHeight - 24, width: bounds.width - 240, height: 22)
        contentContainerView.frame = NSRect(x: 226, y: mainBodyY, width: bounds.width - 240, height: newHeight - 26)
    }
    
    @objc private func onDismissBanner() {
        AppState.shared.setBannerDismissed(true)
        refreshTrialState()
    }
    
    @objc private func onSimulateExpiry() {
        AppState.shared.setForceExpired(true)
        refreshTrialState()
    }
    
    @objc private func onResetTrial() {
        AppState.shared.resetTrial()
        refreshTrialState()
    }
    
    @objc private func onSaveSettings() {
        AppState.shared.save()
        statusToastLabel.stringValue = "✓ Settings saved!"
        statusToastLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.statusToastLabel.isHidden = true
        }
    }
    
    @objc private func onCloseWindow() {
        window?.performClose(nil)
    }
    
    // ==========================================
    // PAGE 1: BLOXSTRAP GOLD (EXACT GOLDPAGE.XAML)
    // ==========================================
    private func buildGeneralTab(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createTabScrollView(bounds: bounds)
        
        let sub = createSubtitleLabel("The ultimate luxury Roblox bootstrapper with built-in multi-instance client support.")
        stack.addArrangedSubview(sub)
        
        // VIP Membership Card (exact Bloxstrap GoldPage.xaml card)
        let heroCard = createCardView(height: 125)
        
        let crown = NSTextField(labelWithString: "👑")
        crown.font = .systemFont(ofSize: 26)
        crown.frame = NSRect(x: 16, y: 84, width: 32, height: 28)
        heroCard.addSubview(crown)
        
        let memberTitle = NSTextField(labelWithString: "BLOXSTRAP GOLD MEMBERSHIP")
        memberTitle.font = .boldSystemFont(ofSize: 14)
        memberTitle.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        memberTitle.frame = NSRect(x: 52, y: 90, width: 260, height: 20)
        heroCard.addSubview(memberTitle)
        
        tierPopup = NSPopUpButton(frame: NSRect(x: 315, y: 86, width: 180, height: 26))
        tierPopup.addItems(withTitles: [
            "Gold Basic ($19.99/mo)",
            "Gold Plus ($49.99/mo) ★",
            "Gold Deluxe ($99.99/mo)",
            "Gold ULTRA ($199.99/mo) 👑"
        ])
        tierPopup.selectItem(at: 1)
        tierPopup.target = self
        tierPopup.action = #selector(onTierChanged)
        heroCard.addSubview(tierPopup)
        
        tierBadgeLabel = NSTextField(labelWithString: "🟢 Free Forever Mode • Infinite Instances • You pay: $0.00")
        tierBadgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        tierBadgeLabel.textColor = NSColor(calibratedRed: 0.063, green: 0.725, blue: 0.506, alpha: 1.0)
        tierBadgeLabel.frame = NSRect(x: 52, y: 64, width: 380, height: 18)
        heroCard.addSubview(tierBadgeLabel)
        
        let subPrice = NSTextField(labelWithString: "Website: bloxstrapgold.github.io • 100% Free under GPL-3.0.")
        subPrice.font = .systemFont(ofSize: 10.5)
        subPrice.textColor = NSColor(calibratedRed: 0.75, green: 0.78, blue: 0.85, alpha: 1.0)
        subPrice.frame = NSRect(x: 52, y: 44, width: 380, height: 16)
        heroCard.addSubview(subPrice)
        
        // Launch Roblox Client Button (Primary Gold)
        let launchRobloxBtn = NSButton(frame: NSRect(x: heroCard.bounds.width - 235, y: 66, width: 220, height: 42))
        launchRobloxBtn.title = "🚀 Launch Roblox Client"
        launchRobloxBtn.bezelStyle = .rounded
        launchRobloxBtn.font = .boldSystemFont(ofSize: 12.5)
        launchRobloxBtn.wantsLayer = true
        launchRobloxBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 1.0).cgColor
        launchRobloxBtn.contentTintColor = .black
        launchRobloxBtn.target = self
        launchRobloxBtn.action = #selector(onLaunchRoblox)
        launchRobloxBtn.autoresizingMask = [.minXMargin]
        heroCard.addSubview(launchRobloxBtn)
        
        let buyGoldBtn = NSButton(frame: NSRect(x: heroCard.bounds.width - 235, y: 20, width: 220, height: 34))
        buyGoldBtn.title = "🛒 Buy on bloxstrapgold.github.io"
        buyGoldBtn.bezelStyle = .rounded
        buyGoldBtn.font = .systemFont(ofSize: 11, weight: .semibold)
        buyGoldBtn.target = self
        buyGoldBtn.action = #selector(onOpenStore)
        buyGoldBtn.autoresizingMask = [.minXMargin]
        heroCard.addSubview(buyGoldBtn)
        
        stack.addArrangedSubview(heroCard)
        
        // Section: Multi-Instance Roblox (exact Bloxstrap GoldPage header)
        let multiHeader = createSectionHeader("Multi-Instance Roblox (Built-in)")
        let multiSub = createSubtitleLabel("Run multiple accounts or game sessions simultaneously on a single computer without third-party injectors.")
        stack.addArrangedSubview(multiHeader)
        stack.addArrangedSubview(multiSub)
        
        // OptionControl 1: Allow multi-instance launching
        let optToggle = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        optToggle.state = .on
        let opt1 = createOptionControl(
            header: "Allow multi-instance launching",
            desc: "Run more than one Roblox game client at once without mutex conflicts.",
            control: optToggle
        )
        stack.addArrangedSubview(opt1)
        
        // Multi-Instance Actions & Status Card
        let sessionCard = createCardView(height: 195)
        
        let sTitle = NSTextField(labelWithString: "Client Session Manager")
        sTitle.font = .boldSystemFont(ofSize: 12)
        sTitle.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        sTitle.frame = NSRect(x: 16, y: 166, width: 200, height: 18)
        sessionCard.addSubview(sTitle)
        
        instanceRamBadge = NSTextField(labelWithString: "0.00 GB RAM")
        instanceRamBadge.font = .monospacedSystemFont(ofSize: 10.5, weight: .bold)
        instanceRamBadge.alignment = .center
        instanceRamBadge.wantsLayer = true
        instanceRamBadge.layer?.cornerRadius = 4
        instanceRamBadge.layer?.backgroundColor = NSColor(calibratedRed: 0.090, green: 0.102, blue: 0.133, alpha: 0.9).cgColor
        instanceRamBadge.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        instanceRamBadge.frame = NSRect(x: sessionCard.bounds.width - 120, y: 164, width: 105, height: 22)
        instanceRamBadge.autoresizingMask = [.minXMargin]
        sessionCard.addSubview(instanceRamBadge)
        
        instanceCountBadge = NSTextField(labelWithString: "0 Active")
        instanceCountBadge.font = .boldSystemFont(ofSize: 10.5)
        instanceCountBadge.alignment = .center
        instanceCountBadge.wantsLayer = true
        instanceCountBadge.layer?.cornerRadius = 4
        instanceCountBadge.layer?.backgroundColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 0.2).cgColor
        instanceCountBadge.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        instanceCountBadge.frame = NSRect(x: sessionCard.bounds.width - 215, y: 164, width: 85, height: 22)
        instanceCountBadge.autoresizingMask = [.minXMargin]
        sessionCard.addSubview(instanceCountBadge)
        
        let pScroll = NSScrollView(frame: NSRect(x: 16, y: 50, width: sessionCard.bounds.width - 32, height: 108))
        pScroll.autoresizingMask = [.width, .height]
        pScroll.hasVerticalScroller = true
        pScroll.drawsBackground = false
        
        instancesStackView = NSStackView(frame: pScroll.bounds)
        instancesStackView.orientation = .vertical
        instancesStackView.alignment = .leading
        instancesStackView.spacing = 5
        pScroll.documentView = instancesStackView
        sessionCard.addSubview(pScroll)
        
        // Bottom Action Bar inside Session Card
        let addClientBtn = NSButton(frame: NSRect(x: 16, y: 10, width: 185, height: 30))
        addClientBtn.title = "+ Launch Client Instance"
        addClientBtn.bezelStyle = .rounded
        addClientBtn.font = .boldSystemFont(ofSize: 11)
        addClientBtn.wantsLayer = true
        addClientBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 1.0).cgColor
        addClientBtn.contentTintColor = .black
        addClientBtn.target = self
        addClientBtn.action = #selector(onLaunchInstance)
        sessionCard.addSubview(addClientBtn)
        
        let launchMaxBtn = NSButton(frame: NSRect(x: 210, y: 10, width: 145, height: 30))
        launchMaxBtn.title = "⚡ Launch 3x Max"
        launchMaxBtn.bezelStyle = .rounded
        launchMaxBtn.font = .systemFont(ofSize: 11)
        launchMaxBtn.target = self
        launchMaxBtn.action = #selector(onLaunchMax)
        sessionCard.addSubview(launchMaxBtn)
        
        let killAllBtn = NSButton(frame: NSRect(x: 365, y: 10, width: 145, height: 30))
        killAllBtn.title = "🛑 Close All Clients"
        killAllBtn.bezelStyle = .rounded
        killAllBtn.font = .systemFont(ofSize: 11)
        killAllBtn.target = self
        killAllBtn.action = #selector(onTerminateAll)
        sessionCard.addSubview(killAllBtn)
        
        let refreshBtn = NSButton(frame: NSRect(x: 520, y: 10, width: 90, height: 30))
        refreshBtn.title = "🔄 Refresh"
        refreshBtn.bezelStyle = .rounded
        refreshBtn.target = self
        refreshBtn.action = #selector(onRefreshInstances)
        sessionCard.addSubview(refreshBtn)
        
        stack.addArrangedSubview(sessionCard)
        return scrollView
    }
    
    @objc private func onTierChanged() {
        let index = tierPopup.indexOfSelectedItem
        let names = ["Gold Basic", "Gold Plus", "Gold Deluxe", "Gold ULTRA"]
        let name = names[index]
        tierBadgeLabel.stringValue = "🟢 \(name) Active • Infinite Instances • You pay: $0.00"
    }
    
    // ==========================================
    // PAGE 2: STORE / BUY (BLOXSTRAPGOLD.GITHUB.IO)
    // ==========================================
    private func buildStoreTab(bounds: NSRect) -> NSView {
        let container = NSView(frame: bounds)
        container.autoresizingMask = [.width, .height]
        
        let barHeight: CGFloat = 38
        let navBar = NSView(frame: NSRect(x: 0, y: bounds.height - barHeight, width: bounds.width, height: barHeight))
        navBar.wantsLayer = true
        navBar.layer?.backgroundColor = NSColor(calibratedRed: 0.050, green: 0.055, blue: 0.068, alpha: 0.95).cgColor
        navBar.layer?.borderColor = NSColor(white: 1.0, alpha: 0.08).cgColor
        navBar.layer?.borderWidth = 1.0
        navBar.autoresizingMask = [.width, .minYMargin]
        container.addSubview(navBar)
        
        let globeIcon = NSTextField(labelWithString: "🌐")
        globeIcon.font = .systemFont(ofSize: 12)
        globeIcon.frame = NSRect(x: 12, y: 10, width: 18, height: 16)
        navBar.addSubview(globeIcon)
        
        let urlLabel = NSTextField(labelWithString: "https://bloxstrapgold.github.io")
        urlLabel.font = .monospacedSystemFont(ofSize: 10.5, weight: .bold)
        urlLabel.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        urlLabel.frame = NSRect(x: 32, y: 10, width: 240, height: 16)
        navBar.addSubview(urlLabel)
        
        let openBrowserBtn = NSButton(frame: NSRect(x: navBar.bounds.width - 325, y: 5, width: 135, height: 26))
        openBrowserBtn.title = "Open in Browser ↗"
        openBrowserBtn.bezelStyle = .rounded
        openBrowserBtn.font = .systemFont(ofSize: 10, weight: .semibold)
        openBrowserBtn.target = self
        openBrowserBtn.action = #selector(onOpenStoreInBrowser)
        openBrowserBtn.autoresizingMask = [.minXMargin]
        navBar.addSubview(openBrowserBtn)
        
        let pricingBtn = NSButton(frame: NSRect(x: navBar.bounds.width - 180, y: 5, width: 115, height: 26))
        pricingBtn.title = "⚡ View Pricing"
        pricingBtn.bezelStyle = .rounded
        pricingBtn.font = .systemFont(ofSize: 10)
        pricingBtn.target = self
        pricingBtn.action = #selector(onScrollToPricing)
        pricingBtn.autoresizingMask = [.minXMargin]
        navBar.addSubview(pricingBtn)
        
        let reloadBtn = NSButton(frame: NSRect(x: navBar.bounds.width - 55, y: 5, width: 45, height: 26))
        reloadBtn.title = "↺"
        reloadBtn.bezelStyle = .rounded
        reloadBtn.font = .boldSystemFont(ofSize: 11)
        reloadBtn.target = self
        reloadBtn.action = #selector(onReloadStore)
        reloadBtn.autoresizingMask = [.minXMargin]
        navBar.addSubview(reloadBtn)
        
        let webConfig = WKWebViewConfiguration()
        storeWebView = WKWebView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height - barHeight), configuration: webConfig)
        storeWebView?.autoresizingMask = [.width, .height]
        storeWebView?.navigationDelegate = self
        storeWebView?.setValue(false, forKey: "drawsBackground")
        if let wv = storeWebView {
            container.addSubview(wv)
        }
        
        loadStoreWebsite()
        return container
    }
    
    private func loadStoreWebsite() {
        let localIndex = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/website/index.html")
        if FileManager.default.fileExists(atPath: localIndex.path) {
            storeWebView?.loadFileURL(localIndex, allowingReadAccessTo: localIndex.deletingLastPathComponent())
        } else if let onlineURL = URL(string: "https://bloxstrapgold.github.io") {
            storeWebView?.load(URLRequest(url: onlineURL))
        }
    }
    
    @objc private func onScrollToPricing() {
        storeWebView?.evaluateJavaScript("document.getElementById('pricing')?.scrollIntoView({behavior: 'smooth'})", completionHandler: nil)
    }
    
    @objc private func onReloadStore() {
        loadStoreWebsite()
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.scheme == "bloxstrap-gold" {
                if let key = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "key" })?.value {
                    handleDeepLinkActivation(key: key)
                }
                decisionHandler(.cancel)
                return
            }
            if url.scheme == "http" || url.scheme == "https" {
                if url.host != "bloxstrapgold.github.io" && url.host != "localhost" {
                    NSWorkspace.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
    
    // ==========================================
    // PAGE 3: INTEGRATIONS (EXACT INTEGRATIONSPAGE.XAML)
    // ==========================================
    private func buildIntegrationsTab(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createTabScrollView(bounds: bounds)
        
        let sub = createSubtitleLabel("Connect Bloxstrap to external services like Discord.")
        stack.addArrangedSubview(sub)
        
        // Discord Rich Presence OptionControl
        let rpcContainer = NSView(frame: NSRect(x: 0, y: 0, width: 290, height: 30))
        let rpcToggle = NSButton(checkboxWithTitle: "Enable", target: nil, action: nil)
        rpcToggle.state = .on
        rpcToggle.frame = NSRect(x: 0, y: 4, width: 75, height: 22)
        rpcContainer.addSubview(rpcToggle)
        
        let badgePopup = NSPopUpButton(frame: NSRect(x: 80, y: 2, width: 185, height: 26))
        badgePopup.addItems(withTitles: ["Gold Standard", "18k Gold Plus", "24k Solid Gold", "Obsidian & Liquid Gold"])
        badgePopup.selectItem(at: 1)
        rpcContainer.addSubview(badgePopup)
        
        let optRpc = createOptionControl(
            header: "Discord Rich Presence",
            desc: "Show what game you're playing and your Gold badge on Discord.",
            control: rpcContainer,
            height: 64
        )
        stack.addArrangedSubview(optRpc)
        
        // Server Location Telemetry OptionControl
        let locToggle = NSButton(checkboxWithTitle: "Enabled", target: nil, action: nil)
        locToggle.state = .on
        locToggle.frame = NSRect(x: 0, y: 4, width: 85, height: 22)
        
        let optLoc = createOptionControl(
            header: "Server location details",
            desc: "Show the server country, city, and round-trip ping using ipinfo.io.",
            control: locToggle,
            height: 64
        )
        stack.addArrangedSubview(optLoc)
        
        return scrollView
    }
    
    // ==========================================
    // PAGE 4: MODS (EXACT MODSPAGE.XAML)
    // ==========================================
    private func buildModsTab(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createTabScrollView(bounds: bounds)
        
        let sub = createSubtitleLabel("Manage game files, audio replacements, and display scaling.")
        stack.addArrangedSubview(sub)
        
        // Death Sound OptionControl
        let soundContainer = NSView(frame: NSRect(x: 0, y: 0, width: 330, height: 30))
        let prevBtn = NSButton(frame: NSRect(x: 0, y: 2, width: 85, height: 26))
        prevBtn.title = "🔊 Preview"
        prevBtn.bezelStyle = .rounded
        prevBtn.target = self
        prevBtn.action = #selector(onPlayClassicSound)
        soundContainer.addSubview(prevBtn)
        
        let installBtn = NSButton(frame: NSRect(x: 90, y: 2, width: 130, height: 26))
        installBtn.title = "⚡ Install Oof"
        installBtn.bezelStyle = .rounded
        installBtn.target = self
        installBtn.action = #selector(onInstallSoundIntoRoblox)
        soundContainer.addSubview(installBtn)
        
        let restoreBtn = NSButton(frame: NSRect(x: 225, y: 2, width: 100, height: 26))
        restoreBtn.title = "↺ Restore"
        restoreBtn.bezelStyle = .rounded
        restoreBtn.target = self
        restoreBtn.action = #selector(onRestoreSound)
        soundContainer.addSubview(restoreBtn)
        
        let optSound = createOptionControl(
            header: "Death sound",
            desc: "Restore the classic 2006 \"Oof\" sound into Roblox.app.",
            control: soundContainer,
            height: 64
        )
        stack.addArrangedSubview(optSound)
        
        // Mouse Cursor OptionControl
        let cursorPopup = NSPopUpButton(frame: NSRect(x: 0, y: 2, width: 185, height: 26))
        cursorPopup.addItems(withTitles: ["Gold Edition Cursor", "Classic 2006 Cursor", "2013 Cursor", "Default Roblox"])
        cursorPopup.selectItem(at: 0)
        
        let optCursor = createOptionControl(
            header: "Mouse cursor",
            desc: "Choose what mouse cursor style Roblox should use.",
            control: cursorPopup,
            height: 64
        )
        stack.addArrangedSubview(optCursor)
        
        // Retina Display Scaling OptionControl
        let dpiBtn = NSButton(frame: NSRect(x: 0, y: 2, width: 165, height: 26))
        dpiBtn.title = "⚡ Enable Retina 1:1"
        dpiBtn.bezelStyle = .rounded
        dpiBtn.target = self
        dpiBtn.action = #selector(onToggleRetinaDpi)
        
        let optDpi = createOptionControl(
            header: "Retina display scaling",
            desc: "Render at native pixel resolution on Retina displays to eliminate blur.",
            control: dpiBtn,
            height: 64
        )
        stack.addArrangedSubview(optDpi)
        
        // In-Game Native FPS Counter OptionControl
        let fpsBtn = NSButton(frame: NSRect(x: 0, y: 2, width: 165, height: 26))
        fpsBtn.title = "⚡ Toggle Overlay"
        fpsBtn.bezelStyle = .rounded
        fpsBtn.target = self
        fpsBtn.action = #selector(onToggleFpsOverlay)
        
        let optFps = createOptionControl(
            header: "In-game FPS overlay",
            desc: "Show the built-in engine FPS counter in the corner without pressing Shift+F5.",
            control: fpsBtn,
            height: 64
        )
        stack.addArrangedSubview(optFps)
        
        return scrollView
    }
    
    @objc private func onPlayClassicSound() {
        SoundManager.shared.playPreview()
    }
    
    @objc private func onInstallSoundIntoRoblox() {
        let res = SoundManager.shared.installOofIntoRoblox()
        let alert = createGoldAlert(
            title: res.success ? "Classic Sound Installed" : "Installation Failed",
            message: res.message,
            style: res.success ? .informational : .critical
        )
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func onRestoreSound() {
        let res = SoundManager.shared.restoreOriginalSound()
        let alert = createGoldAlert(
            title: res.success ? "Default Sound Restored" : "Notice",
            message: res.message,
            style: res.success ? .informational : .warning
        )
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func onToggleRetinaDpi() {
        FastFlagManager.shared.setFlag(key: "DFFlagDisableDPIScale", value: "True")
        let alert = createGoldAlert(
            title: "Retina 1:1 Rendering Enabled",
            message: "DFFlagDisableDPIScale set to True in ClientAppSettings.json.\nRoblox will render at full native Retina resolution.",
            style: .informational
        )
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func onToggleFpsOverlay() {
        FastFlagManager.shared.setFlag(key: "FFlagDebugDisplayFPS", value: "True")
        let alert = createGoldAlert(
            title: "FPS Counter Enabled",
            message: "FFlagDebugDisplayFPS set to True in ClientAppSettings.json.\nRoblox will show the in-game FPS counter in the top-right corner.",
            style: .informational
        )
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    // ==========================================
    // PAGE 5: FASTFLAGS (EXACT FASTFLAGSPAGE.XAML)
    // ==========================================
    private func buildFastFlagsTab(bounds: NSRect) -> NSView {
        let view = NSView(frame: bounds)
        
        // --- 1. LOCKED VIEW ---
        keyLockContainer = NSView(frame: NSRect(x: 20, y: 20, width: bounds.width - 40, height: bounds.height - 40))
        keyLockContainer.wantsLayer = true
        keyLockContainer.layer?.backgroundColor = NSColor(calibratedRed: 0.055, green: 0.062, blue: 0.078, alpha: 0.95).cgColor
        keyLockContainer.layer?.borderColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 0.35).cgColor
        keyLockContainer.layer?.borderWidth = 1.0
        keyLockContainer.layer?.cornerRadius = 6
        keyLockContainer.autoresizingMask = [.width, .height]
        view.addSubview(keyLockContainer)
        
        let lockIcon = NSTextField(labelWithString: "🔒")
        lockIcon.font = .systemFont(ofSize: 34)
        lockIcon.frame = NSRect(x: 20, y: keyLockContainer.bounds.height - 62, width: 44, height: 40)
        keyLockContainer.addSubview(lockIcon)
        
        let lockTitle = NSTextField(labelWithString: "FastFlags Vault & Allowlist Engine")
        lockTitle.font = .boldSystemFont(ofSize: 14)
        lockTitle.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        lockTitle.frame = NSRect(x: 75, y: keyLockContainer.bounds.height - 44, width: 440, height: 20)
        keyLockContainer.addSubview(lockTitle)
        
        let lockSub = NSTextField(wrappingLabelWithString: "This tab is gated by a Gold License Key.\nAny key that starts with \"GOLD-\" will unlock it (e.g. GOLD-7DAY-8849-F291-C84B-9102-E7A4). We don't check anything else.")
        lockSub.font = .systemFont(ofSize: 11)
        lockSub.textColor = NSColor(calibratedRed: 0.75, green: 0.78, blue: 0.85, alpha: 1.0)
        lockSub.frame = NSRect(x: 75, y: keyLockContainer.bounds.height - 90, width: 480, height: 34)
        keyLockContainer.addSubview(lockSub)
        
        let keyLabel = NSTextField(labelWithString: "Gold License Key:")
        keyLabel.font = .boldSystemFont(ofSize: 11)
        keyLabel.textColor = .white
        keyLabel.frame = NSRect(x: 75, y: keyLockContainer.bounds.height - 124, width: 140, height: 18)
        keyLockContainer.addSubview(keyLabel)
        
        keyInputField = NSTextField(frame: NSRect(x: 75, y: keyLockContainer.bounds.height - 156, width: 280, height: 28))
        keyInputField.placeholderString = "GOLD-7DAY-8849-F291-C84B-9102-E7A4"
        keyInputField.font = .monospacedSystemFont(ofSize: 10.5, weight: .bold)
        keyLockContainer.addSubview(keyInputField)
        
        let quickFillBtn = NSButton(frame: NSRect(x: 365, y: keyLockContainer.bounds.height - 158, width: 105, height: 30))
        quickFillBtn.title = "⚡ Quick-Fill"
        quickFillBtn.bezelStyle = .rounded
        quickFillBtn.font = .systemFont(ofSize: 10.5, weight: .bold)
        quickFillBtn.target = self
        quickFillBtn.action = #selector(onQuickFillKey)
        keyLockContainer.addSubview(quickFillBtn)
        
        let unlockBtn = NSButton(frame: NSRect(x: 480, y: keyLockContainer.bounds.height - 158, width: 120, height: 30))
        unlockBtn.title = "Unlock Vault"
        unlockBtn.bezelStyle = .rounded
        unlockBtn.font = .boldSystemFont(ofSize: 11)
        unlockBtn.wantsLayer = true
        unlockBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 1.0).cgColor
        unlockBtn.contentTintColor = .black
        unlockBtn.target = self
        unlockBtn.action = #selector(onUnlockFastFlags)
        keyLockContainer.addSubview(unlockBtn)
        
        let buyKeyBtn = NSButton(frame: NSRect(x: 75, y: keyLockContainer.bounds.height - 200, width: 280, height: 30))
        buyKeyBtn.title = "🛒 Get License Key at bloxstrapgold.github.io"
        buyKeyBtn.bezelStyle = .rounded
        buyKeyBtn.font = .systemFont(ofSize: 10.5, weight: .semibold)
        buyKeyBtn.target = self
        buyKeyBtn.action = #selector(onOpenStore)
        keyLockContainer.addSubview(buyKeyBtn)
        
        // --- 2. UNLOCKED VIEW ---
        fastFlagsUnlockedContainer = NSView(frame: bounds)
        fastFlagsUnlockedContainer.autoresizingMask = [.width, .height]
        view.addSubview(fastFlagsUnlockedContainer)
        
        let unlTitle = NSTextField(labelWithString: "FastFlags Vault — September 2025 Allowlist")
        unlTitle.font = .boldSystemFont(ofSize: 14)
        unlTitle.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        unlTitle.frame = NSRect(x: 16, y: bounds.height - 34, width: 440, height: 20)
        unlTitle.autoresizingMask = [.minYMargin]
        fastFlagsUnlockedContainer.addSubview(unlTitle)
        
        unlockedBadgeLabel = NSTextField(labelWithString: "👑 VIP ACTIVATED")
        unlockedBadgeLabel.font = .boldSystemFont(ofSize: 9)
        unlockedBadgeLabel.alignment = .center
        unlockedBadgeLabel.wantsLayer = true
        unlockedBadgeLabel.layer?.cornerRadius = 3
        unlockedBadgeLabel.layer?.backgroundColor = NSColor(calibratedRed: 0.063, green: 0.725, blue: 0.506, alpha: 0.25).cgColor
        unlockedBadgeLabel.textColor = NSColor(calibratedRed: 0.063, green: 0.725, blue: 0.506, alpha: 1.0)
        unlockedBadgeLabel.frame = NSRect(x: bounds.width - 170, y: bounds.height - 35, width: 155, height: 18)
        unlockedBadgeLabel.autoresizingMask = [.minXMargin, .minYMargin]
        fastFlagsUnlockedContainer.addSubview(unlockedBadgeLabel)
        
        // Settings Card: Framerate limit & Backend mode
        let configCard = NSView(frame: NSRect(x: 16, y: bounds.height - 95, width: bounds.width - 32, height: 54))
        configCard.wantsLayer = true
        configCard.layer?.backgroundColor = NSColor(calibratedRed: 0.067, green: 0.075, blue: 0.094, alpha: 0.95).cgColor
        configCard.layer?.borderColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 0.22).cgColor
        configCard.layer?.borderWidth = 1.0
        configCard.layer?.cornerRadius = 6
        configCard.autoresizingMask = [.minYMargin, .width]
        fastFlagsUnlockedContainer.addSubview(configCard)
        
        let fpsLabel = NSTextField(labelWithString: "Target FPS:")
        fpsLabel.font = .boldSystemFont(ofSize: 11)
        fpsLabel.textColor = .white
        fpsLabel.frame = NSRect(x: 12, y: 18, width: 75, height: 16)
        configCard.addSubview(fpsLabel)
        
        fpsPopup = NSPopUpButton(frame: NSRect(x: 90, y: 13, width: 140, height: 26))
        fpsPopup.addItems(withTitles: ["60 FPS", "120 FPS", "144 FPS", "165 FPS", "240 FPS", "Uncapped (9999)"])
        fpsPopup.selectItem(at: 4)
        configCard.addSubview(fpsPopup)
        
        let backendLabel = NSTextField(labelWithString: "Graphics Mode:")
        backendLabel.font = .boldSystemFont(ofSize: 11)
        backendLabel.textColor = .white
        backendLabel.frame = NSRect(x: 250, y: 18, width: 95, height: 16)
        configCard.addSubview(backendLabel)
        
        backendPopup = NSPopUpButton(frame: NSRect(x: 350, y: 13, width: 170, height: 26))
        backendPopup.addItems(withTitles: ["Metal (macOS Default)", "MoltenVK / Vulkan", "OpenGL"])
        backendPopup.selectItem(at: 0)
        configCard.addSubview(backendPopup)
        
        let applyFpsBtn = NSButton(frame: NSRect(x: configCard.bounds.width - 118, y: 13, width: 105, height: 28))
        applyFpsBtn.title = "Save Preset"
        applyFpsBtn.bezelStyle = .rounded
        applyFpsBtn.target = self
        applyFpsBtn.action = #selector(onApplyFps)
        applyFpsBtn.autoresizingMask = [.minXMargin]
        configCard.addSubview(applyFpsBtn)
        
        // Allowlist Table View
        let tableScroll = NSScrollView(frame: NSRect(x: 16, y: 52, width: bounds.width - 32, height: bounds.height - 155))
        tableScroll.autoresizingMask = [.width, .height]
        tableScroll.hasVerticalScroller = true
        tableScroll.drawsBackground = false
        
        let stack = NSStackView(frame: tableScroll.bounds)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 5
        tableScroll.documentView = stack
        fastFlagsUnlockedContainer.addSubview(tableScroll)
        
        for flag in FastFlagManager.shared.registry {
            let row = NSView(frame: NSRect(x: 0, y: 0, width: bounds.width - 48, height: 34))
            row.wantsLayer = true
            row.layer?.backgroundColor = NSColor(calibratedRed: 0.090, green: 0.102, blue: 0.133, alpha: 0.85).cgColor
            row.layer?.cornerRadius = 5
            row.autoresizingMask = [.width]
            
            let statusBadge = NSTextField(labelWithString: flag.isAllowed ? "✓ ALLOWLISTED" : "✕ BLOCKED")
            statusBadge.font = .systemFont(ofSize: 8.5, weight: .bold)
            statusBadge.textColor = flag.isAllowed ? NSColor(calibratedRed: 0.063, green: 0.725, blue: 0.506, alpha: 1.0) : NSColor(calibratedRed: 0.937, green: 0.267, blue: 0.267, alpha: 1.0)
            statusBadge.frame = NSRect(x: 10, y: 8, width: 105, height: 16)
            row.addSubview(statusBadge)
            
            let keyLabel = NSTextField(labelWithString: flag.key)
            keyLabel.font = .monospacedSystemFont(ofSize: 10.5, weight: .bold)
            keyLabel.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
            keyLabel.frame = NSRect(x: 125, y: 16, width: 340, height: 15)
            row.addSubview(keyLabel)
            
            let descLabel = NSTextField(labelWithString: flag.description)
            descLabel.font = .systemFont(ofSize: 9)
            descLabel.textColor = NSColor(calibratedRed: 0.75, green: 0.78, blue: 0.85, alpha: 1.0)
            descLabel.frame = NSRect(x: 125, y: 2, width: 440, height: 14)
            row.addSubview(descLabel)
            
            stack.addArrangedSubview(row)
        }
        
        // Bottom Action Bar
        let applyAllBtn = NSButton(frame: NSRect(x: 16, y: 12, width: 210, height: 30))
        applyAllBtn.title = "⚡ Apply Recommended Flags"
        applyAllBtn.bezelStyle = .rounded
        applyAllBtn.font = .boldSystemFont(ofSize: 11)
        applyAllBtn.wantsLayer = true
        applyAllBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 1.0).cgColor
        applyAllBtn.contentTintColor = .black
        applyAllBtn.target = self
        applyAllBtn.action = #selector(onApplyRecommendedFlags)
        applyAllBtn.autoresizingMask = [.maxYMargin]
        fastFlagsUnlockedContainer.addSubview(applyAllBtn)
        
        let openFolderBtn = NSButton(frame: NSRect(x: 236, y: 12, width: 180, height: 30))
        openFolderBtn.title = "📂 Open Settings Folder"
        openFolderBtn.bezelStyle = .rounded
        openFolderBtn.target = self
        openFolderBtn.action = #selector(onOpenClientSettingsFolder)
        openFolderBtn.autoresizingMask = [.maxYMargin]
        fastFlagsUnlockedContainer.addSubview(openFolderBtn)
        
        let viewJsonBtn = NSButton(frame: NSRect(x: 426, y: 12, width: 125, height: 30))
        viewJsonBtn.title = "👁 View Live JSON"
        viewJsonBtn.bezelStyle = .rounded
        viewJsonBtn.target = self
        viewJsonBtn.action = #selector(onViewLiveJson)
        viewJsonBtn.autoresizingMask = [.maxYMargin]
        fastFlagsUnlockedContainer.addSubview(viewJsonBtn)
        
        updateFastFlagsVisibility()
        return view
    }
    
    private func updateFastFlagsVisibility() {
        let isUnlocked = AppState.shared.data.isFastFlagsUnlocked
        keyLockContainer.isHidden = isUnlocked
        fastFlagsUnlockedContainer.isHidden = !isUnlocked
        if let key = AppState.shared.data.vipKey {
            unlockedBadgeLabel?.stringValue = "👑 VIP: \(key)"
        }
    }
    
    @objc private func onQuickFillKey() {
        keyInputField.stringValue = "GOLD-7DAY-8849-F291-C84B-9102-E7A4"
    }
    
    @objc private func onUnlockFastFlags() {
        let key = keyInputField.stringValue
        if AppState.shared.verifyAndApplyKey(key) {
            updateFastFlagsVisibility()
            let alert = createGoldAlert(
                title: "👑 FastFlags Vault Unlocked",
                message: "Key verified. You can now tune framerates and configure Roblox FastFlags on macOS.",
                style: .informational
            )
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } else {
            let alert = createGoldAlert(
                title: "Invalid Key Format",
                message: "Key must start with \"GOLD-\" (e.g. GOLD-7DAY-XXXX).",
                style: .critical
            )
            alert.addButton(withTitle: "Try Again")
            alert.runModal()
        }
    }
    
    @objc private func onApplyFps() {
        let index = fpsPopup.indexOfSelectedItem
        let fpsValues = [60, 120, 144, 165, 240, 9999]
        let chosenFps = fpsValues[index]
        FastFlagManager.shared.setFlag(key: "DFIntTaskSchedulerTargetFps", value: chosenFps)
        
        let alert = createGoldAlert(
            title: "Preset Saved",
            message: "Target framerate set to \(chosenFps == 9999 ? "Uncapped (9999)" : "\(chosenFps) FPS") in ClientAppSettings.json.",
            style: .informational
        )
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func onApplyRecommendedFlags() {
        let settings: [String: Any] = [
            "DFIntTaskSchedulerTargetFps": 9999,
            "DFFlagDisableDPIScale": "True",
            "FIntDebugForceMSAASamples": 4,
            "DFFlagTextureQualityOverrideEnabled": "True",
            "DFIntTextureQualityOverride": 3,
            "FFlagHandleAltEnterFullscreenManually": "True",
            "FFlagDebugDisplayFPS": "True",
            "FFlagDebugGraphicsPreferVulkan": "True",
            "FIntFRMMaxGrassDistance": 300,
            "FFlagFixGraphicsQuality": "True",
            "DFIntCanHideGuiGroupId": 32380007
        ]
        _ = FastFlagManager.shared.saveSettings(settings)
        
        let alert = createGoldAlert(
            title: "Recommended Flags Applied",
            message: "Saved 11 allowlisted FastFlags to:\n~/Library/Application Support/Roblox/ClientSettings/ClientAppSettings.json",
            style: .informational
        )
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func onOpenClientSettingsFolder() {
        let folder = FastFlagManager.shared.clientSettingsURL.deletingLastPathComponent()
        NSWorkspace.shared.selectFile(FastFlagManager.shared.clientSettingsURL.path, inFileViewerRootedAtPath: folder.path)
    }
    
    @objc private func onViewLiveJson() {
        let url = FastFlagManager.shared.clientSettingsURL
        let content: String
        if let data = try? Data(contentsOf: url), let str = String(data: data, encoding: .utf8) {
            content = str
        } else {
            content = "ClientAppSettings.json is currently empty."
        }
        
        let alert = createGoldAlert(
            title: "Live ClientAppSettings.json",
            message: content,
            style: .informational
        )
        alert.addButton(withTitle: "Close")
        alert.runModal()
    }
    
    // ==========================================
    // PAGE 6: APPEARANCE (EXACT APPEARANCEPAGE.XAML)
    // ==========================================
    private func buildAppearanceTab(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createTabScrollView(bounds: bounds)
        
        let sub = createSubtitleLabel("Configure how Bloxstrap Gold looks.")
        stack.addArrangedSubview(sub)
        
        // Theme OptionControl
        let themePopup = NSPopUpButton(frame: NSRect(x: 0, y: 2, width: 190, height: 26))
        themePopup.addItems(withTitles: ["Gold Edition (Dark)", "Standard Bloxstrap (Purple)", "Light"])
        themePopup.selectItem(at: 0)
        
        let optTheme = createOptionControl(
            header: "Theme",
            desc: "Change the interface theme of Bloxstrap.",
            control: themePopup,
            height: 64
        )
        stack.addArrangedSubview(optTheme)
        
        // Bootstrapper Style OptionControl
        let stylePopup = NSPopUpButton(frame: NSRect(x: 0, y: 2, width: 190, height: 26))
        stylePopup.addItems(withTitles: ["Fluent (Gold Accent)", "Classic Fluent", "Progress Bar", "Byfron"])
        stylePopup.selectItem(at: 0)
        
        let optStyle = createOptionControl(
            header: "Bootstrapper style",
            desc: "Choose the launcher dialog style shown when Roblox starts.",
            control: stylePopup,
            height: 64
        )
        stack.addArrangedSubview(optStyle)
        
        // Icon OptionControl
        let iconPopup = NSPopUpButton(frame: NSRect(x: 0, y: 2, width: 190, height: 26))
        iconPopup.addItems(withTitles: ["Bloxstrap Gold Crown 👑", "Classic Bloxstrap", "Early 2011", "2008"])
        iconPopup.selectItem(at: 0)
        
        let optIcon = createOptionControl(
            header: "Icon",
            desc: "Choose what icon Bloxstrap Gold should use.",
            control: iconPopup,
            height: 64
        )
        stack.addArrangedSubview(optIcon)
        
        return scrollView
    }
    
    // ==========================================
    // PAGE 7: ABOUT (EXACT ABOUTPAGE.XAML)
    // ==========================================
    private func buildAboutTab(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createTabScrollView(bounds: bounds)
        
        let sub = createSubtitleLabel("Bloxstrap Gold v2.11.4 — Open Source under GPL-3.0")
        stack.addArrangedSubview(sub)
        
        let aboutCard = createCardView(height: 240)
        let text = NSTextField(wrappingLabelWithString: """
        Is this real?
        No. It's a joke. Bloxstrap Gold is completely free and open-source under GPL-3.0. We don't want your money, we don't store your card, and nobody is ever getting charged. It's literally just a bit.
        
        Official Website:
        https://bloxstrapgold.github.io
        
        Who made what?
        • Bloxstrap was created by pizzaboxer and contributors (github.com/bloxstraplabs/bloxstrap).
        • The Mac multi-instance technique is based on research by Insadem (multi-roblox-macos).
        • Windows multi-instance research by Avaluate/Fliktem and ic3w0lf22.
        • We wrapped it in a deadpan gold theme because the idea of a paid subscription for an open-source Roblox launcher was hilarious.
        
        Bloxstrap Gold is not affiliated with or endorsed by Roblox Corporation.
        """)
        text.font = .systemFont(ofSize: 11)
        text.textColor = NSColor(calibratedRed: 0.82, green: 0.85, blue: 0.92, alpha: 1.0)
        text.frame = NSRect(x: 16, y: 12, width: aboutCard.bounds.width - 32, height: 215)
        text.autoresizingMask = [.width, .height]
        aboutCard.addSubview(text)
        stack.addArrangedSubview(aboutCard)
        
        // Developer & Test Controls Card
        let devCard = createCardView(height: 70)
        let devTitle = NSTextField(labelWithString: "Website & Developer Test Controls:")
        devTitle.font = .boldSystemFont(ofSize: 11)
        devTitle.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        devTitle.frame = NSRect(x: 16, y: 44, width: 350, height: 16)
        devCard.addSubview(devTitle)
        
        let simExpBtn = NSButton(frame: NSRect(x: 16, y: 10, width: 145, height: 26))
        simExpBtn.title = "⚡ Expire Trial (Demo)"
        simExpBtn.bezelStyle = .rounded
        simExpBtn.target = self
        simExpBtn.action = #selector(onSimulateExpiry)
        devCard.addSubview(simExpBtn)
        
        let resetBtn = NSButton(frame: NSRect(x: 170, y: 10, width: 125, height: 26))
        resetBtn.title = "↺ Reset (7 Days)"
        resetBtn.bezelStyle = .rounded
        resetBtn.target = self
        resetBtn.action = #selector(onResetTrial)
        devCard.addSubview(resetBtn)
        
        let wipeBtn = NSButton(frame: NSRect(x: 305, y: 10, width: 140, height: 26))
        wipeBtn.title = "🗑️ Reset App Data"
        wipeBtn.bezelStyle = .rounded
        wipeBtn.target = self
        wipeBtn.action = #selector(onWipeData)
        devCard.addSubview(wipeBtn)
        
        let webLinkBtn = NSButton(frame: NSRect(x: devCard.bounds.width - 150, y: 10, width: 135, height: 26))
        webLinkBtn.title = "🌐 Website ↗"
        webLinkBtn.bezelStyle = .rounded
        webLinkBtn.font = .systemFont(ofSize: 10.5, weight: .semibold)
        webLinkBtn.target = self
        webLinkBtn.action = #selector(onOpenStoreInBrowser)
        webLinkBtn.autoresizingMask = [.minXMargin]
        devCard.addSubview(webLinkBtn)
        
        stack.addArrangedSubview(devCard)
        return scrollView
    }
    
    @objc private func onWipeData() {
        AppState.shared.resetTrial()
        refreshTrialState()
        let alert = createGoldAlert(
            title: "Data Reset",
            message: "App state has been reset to defaults.",
            style: .informational
        )
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    // --- ACTIONS ---
    @objc private func onLaunchRoblox() {
        let res = MultiInstanceManager.shared.launchNewInstance()
        let alert = createGoldAlert(
            title: res.success ? "Roblox Client Launched" : "Launch Failed",
            message: res.message,
            style: res.success ? .informational : .critical
        )
        alert.addButton(withTitle: "OK")
        alert.runModal()
        updateInstanceList()
    }
    
    @objc private func onLaunchInstance() {
        onLaunchRoblox()
    }
    
    @objc private func onLaunchMax() {
        _ = MultiInstanceManager.shared.launchNewInstance()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            _ = MultiInstanceManager.shared.launchNewInstance()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            _ = MultiInstanceManager.shared.launchNewInstance()
            self?.updateInstanceList()
        }
    }
    
    @objc private func onTerminateAll() {
        _ = MultiInstanceManager.shared.terminateAllInstances()
        updateInstanceList()
    }
    
    private func updateInstanceList() {
        let pids = MultiInstanceManager.shared.getRunningInstances()
        instanceCountBadge?.stringValue = "\(pids.count) Active"
        
        var totalMb: Int = 0
        for pid in pids {
            totalMb += MultiInstanceManager.shared.getMemoryForPid(pid: pid)
        }
        let totalGb = Double(totalMb) / 1024.0
        instanceRamBadge?.stringValue = String(format: "%.2f GB RAM", totalGb)
        
        guard let stack = instancesStackView else { return }
        stack.subviews.forEach { $0.removeFromSuperview() }
        
        if pids.isEmpty {
            let emptyLabel = NSTextField(labelWithString: "🎮 No Roblox clients running right now. Click \"+ Launch Client Instance\" below.")
            emptyLabel.font = .systemFont(ofSize: 11)
            emptyLabel.textColor = .gray
            stack.addArrangedSubview(emptyLabel)
        } else {
            for (idx, pid) in pids.enumerated() {
                let ram = MultiInstanceManager.shared.getMemoryForPid(pid: pid)
                let row = NSView(frame: NSRect(x: 0, y: 0, width: 620, height: 30))
                row.wantsLayer = true
                row.layer?.backgroundColor = NSColor(calibratedRed: 0.090, green: 0.102, blue: 0.133, alpha: 0.85).cgColor
                row.layer?.cornerRadius = 4
                row.autoresizingMask = [.width]
                
                let dot = NSTextField(labelWithString: "🟢")
                dot.font = .systemFont(ofSize: 9)
                dot.frame = NSRect(x: 8, y: 7, width: 16, height: 16)
                row.addSubview(dot)
                
                let lbl = NSTextField(labelWithString: "Client #\(idx + 1) • PID: \(pid)")
                lbl.font = .monospacedSystemFont(ofSize: 10.5, weight: .bold)
                lbl.textColor = .white
                lbl.frame = NSRect(x: 28, y: 6, width: 220, height: 18)
                row.addSubview(lbl)
                
                let ramLbl = NSTextField(labelWithString: "\(ram) MB RAM • 240 FPS")
                ramLbl.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
                ramLbl.textColor = NSColor(calibratedRed: 0.886, green: 0.753, blue: 0.463, alpha: 0.9)
                ramLbl.frame = NSRect(x: 250, y: 6, width: 180, height: 18)
                row.addSubview(ramLbl)
                
                let killBtn = NSButton(frame: NSRect(x: row.bounds.width - 70, y: 3, width: 62, height: 24))
                killBtn.title = "Close"
                killBtn.bezelStyle = .inline
                killBtn.font = .systemFont(ofSize: 10)
                killBtn.tag = pid
                killBtn.target = self
                killBtn.action = #selector(onKillSingleInstance(_:))
                killBtn.autoresizingMask = [.minXMargin]
                row.addSubview(killBtn)
                
                stack.addArrangedSubview(row)
            }
        }
    }
    
    @objc private func onRefreshInstances() {
        updateInstanceList()
    }
    
    @objc private func onKillSingleInstance(_ sender: NSButton) {
        let pid = sender.tag
        kill(pid_t(pid), SIGTERM)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updateInstanceList()
        }
    }
    
    // --- UI FACTORY HELPERS (BLOXSTRAP CONTROLS) ---
    private func createTabScrollView(bounds: NSRect) -> (NSScrollView, NSStackView) {
        let scroll = NSScrollView(frame: bounds)
        scroll.autoresizingMask = [.width, .height]
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        
        let docView = FlippedContainerView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        docView.autoresizingMask = [.width]
        
        let stack = NSStackView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: 0))
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        docView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: docView.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: docView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: docView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: docView.bottomAnchor, constant: -14)
        ])
        
        scroll.documentView = docView
        return (scroll, stack)
    }
    
    private func createSectionHeader(_ text: String) -> NSTextField {
        let lbl = NSTextField(labelWithString: text)
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        return lbl
    }
    
    private func createSubtitleLabel(_ text: String) -> NSTextField {
        let lbl = NSTextField(wrappingLabelWithString: text)
        lbl.font = .systemFont(ofSize: 11)
        lbl.textColor = NSColor(calibratedRed: 0.70, green: 0.74, blue: 0.82, alpha: 1.0)
        return lbl
    }
    
    private func createCardView(height: CGFloat) -> NSView {
        let card = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: height))
        card.wantsLayer = true
        card.layer?.backgroundColor = NSColor(calibratedRed: 0.067, green: 0.075, blue: 0.094, alpha: 0.95).cgColor
        card.layer?.borderColor = NSColor(white: 1.0, alpha: 0.08).cgColor
        card.layer?.borderWidth = 1.0
        card.layer?.cornerRadius = 6
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: height).isActive = true
        card.widthAnchor.constraint(equalToConstant: 700).isActive = true
        return card
    }
    
    // Exact Bloxstrap OptionControl (Header + Description on left, Control on right)
    private func createOptionControl(header: String, desc: String, control: NSView, height: CGFloat = 62) -> NSView {
        let card = createCardView(height: height)
        
        let t = NSTextField(labelWithString: header)
        t.font = .boldSystemFont(ofSize: 12)
        t.textColor = .white
        t.frame = NSRect(x: 14, y: height - 26, width: 440, height: 18)
        card.addSubview(t)
        
        let d = NSTextField(wrappingLabelWithString: desc)
        d.font = .systemFont(ofSize: 10.5)
        d.textColor = NSColor(calibratedRed: 0.70, green: 0.74, blue: 0.82, alpha: 1.0)
        d.frame = NSRect(x: 14, y: 8, width: 440, height: height - 32)
        d.autoresizingMask = [.width]
        card.addSubview(d)
        
        control.frame.origin.x = card.bounds.width - control.bounds.width - 16
        control.frame.origin.y = (height - control.bounds.height) / 2
        control.autoresizingMask = [.minXMargin]
        card.addSubview(control)
        
        return card
    }
    
    private func createSmallButton(title: String, frame: NSRect) -> NSButton {
        let btn = NSButton(frame: frame)
        btn.title = title
        btn.bezelStyle = .rounded
        btn.font = .systemFont(ofSize: 10.5)
        return btn
    }
}
