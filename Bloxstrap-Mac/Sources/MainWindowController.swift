import AppKit
import AVFoundation
@preconcurrency import WebKit

// MARK: - Windows 11 Fluent Toggle Switch
class FluentToggleSwitch: NSControl {
    var isOn: Bool = false {
        didSet {
            needsDisplay = true
            sendAction(action, to: target)
        }
    }
    
    var onColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0) // Gold accent
    var offBorderColor = NSColor(calibratedWhite: 0.55, alpha: 1.0)
    var offThumbColor = NSColor(calibratedWhite: 0.85, alpha: 1.0)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: frameRect.origin.x, y: frameRect.origin.y, width: 44, height: 22))
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        let trackRect = NSRect(x: 1, y: 1, width: 42, height: 20)
        let corner = trackRect.height / 2
        let path = CGPath(roundedRect: trackRect, cornerWidth: corner, cornerHeight: corner, transform: nil)
        
        if isOn {
            ctx.setFillColor(onColor.cgColor)
            ctx.addPath(path)
            ctx.fillPath()
            
            // Thumb (right)
            ctx.setFillColor(NSColor.black.cgColor)
            let thumbRect = NSRect(x: trackRect.maxX - 16, y: trackRect.minY + 2, width: 14, height: 16)
            let thumbPath = CGPath(roundedRect: thumbRect, cornerWidth: 7, cornerHeight: 7, transform: nil)
            ctx.addPath(thumbPath)
            ctx.fillPath()
        } else {
            ctx.setStrokeColor(offBorderColor.cgColor)
            ctx.setLineWidth(1.5)
            ctx.addPath(path)
            ctx.strokePath()
            
            // Thumb (left)
            ctx.setFillColor(offThumbColor.cgColor)
            let thumbRect = NSRect(x: trackRect.minX + 3, y: trackRect.minY + 3, width: 14, height: 14)
            let thumbPath = CGPath(roundedRect: thumbRect, cornerWidth: 7, cornerHeight: 7, transform: nil)
            ctx.addPath(thumbPath)
            ctx.fillPath()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        isOn.toggle()
    }
}

// MARK: - Flipped Container for Natural Scrolling
class FlippedContainerView: NSView {
    override var isFlipped: Bool { return true }
}

// MARK: - Main Bloxstrap Window Controller (Exact 1:1 Parity)
public class MainWindowController: NSWindowController, WKNavigationDelegate, NSTextFieldDelegate {
    
    // Core Navigation & Pages
    private var sidebarView: NSView!
    private var sidebarButtons: [NSButton] = []
    private var activeIndicators: [NSView] = []
    private var contentContainer: NSView!
    private var tabViews: [NSView] = []
    private var currentTabIndex: Int = 2 // Default to FastFlags (matching screenshot)
    
    // Key Gate Overlay
    private var keyGateOverlay: NSView!
    private var keyGateInputField: NSTextField!
    private var keyGateTierLabel: NSTextField!
    private var keyGateErrorLabel: NSTextField!
    
    // Status Bar & Controls
    private var statusBarView: NSView!
    private var toastLabel: NSTextField!
    private var tierHeaderBadge: NSTextField!
    
    // Dynamic Fields for FastFlags & Mods
    private var fpsInputField: NSTextField!
    private var lightingPopup: NSPopUpButton!
    private var escapeMenuPopup: NSPopUpButton!
    private var hideGuisSwitch: FluentToggleSwitch!
    private var renderingModePopup: NSPopUpButton!
    private var exclusiveFullscreenSwitch: FluentToggleSwitch!
    private var altQualitySwitch: FluentToggleSwitch!
    private var inGameMenuPopup: NSPopUpButton!
    private var disableFsoSwitch: FluentToggleSwitch!
    private var deathSoundSwitch: FluentToggleSwitch!
    
    // Accounts Manager Table View
    private var accountsStackView: NSStackView!
    private var multiInstanceStatusLabel: NSTextField!
    private var instancesStackView: NSStackView!
    private var instanceTimer: Timer?
    
    private let pageNames: [String] = [
        "Integrations",
        "Mods",
        "FastFlags",
        "Appearance",
        "Behaviour",
        "Bloxstrap Gold",
        "About"
    ]
    
    private let pageIcons: [String] = [
        "＋",
        "🔧",
        "⚐",
        "🖥",
        "⚙",
        "👑",
        "❓"
    ]
    
    public init() {
        let window = NSWindow(
            contentRect: NSRect(x: 120, y: 100, width: 1000, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Bloxstrap Menu"
        window.backgroundColor = NSColor(calibratedRed: 0.114, green: 0.114, blue: 0.125, alpha: 1.0) // Authentic Windows Mica dark
        window.minSize = NSSize(width: 960, height: 560)
        
        super.init(window: window)
        setupUI()
        
        // Polling timer for active instances
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
    
    private func setupUI() {
        guard let contentView = window?.contentView else { return }
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor(calibratedRed: 0.114, green: 0.114, blue: 0.125, alpha: 1.0).cgColor
        
        let bounds = contentView.bounds
        
        // 1. Bottom Status Bar (Flush with bottom, height: 52px)
        setupBottomStatusBar(bounds: bounds)
        
        // 2. Left Sidebar (Width: 200px)
        let mainHeight = bounds.height - 52
        sidebarView = NSView(frame: NSRect(x: 0, y: 52, width: 210, height: mainHeight))
        sidebarView.wantsLayer = true
        sidebarView.layer?.backgroundColor = NSColor(calibratedRed: 0.098, green: 0.098, blue: 0.106, alpha: 0.95).cgColor
        sidebarView.autoresizingMask = [.height, .maxXMargin]
        contentView.addSubview(sidebarView)
        setupSidebar()
        
        // 3. Right Content Container
        contentContainer = NSView(frame: NSRect(x: 210, y: 52, width: bounds.width - 210, height: mainHeight))
        contentContainer.wantsLayer = true
        contentContainer.layer?.backgroundColor = NSColor(calibratedRed: 0.114, green: 0.114, blue: 0.125, alpha: 1.0).cgColor
        contentContainer.autoresizingMask = [.width, .height]
        contentView.addSubview(contentContainer)
        
        // Build all 7 authentic Bloxstrap pages
        tabViews = [
            buildIntegrationsPage(bounds: contentContainer.bounds),
            buildModsPage(bounds: contentContainer.bounds),
            buildFastFlagsPage(bounds: contentContainer.bounds),
            buildAppearancePage(bounds: contentContainer.bounds),
            buildBehaviourPage(bounds: contentContainer.bounds),
            buildGoldPage(bounds: contentContainer.bounds),
            buildAboutPage(bounds: contentContainer.bounds)
        ]
        
        for tab in tabViews {
            tab.autoresizingMask = [.width, .height]
            tab.isHidden = true
            contentContainer.addSubview(tab)
        }
        
        // Select initial tab (FastFlags to match user's screenshot)
        selectTab(index: 2)
        
        // 4. Key Gate Modal Overlay (Displayed if unauthenticated)
        setupKeyGateOverlay(bounds: bounds)
        updateAuthenticationState()
    }
    
    // MARK: - Key Gate Modal (Starts with GOLD-7DAY-)
    private func setupKeyGateOverlay(bounds: NSRect) {
        guard let contentView = window?.contentView else { return }
        
        keyGateOverlay = NSView(frame: bounds)
        keyGateOverlay.wantsLayer = true
        keyGateOverlay.layer?.backgroundColor = NSColor(calibratedRed: 0.07, green: 0.07, blue: 0.08, alpha: 0.98).cgColor
        keyGateOverlay.autoresizingMask = [.width, .height]
        
        // Dialog Card
        let cardW: CGFloat = 520
        let cardH: CGFloat = 360
        let card = NSView(frame: NSRect(x: (bounds.width - cardW) / 2, y: (bounds.height - cardH) / 2, width: cardW, height: cardH))
        card.wantsLayer = true
        card.layer?.backgroundColor = NSColor(calibratedRed: 0.14, green: 0.14, blue: 0.16, alpha: 1.0).cgColor
        card.layer?.borderColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 0.4).cgColor
        card.layer?.borderWidth = 1.5
        card.layer?.cornerRadius = 8
        card.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        keyGateOverlay.addSubview(card)
        
        let crown = NSTextField(labelWithString: "👑")
        crown.font = .systemFont(ofSize: 42)
        crown.frame = NSRect(x: (cardW - 50) / 2, y: cardH - 68, width: 50, height: 50)
        card.addSubview(crown)
        
        let title = NSTextField(labelWithString: "Bloxstrap Gold Activation")
        title.font = .boldSystemFont(ofSize: 18)
        title.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        title.alignment = .center
        title.frame = NSRect(x: 20, y: cardH - 105, width: cardW - 40, height: 24)
        card.addSubview(title)
        
        let desc = NSTextField(labelWithString: "Enter your license key to unlock Bloxstrap Gold.\nKeys must start with GOLD-7DAY- (e.g. GOLD-7DAY-ULTRA-XXXX-XXXX).")
        desc.font = .systemFont(ofSize: 12)
        desc.textColor = NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.82, alpha: 1.0)
        desc.alignment = .center
        desc.frame = NSRect(x: 20, y: cardH - 150, width: cardW - 40, height: 32)
        card.addSubview(desc)
        
        // Input Box
        keyGateInputField = NSTextField(frame: NSRect(x: 40, y: cardH - 195, width: cardW - 80, height: 34))
        keyGateInputField.placeholderString = "GOLD-7DAY-ULTRA-XXXX-XXXX-XXXX"
        keyGateInputField.font = .monospacedSystemFont(ofSize: 12, weight: .bold)
        keyGateInputField.textColor = .white
        keyGateInputField.wantsLayer = true
        keyGateInputField.layer?.backgroundColor = NSColor(calibratedRed: 0.09, green: 0.09, blue: 0.11, alpha: 1.0).cgColor
        keyGateInputField.layer?.cornerRadius = 4
        keyGateInputField.delegate = self
        card.addSubview(keyGateInputField)
        
        // Live Tier Detection Label
        keyGateTierLabel = NSTextField(labelWithString: "🔑 Enter a valid key to detect your tier")
        keyGateTierLabel.font = .boldSystemFont(ofSize: 11.5)
        keyGateTierLabel.textColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0)
        keyGateTierLabel.alignment = .center
        keyGateTierLabel.frame = NSRect(x: 20, y: cardH - 225, width: cardW - 40, height: 18)
        card.addSubview(keyGateTierLabel)
        
        keyGateErrorLabel = NSTextField(labelWithString: "")
        keyGateErrorLabel.font = .systemFont(ofSize: 11)
        keyGateErrorLabel.textColor = NSColor(calibratedRed: 0.95, green: 0.35, blue: 0.35, alpha: 1.0)
        keyGateErrorLabel.alignment = .center
        keyGateErrorLabel.frame = NSRect(x: 20, y: cardH - 245, width: cardW - 40, height: 18)
        card.addSubview(keyGateErrorLabel)
        
        // Unlock Button
        let unlockBtn = NSButton(frame: NSRect(x: 40, y: 45, width: cardW - 80, height: 36))
        unlockBtn.title = "Unlock Bloxstrap Gold"
        unlockBtn.bezelStyle = .rounded
        unlockBtn.font = .boldSystemFont(ofSize: 13)
        unlockBtn.wantsLayer = true
        unlockBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0).cgColor
        unlockBtn.contentTintColor = .black
        unlockBtn.target = self
        unlockBtn.action = #selector(onActivateKeyClicked)
        card.addSubview(unlockBtn)
        
        let buyBtn = NSButton(frame: NSRect(x: 40, y: 12, width: cardW - 80, height: 26))
        buyBtn.title = "🛒 Get a key at bloxstrapgold.github.io"
        buyBtn.isBordered = false
        buyBtn.font = .systemFont(ofSize: 11, weight: .semibold)
        buyBtn.contentTintColor = NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.85, alpha: 1.0)
        buyBtn.target = self
        buyBtn.action = #selector(onOpenStore)
        card.addSubview(buyBtn)
        
        contentView.addSubview(keyGateOverlay)
    }
    
    public func controlTextDidChange(_ obj: Notification) {
        guard let field = obj.object as? NSTextField, field == keyGateInputField else { return }
        let text = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if text.hasPrefix("GOLD-7DAY-") {
            let detected = AppState.shared.detectTier(from: text)
            keyGateTierLabel.stringValue = "✨ Detected: \(detected)"
            keyGateErrorLabel.stringValue = ""
        } else if !text.isEmpty {
            keyGateTierLabel.stringValue = "⚠️ Key must begin with GOLD-7DAY-"
        } else {
            keyGateTierLabel.stringValue = "🔑 Enter a valid key to detect your tier"
        }
    }
    
    @objc private func onActivateKeyClicked() {
        let key = keyGateInputField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if AppState.shared.verifyAndApplyKey(key) {
            updateAuthenticationState()
            showToast("✓ Activated: \(AppState.shared.currentTierName)")
        } else {
            keyGateErrorLabel.stringValue = "Invalid Key! Must start with GOLD-7DAY- (e.g. GOLD-7DAY-ULTRA-...)"
        }
    }
    
    private func updateAuthenticationState() {
        let auth = AppState.shared.isAuthenticated
        keyGateOverlay.isHidden = auth
        if auth {
            tierHeaderBadge?.stringValue = AppState.shared.currentTierBadge
            tierHeaderBadge?.isHidden = false
        }
    }
    
    // Deep Link protocol handler: bloxstrap-gold://activate?key={KEY}
    public func handleDeepLinkActivation(key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if AppState.shared.verifyAndApplyKey(trimmed) {
            updateAuthenticationState()
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            showToast("✓ Protocol Activated: \(AppState.shared.currentTierName)")
        }
    }
    
    // MARK: - Sidebar Setup (Exact Bloxstrap NavigationFluent)
    private func setupSidebar() {
        sidebarButtons.removeAll()
        activeIndicators.removeAll()
        sidebarView.subviews.forEach { $0.removeFromSuperview() }
        
        let startY: CGFloat = sidebarView.bounds.height - 42
        for (i, name) in pageNames.enumerated() {
            let y = startY - CGFloat(i * 38)
            let row = NSView(frame: NSRect(x: 4, y: y, width: sidebarView.bounds.width - 8, height: 34))
            row.autoresizingMask = [.width, .minYMargin]
            
            // Left active pill indicator
            let indicator = NSView(frame: NSRect(x: 0, y: 7, width: 3, height: 20))
            indicator.wantsLayer = true
            indicator.layer?.backgroundColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0).cgColor
            indicator.layer?.cornerRadius = 1.5
            indicator.isHidden = (i != currentTabIndex)
            row.addSubview(indicator)
            activeIndicators.append(indicator)
            
            let btn = NSButton(frame: NSRect(x: 6, y: 0, width: row.bounds.width - 6, height: 34))
            btn.title = "  \(pageIcons[i])   \(name)"
            btn.alignment = .left
            btn.isBordered = false
            btn.font = .systemFont(ofSize: 13, weight: .medium)
            btn.wantsLayer = true
            btn.layer?.cornerRadius = 5
            btn.tag = i
            btn.target = self
            btn.action = #selector(onSidebarTabClicked(_:))
            btn.autoresizingMask = [.width]
            row.addSubview(btn)
            sidebarButtons.append(btn)
            
            sidebarView.addSubview(row)
        }
    }
    
    @objc private func onSidebarTabClicked(_ sender: NSButton) {
        selectTab(index: sender.tag)
    }
    
    @objc public func showAboutTab() {
        selectTab(index: 6)
    }
    
    private func selectTab(index: Int) {
        currentTabIndex = index
        for (i, btn) in sidebarButtons.enumerated() {
            let isSelected = (i == index)
            btn.layer?.backgroundColor = isSelected ? NSColor(calibratedRed: 0.17, green: 0.17, blue: 0.19, alpha: 1.0).cgColor : NSColor.clear.cgColor
            btn.contentTintColor = isSelected ? .white : NSColor(calibratedRed: 0.78, green: 0.78, blue: 0.84, alpha: 1.0)
            activeIndicators[i].isHidden = !isSelected
        }
        for (i, v) in tabViews.enumerated() {
            v.isHidden = (i != index)
        }
        if index == 5 {
            updateInstanceList()
        }
    }
    
    // MARK: - Bottom Status Bar (Save & Cancel buttons)
    private func setupBottomStatusBar(bounds: NSRect) {
        guard let contentView = window?.contentView else { return }
        
        statusBarView = NSView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: 52))
        statusBarView.wantsLayer = true
        statusBarView.layer?.backgroundColor = NSColor(calibratedRed: 0.10, green: 0.10, blue: 0.11, alpha: 0.98).cgColor
        statusBarView.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.06).cgColor
        statusBarView.layer?.borderWidth = 1.0
        statusBarView.autoresizingMask = [.width, .maxYMargin]
        contentView.addSubview(statusBarView)
        
        // Left: Roblox Status Indicator
        let isInstalled = MultiInstanceManager.shared.isRobloxInstalled
        let dot = NSTextField(labelWithString: isInstalled ? "🟢" : "🟡")
        dot.font = .systemFont(ofSize: 10)
        dot.frame = NSRect(x: 16, y: 18, width: 16, height: 16)
        statusBarView.addSubview(dot)
        
        let statusLbl = NSTextField(labelWithString: isInstalled ? "Roblox.app Detected" : "Roblox Not Installed")
        statusLbl.font = .systemFont(ofSize: 12, weight: .medium)
        statusLbl.textColor = isInstalled ? NSColor(calibratedRed: 0.18, green: 0.80, blue: 0.44, alpha: 1.0) : .systemYellow
        statusLbl.frame = NSRect(x: 36, y: 17, width: 180, height: 18)
        statusBarView.addSubview(statusLbl)
        
        // Tier Badge in Bottom Bar
        tierHeaderBadge = NSTextField(labelWithString: AppState.shared.currentTierBadge)
        tierHeaderBadge.font = .boldSystemFont(ofSize: 10.5)
        tierHeaderBadge.alignment = .center
        tierHeaderBadge.textColor = .black
        tierHeaderBadge.wantsLayer = true
        tierHeaderBadge.layer?.backgroundColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0).cgColor
        tierHeaderBadge.layer?.cornerRadius = 3
        tierHeaderBadge.frame = NSRect(x: 230, y: 16, width: 120, height: 20)
        statusBarView.addSubview(tierHeaderBadge)
        
        // Toast message
        toastLabel = NSTextField(labelWithString: "")
        toastLabel.font = .boldSystemFont(ofSize: 11.5)
        toastLabel.textColor = NSColor(calibratedRed: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        toastLabel.frame = NSRect(x: 360, y: 17, width: 260, height: 18)
        toastLabel.isHidden = true
        statusBarView.addSubview(toastLabel)
        
        // Right: [ Save ] (Gold primary) and [ Cancel ]
        let cancelBtn = NSButton(frame: NSRect(x: statusBarView.bounds.width - 95, y: 11, width: 80, height: 30))
        cancelBtn.title = "Cancel"
        cancelBtn.bezelStyle = .rounded
        cancelBtn.font = .systemFont(ofSize: 12)
        cancelBtn.target = self
        cancelBtn.action = #selector(onCloseClicked)
        cancelBtn.autoresizingMask = [.minXMargin]
        statusBarView.addSubview(cancelBtn)
        
        let saveBtn = NSButton(frame: NSRect(x: statusBarView.bounds.width - 185, y: 11, width: 80, height: 30))
        saveBtn.title = "Save"
        saveBtn.bezelStyle = .rounded
        saveBtn.font = .boldSystemFont(ofSize: 12)
        saveBtn.wantsLayer = true
        saveBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0).cgColor
        saveBtn.contentTintColor = .black
        saveBtn.target = self
        saveBtn.action = #selector(onSaveClicked)
        saveBtn.autoresizingMask = [.minXMargin]
        statusBarView.addSubview(saveBtn)
    }
    
    @objc private func onSaveClicked() {
        // Save current UI state
        if let fpsVal = Int(fpsInputField.stringValue) {
            AppState.shared.data.targetFps = fpsVal
            FastFlagManager.shared.setFlag(key: "DFIntTaskSchedulerTargetFps", value: fpsVal)
        }
        AppState.shared.data.preferredLighting = lightingPopup.titleOfSelectedItem ?? "Future (Phase 3)"
        AppState.shared.data.escapeMenuVersion = escapeMenuPopup.titleOfSelectedItem ?? "Version 4 (2023)"
        AppState.shared.data.hideGuisEnabled = hideGuisSwitch.isOn
        AppState.shared.data.renderingMode = renderingModePopup.titleOfSelectedItem ?? "Direct3D 11"
        AppState.shared.data.exclusiveFullscreen = exclusiveFullscreenSwitch.isOn
        AppState.shared.data.alternateQualitySelector = altQualitySwitch.isOn
        AppState.shared.data.inGameMenuVersion = inGameMenuPopup.titleOfSelectedItem ?? "Version 3 (2021)"
        AppState.shared.data.disableFullscreenOptimizations = disableFsoSwitch.isOn
        AppState.shared.save()
        
        showToast("✓ Settings saved!")
    }
    
    @objc private func onCloseClicked() {
        window?.performClose(nil)
    }
    
    private func showToast(_ msg: String) {
        toastLabel.stringValue = msg
        toastLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.toastLabel.isHidden = true
        }
    }
    
    // MARK: - PAGE 1: FASTFLAGS (EXACT REPLICA OF SCREENSHOT 1)
    private func buildFastFlagsPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        
        let title = createPageHeader(title: "FastFlags", subtitle: "Control how specific Roblox engine parameters and features are configured.")
        stack.addArrangedSubview(title)
        
        // Two Action Cards: [ FastFlag Editor > ]  [ Help > ]
        let cardRow = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 56))
        cardRow.translatesAutoresizingMaskIntoConstraints = false
        cardRow.heightAnchor.constraint(equalToConstant: 56).isActive = true
        cardRow.widthAnchor.constraint(equalToConstant: 720).isActive = true
        
        let card1 = createCardAction(frame: NSRect(x: 0, y: 0, width: 352, height: 56), icon: "⚡", title: "FastFlag Editor", desc: "Manage your own FastFlags.", action: #selector(onOpenFastFlagEditor))
        let card2 = createCardAction(frame: NSRect(x: 368, y: 0, width: 352, height: 56), icon: "❓", title: "Help", desc: "Learn more about FastFlags.", action: #selector(onOpenFastFlagHelp))
        cardRow.addSubview(card1)
        cardRow.addSubview(card2)
        stack.addArrangedSubview(cardRow)
        
        // Section: Presets
        let presetHeader = createSectionHeader("Presets")
        stack.addArrangedSubview(presetHeader)
        
        let presetSub = createSubtitleLabel("FastFlags for Direct3D exclusive fullscreen (Alt+Enter) and DPI scaling fixes are already enabled by default.")
        stack.addArrangedSubview(presetSub)
        
        // Option 1: Framerate limit ⓘ
        fpsInputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 140, height: 28))
        fpsInputField.stringValue = "\(AppState.shared.data.targetFps)"
        fpsInputField.font = .monospacedSystemFont(ofSize: 12, weight: .bold)
        fpsInputField.textColor = .white
        fpsInputField.wantsLayer = true
        fpsInputField.layer?.backgroundColor = NSColor(calibratedRed: 0.13, green: 0.13, blue: 0.15, alpha: 1.0).cgColor
        fpsInputField.layer?.cornerRadius = 4
        let optFps = createOptionControl(header: "Framerate limit ⓘ", desc: "Use a large number like 9999 for no limit. Set as 0 for defaults.", control: fpsInputField)
        stack.addArrangedSubview(optFps)
        
        // Option 2: Preferred lighting technology
        lightingPopup = createStyledPopup(items: ["Chosen by game", "Compatibility (Phase 1)", "ShadowMap (Phase 2)", "Future (Phase 3)"], selected: AppState.shared.data.preferredLighting)
        let optLight = createOptionControl(header: "Preferred lighting technology", desc: "Choose which lighting technology should be forced enabled in all games.", control: lightingPopup)
        stack.addArrangedSubview(optLight)
        
        // Option 3: Preferred escape menu version ⓘ
        escapeMenuPopup = createStyledPopup(items: ["Default", "Version 1 (2015)", "Version 2 (2020)", "Version 4 (2023)"], selected: AppState.shared.data.escapeMenuVersion)
        let optEsc = createOptionControl(header: "Preferred escape menu version ⓘ", desc: "Choose which version of the escape menu to use.", control: escapeMenuPopup)
        stack.addArrangedSubview(optEsc)
        
        // Option 4: Enable ability to hide GUIs ⓘ
        hideGuisSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        hideGuisSwitch.isOn = AppState.shared.data.hideGuisEnabled
        let optHide = createOptionControl(header: "Enable ability to hide GUIs ⓘ", desc: "Toggled with keyboard shortcuts. Only works if you're in the Bloxstrap group.", control: hideGuisSwitch)
        stack.addArrangedSubview(optHide)
        
        return scrollView
    }
    
    // MARK: - PAGE 2: MODS (EXACT REPLICA OF SCREENSHOT 2)
    private func buildModsPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        
        let title = createPageHeader(title: "Mods", subtitle: "Manage game rendering, custom assets, and mouse controls.")
        stack.addArrangedSubview(title)
        
        // Option 1: Rendering mode
        renderingModePopup = createStyledPopup(items: ["Direct3D 11", "Vulkan / MoltenVK", "Metal (macOS Default)", "OpenGL"], selected: AppState.shared.data.renderingMode)
        let optRen = createOptionControl(header: "Rendering mode", desc: "Select which renderer Roblox should use. ReShade requires Direct3D 11.", control: renderingModePopup)
        stack.addArrangedSubview(optRen)
        
        // Option 2: Use exclusive fullscreen
        exclusiveFullscreenSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        exclusiveFullscreenSwitch.isOn = AppState.shared.data.exclusiveFullscreen
        let optFull = createOptionControl(header: "Use exclusive fullscreen", desc: "Enables using Alt + Enter to enter exclusive fullscreen. Only works with Direct3D 11.", control: exclusiveFullscreenSwitch)
        stack.addArrangedSubview(optFull)
        
        // Option 3: Use alternate graphics quality selector
        altQualitySwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        altQualitySwitch.isOn = AppState.shared.data.alternateQualitySelector
        let optAlt = createOptionControl(header: "Use alternate graphics quality selector", desc: "Toggle between using the consolidated 1-10 / fine-grained 1-21 graphics quality slider.", control: altQualitySwitch)
        stack.addArrangedSubview(optAlt)
        
        // Option 4: In-game menu version
        inGameMenuPopup = createStyledPopup(items: ["Default", "Version 1 (2015)", "Version 2 (2020)", "Version 3 (2021)"], selected: AppState.shared.data.inGameMenuVersion)
        let optMenu = createOptionControl(header: "In-game menu version", desc: "Choose which version of the in-game menu to use. Current default is v1.", control: inGameMenuPopup)
        stack.addArrangedSubview(optMenu)
        
        // Section: Miscellaneous
        let miscHeader = createSectionHeader("Miscellaneous")
        stack.addArrangedSubview(miscHeader)
        
        // Option 5: Disable full-screen optimizations
        disableFsoSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        disableFsoSwitch.isOn = AppState.shared.data.disableFullscreenOptimizations
        let optFso = createOptionControl(header: "Disable full-screen optimizations", desc: "A Windows feature that can potentially cause problems - click here for more info.", control: disableFsoSwitch)
        stack.addArrangedSubview(optFso)
        
        // Option 6: Restore 2006 Death Sound
        deathSoundSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        deathSoundSwitch.isOn = AppState.shared.data.customDeathSound
        deathSoundSwitch.target = self
        deathSoundSwitch.action = #selector(onDeathSoundToggled)
        let optSound = createOptionControl(header: "Classic 2006 \"OOF\" death sound", desc: "Restores the nostalgic sound and backs up default Roblox audio.", control: deathSoundSwitch)
        stack.addArrangedSubview(optSound)
        
        return scrollView
    }
    
    @objc private func onDeathSoundToggled() {
        if deathSoundSwitch.isOn {
            _ = SoundManager.shared.installOofIntoRoblox()
            SoundManager.shared.playPreview()
            showToast("✓ Classic OOF Sound Installed")
        } else {
            _ = SoundManager.shared.restoreOriginalSound()
            showToast("↺ Restored default sound")
        }
    }
    
    // MARK: - PAGE 3: ABOUT (EXACT REPLICA OF SCREENSHOT 3)
    private func buildAboutPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        
        let title = createPageHeader(title: "About", subtitle: "")
        stack.addArrangedSubview(title)
        
        // Header Block with Logo & Info
        let heroCard = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 110))
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.heightAnchor.constraint(equalToConstant: 110).isActive = true
        heroCard.widthAnchor.constraint(equalToConstant: 720).isActive = true
        
        let logo = NSTextField(labelWithString: "⬚⬚\n⬚⬚")
        logo.font = .systemFont(ofSize: 24, weight: .black)
        logo.textColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0)
        logo.frame = NSRect(x: 0, y: 35, width: 45, height: 50)
        heroCard.addSubview(logo)
        
        let appName = NSTextField(labelWithString: "Bloxstrap  Version 2.11.4")
        appName.font = .boldSystemFont(ofSize: 18)
        appName.textColor = .white
        appName.frame = NSRect(x: 55, y: 64, width: 400, height: 24)
        heroCard.addSubview(appName)
        
        let appDesc = NSTextField(labelWithString: "An open-source, feature-packed alternative bootstrapper for Roblox\nDeveloped by pizzaboxer - if you like this, please consider leaving a star on GitHub.")
        appDesc.font = .systemFont(ofSize: 12)
        appDesc.textColor = NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.82, alpha: 1.0)
        appDesc.frame = NSRect(x: 55, y: 22, width: 620, height: 36)
        heroCard.addSubview(appDesc)
        
        stack.addArrangedSubview(heroCard)
        
        // Action Pills Row: [ GitHub repository ]  [ Report an issue ]  [ Help topics ]
        let pillsRow = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 36))
        pillsRow.translatesAutoresizingMaskIntoConstraints = false
        pillsRow.heightAnchor.constraint(equalToConstant: 36).isActive = true
        pillsRow.widthAnchor.constraint(equalToConstant: 720).isActive = true
        
        let p1 = createActionPill(frame: NSRect(x: 0, y: 2, width: 165, height: 30), icon: "</>", title: "GitHub repository", url: "https://github.com/Bloxstrap-Gold/Bloxstrap-Gold")
        let p2 = createActionPill(frame: NSRect(x: 175, y: 2, width: 145, height: 30), icon: "🗩", title: "Report an issue", url: "https://github.com/Bloxstrap-Gold/Bloxstrap-Gold/issues")
        let p3 = createActionPill(frame: NSRect(x: 330, y: 2, width: 125, height: 30), icon: "🕮", title: "Help topics", url: "https://bloxstrapgold.github.io")
        pillsRow.addSubview(p1)
        pillsRow.addSubview(p2)
        pillsRow.addSubview(p3)
        stack.addArrangedSubview(pillsRow)
        
        // Section: Contributors
        let contribHeader = createSectionHeader("Contributors")
        stack.addArrangedSubview(contribHeader)
        
        let contribSub = createSubtitleLabel("These are the people who have made notable contributions to Bloxstrap, helping make it what it is today.")
        stack.addArrangedSubview(contribSub)
        
        let contributors: [(name: String, desc: String)] = [
            ("Multako", "Designing the Bloxstrap logo"),
            ("bluepilledgreat", "Helping with bootstrapper functionality and UX"),
            ("1011025m", "Providing a method for disabling the Roblox desktop app"),
            ("sitiom", "Setting up GitHub CI workflows and Winget releases"),
            ("taskmanager", "Helping with designing the new menu look and layout"),
            ("Extravi", "Allowing their presets to be bundled with Bloxstrap, and helping...")
        ]
        
        for c in contributors {
            let row = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 26))
            row.translatesAutoresizingMaskIntoConstraints = false
            row.heightAnchor.constraint(equalToConstant: 26).isActive = true
            row.widthAnchor.constraint(equalToConstant: 720).isActive = true
            
            let n = NSTextField(labelWithString: c.name)
            n.font = .systemFont(ofSize: 12.5, weight: .semibold)
            n.textColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0)
            n.frame = NSRect(x: 4, y: 4, width: 160, height: 18)
            row.addSubview(n)
            
            let d = NSTextField(labelWithString: c.desc)
            d.font = .systemFont(ofSize: 12)
            d.textColor = NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.82, alpha: 1.0)
            d.frame = NSRect(x: 170, y: 4, width: 540, height: 18)
            row.addSubview(d)
            
            stack.addArrangedSubview(row)
        }
        
        // Section: Licenses
        let licHeader = createSectionHeader("Licenses")
        stack.addArrangedSubview(licHeader)
        let licDesc = createSubtitleLabel("Bloxstrap Gold is distributed under the GNU General Public License v3.0 (GPL-3.0). Free forever.")
        stack.addArrangedSubview(licDesc)
        
        return scrollView
    }
    
    // MARK: - PAGE 4: BLOXSTRAP GOLD (VIP TIER & MULTI-INSTANCE OVERLAY)
    private func buildGoldPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        
        let title = createPageHeader(title: "Bloxstrap Gold", subtitle: "Active Tier License, Multi-Instance Manager, and Account Profiles.")
        stack.addArrangedSubview(title)
        
        // Tier Status Card
        let statusCard = createOptionCard(height: 95)
        let t1 = NSTextField(labelWithString: "👑 ACTIVE LICENSE: \(AppState.shared.currentTierName.uppercased())")
        t1.font = .boldSystemFont(ofSize: 14)
        t1.textColor = NSColor(calibratedRed: 0.988, green: 0.878, blue: 0.608, alpha: 1.0)
        t1.frame = NSRect(x: 16, y: 60, width: 450, height: 20)
        statusCard.addSubview(t1)
        
        let t2 = NSTextField(labelWithString: "Key: \(AppState.shared.data.vipKey ?? "None") • Price: \(AppState.shared.currentTierPrice)")
        t2.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        t2.textColor = NSColor(calibratedRed: 0.75, green: 0.78, blue: 0.85, alpha: 1.0)
        t2.frame = NSRect(x: 16, y: 36, width: 450, height: 18)
        statusCard.addSubview(t2)
        
        let changeKeyBtn = NSButton(frame: NSRect(x: 16, y: 8, width: 140, height: 24))
        changeKeyBtn.title = "🔑 Change License Key"
        changeKeyBtn.bezelStyle = .rounded
        changeKeyBtn.font = .systemFont(ofSize: 10.5)
        changeKeyBtn.target = self
        changeKeyBtn.action = #selector(onChangeKeyClicked)
        statusCard.addSubview(changeKeyBtn)
        
        let webBtn = NSButton(frame: NSRect(x: 165, y: 8, width: 175, height: 24))
        webBtn.title = "🌐 Visit bloxstrapgold.github.io"
        webBtn.bezelStyle = .rounded
        webBtn.font = .systemFont(ofSize: 10.5)
        webBtn.target = self
        webBtn.action = #selector(onOpenStore)
        statusCard.addSubview(webBtn)
        
        stack.addArrangedSubview(statusCard)
        
        // Multi-Instance Manager
        let multiHeader = createSectionHeader("Multi-Instance Roblox")
        stack.addArrangedSubview(multiHeader)
        
        let multiCard = createOptionCard(height: 155)
        multiInstanceStatusLabel = NSTextField(labelWithString: "Active Instances: 0 running")
        multiInstanceStatusLabel.font = .boldSystemFont(ofSize: 12)
        multiInstanceStatusLabel.textColor = .white
        multiInstanceStatusLabel.frame = NSRect(x: 16, y: 122, width: 300, height: 18)
        multiCard.addSubview(multiInstanceStatusLabel)
        
        let launchBtn = NSButton(frame: NSRect(x: 16, y: 12, width: 190, height: 32))
        launchBtn.title = "🚀 Launch Extra Instance"
        launchBtn.bezelStyle = .rounded
        launchBtn.font = .boldSystemFont(ofSize: 11.5)
        launchBtn.wantsLayer = true
        launchBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0).cgColor
        launchBtn.contentTintColor = .black
        launchBtn.target = self
        launchBtn.action = #selector(onLaunchInstance)
        multiCard.addSubview(launchBtn)
        
        let killBtn = NSButton(frame: NSRect(x: 215, y: 12, width: 150, height: 32))
        killBtn.title = "🛑 Close All Instances"
        killBtn.bezelStyle = .rounded
        killBtn.font = .systemFont(ofSize: 11)
        killBtn.target = self
        killBtn.action = #selector(onTerminateAllInstances)
        multiCard.addSubview(killBtn)
        
        let pScroll = NSScrollView(frame: NSRect(x: 16, y: 52, width: 688, height: 60))
        pScroll.hasVerticalScroller = true
        pScroll.drawsBackground = false
        instancesStackView = NSStackView(frame: pScroll.bounds)
        instancesStackView.orientation = .vertical
        instancesStackView.alignment = .leading
        instancesStackView.spacing = 4
        pScroll.documentView = instancesStackView
        multiCard.addSubview(pScroll)
        
        stack.addArrangedSubview(multiCard)
        return scrollView
    }
    
    // MARK: - PAGE 5: INTEGRATIONS
    private func buildIntegrationsPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        let title = createPageHeader(title: "Integrations", subtitle: "Connect Roblox to Discord and external rich presence services.")
        stack.addArrangedSubview(title)
        
        let rpcSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        rpcSwitch.isOn = true
        let optRpc = createOptionControl(header: "Discord Rich Presence", desc: "Show game activity, server details, and your Bloxstrap Gold VIP tier on Discord.", control: rpcSwitch)
        stack.addArrangedSubview(optRpc)
        
        let locSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        locSwitch.isOn = true
        let optLoc = createOptionControl(header: "Show server location details", desc: "Display region and ping telemetry using server IP queries.", control: locSwitch)
        stack.addArrangedSubview(optLoc)
        return scrollView
    }
    
    // MARK: - PAGE 6: APPEARANCE
    private func buildAppearancePage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        let title = createPageHeader(title: "Appearance", subtitle: "Customize the look and feel of Bloxstrap.")
        stack.addArrangedSubview(title)
        
        let themePopup = createStyledPopup(items: ["Dark (Windows 11 Mica)", "Gold Edition", "Light"], selected: "Dark (Windows 11 Mica)")
        let optTheme = createOptionControl(header: "Theme", desc: "Change the visual theme of the Bloxstrap Menu.", control: themePopup)
        stack.addArrangedSubview(optTheme)
        
        let stylePopup = createStyledPopup(items: ["Fluent", "Classic Fluent", "Progress Bar", "Byfron"], selected: "Fluent")
        let optStyle = createOptionControl(header: "Bootstrapper style", desc: "Choose the style of dialog shown when Roblox starts.", control: stylePopup)
        stack.addArrangedSubview(optStyle)
        return scrollView
    }
    
    // MARK: - PAGE 7: BEHAVIOUR
    private func buildBehaviourPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        let title = createPageHeader(title: "Behaviour", subtitle: "Configure bootstrapper automation and update policies.")
        stack.addArrangedSubview(title)
        
        let updateSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        updateSwitch.isOn = true
        let optUpdate = createOptionControl(header: "Automatically check for updates", desc: "Periodically check for new releases of Bloxstrap Gold.", control: updateSwitch)
        stack.addArrangedSubview(optUpdate)
        
        let multiSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        multiSwitch.isOn = true
        let optMulti = createOptionControl(header: "Allow multi-instance launching", desc: "Permit running multiple Roblox clients simultaneously.", control: multiSwitch)
        stack.addArrangedSubview(optMulti)
        return scrollView
    }
    
    // MARK: - Helper UI Builders (Exact Bloxstrap Look & Feel)
    private func createScrollablePage(bounds: NSRect) -> (NSScrollView, NSStackView) {
        let scroll = NSScrollView(frame: bounds)
        scroll.autoresizingMask = [.width, .height]
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        
        let doc = FlippedContainerView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        doc.autoresizingMask = [.width]
        
        let stack = NSStackView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: 0))
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        doc.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: doc.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: doc.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: doc.trailingAnchor, constant: -28),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: doc.bottomAnchor, constant: -18)
        ])
        
        scroll.documentView = doc
        return (scroll, stack)
    }
    
    private func createPageHeader(title: String, subtitle: String) -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(equalToConstant: 720).isActive = true
        
        let t = NSTextField(labelWithString: title)
        t.font = .systemFont(ofSize: 26, weight: .bold)
        t.textColor = .white
        t.frame = NSRect(x: 0, y: subtitle.isEmpty ? 0 : 20, width: 720, height: 32)
        container.addSubview(t)
        
        if !subtitle.isEmpty {
            let s = NSTextField(labelWithString: subtitle)
            s.font = .systemFont(ofSize: 13)
            s.textColor = NSColor(calibratedRed: 0.65, green: 0.65, blue: 0.72, alpha: 1.0)
            s.frame = NSRect(x: 0, y: 0, width: 720, height: 18)
            container.addSubview(s)
            container.heightAnchor.constraint(equalToConstant: 54).isActive = true
        } else {
            container.heightAnchor.constraint(equalToConstant: 34).isActive = true
        }
        return container
    }
    
    private func createSectionHeader(_ text: String) -> NSTextField {
        let lbl = NSTextField(labelWithString: text)
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = .white
        return lbl
    }
    
    private func createSubtitleLabel(_ text: String) -> NSTextField {
        let lbl = NSTextField(wrappingLabelWithString: text)
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = NSColor(calibratedRed: 0.65, green: 0.65, blue: 0.72, alpha: 1.0)
        return lbl
    }
    
    // Exact Bloxstrap CardAction: [ Icon | Title + Subtitle | > ]
    private func createCardAction(frame: NSRect, icon: String, title: String, desc: String, action: Selector) -> NSButton {
        let btn = NSButton(frame: frame)
        btn.title = ""
        btn.isBordered = false
        btn.wantsLayer = true
        btn.layer?.backgroundColor = NSColor(calibratedRed: 0.145, green: 0.145, blue: 0.165, alpha: 1.0).cgColor
        btn.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.06).cgColor
        btn.layer?.borderWidth = 1.0
        btn.layer?.cornerRadius = 6
        btn.target = self
        btn.action = action
        
        let ic = NSTextField(labelWithString: icon)
        ic.font = .systemFont(ofSize: 18)
        ic.frame = NSRect(x: 12, y: 16, width: 24, height: 24)
        btn.addSubview(ic)
        
        let t = NSTextField(labelWithString: title)
        t.font = .boldSystemFont(ofSize: 13)
        t.textColor = .white
        t.frame = NSRect(x: 42, y: 28, width: 270, height: 18)
        btn.addSubview(t)
        
        let d = NSTextField(labelWithString: desc)
        d.font = .systemFont(ofSize: 11)
        d.textColor = NSColor(calibratedRed: 0.65, green: 0.65, blue: 0.72, alpha: 1.0)
        d.frame = NSRect(x: 42, y: 10, width: 270, height: 16)
        btn.addSubview(d)
        
        let chev = NSTextField(labelWithString: "›")
        chev.font = .systemFont(ofSize: 20, weight: .light)
        chev.textColor = NSColor(calibratedWhite: 0.5, alpha: 1.0)
        chev.frame = NSRect(x: frame.width - 24, y: 16, width: 16, height: 24)
        btn.addSubview(chev)
        
        return btn
    }
    
    // Exact Bloxstrap OptionControl Card (Header, Description on Left, Control on Right)
    private func createOptionControl(header: String, desc: String, control: NSView, height: CGFloat = 64) -> NSView {
        let card = createOptionCard(height: height)
        
        let t = NSTextField(labelWithString: header)
        t.font = .systemFont(ofSize: 13, weight: .semibold)
        t.textColor = .white
        t.frame = NSRect(x: 14, y: height - 26, width: 480, height: 18)
        card.addSubview(t)
        
        let d = NSTextField(wrappingLabelWithString: desc)
        d.font = .systemFont(ofSize: 11.5)
        d.textColor = NSColor(calibratedRed: 0.65, green: 0.65, blue: 0.72, alpha: 1.0)
        d.frame = NSRect(x: 14, y: 8, width: 480, height: height - 32)
        card.addSubview(d)
        
        control.frame.origin.x = card.bounds.width - control.bounds.width - 16
        control.frame.origin.y = (height - control.bounds.height) / 2
        control.autoresizingMask = [.minXMargin]
        card.addSubview(control)
        return card
    }
    
    private func createOptionCard(height: CGFloat) -> NSView {
        let card = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: height))
        card.wantsLayer = true
        card.layer?.backgroundColor = NSColor(calibratedRed: 0.145, green: 0.145, blue: 0.165, alpha: 1.0).cgColor
        card.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.06).cgColor
        card.layer?.borderWidth = 1.0
        card.layer?.cornerRadius = 6
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: height).isActive = true
        card.widthAnchor.constraint(equalToConstant: 720).isActive = true
        return card
    }
    
    private func createStyledPopup(items: [String], selected: String) -> NSPopUpButton {
        let popup = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 175, height: 28))
        popup.addItems(withTitles: items)
        if items.contains(selected) {
            popup.selectItem(withTitle: selected)
        }
        return popup
    }
    
    private func createActionPill(frame: NSRect, icon: String, title: String, url: String) -> NSButton {
        let btn = NSButton(frame: frame)
        btn.title = "  \(icon)  \(title)"
        btn.bezelStyle = .rounded
        btn.font = .systemFont(ofSize: 11.5, weight: .medium)
        btn.target = self
        btn.action = #selector(onActionPillClicked(_:))
        btn.toolTip = url
        return btn
    }
    
    @objc private func onActionPillClicked(_ sender: NSButton) {
        if let targetUrl = sender.toolTip, let u = URL(string: targetUrl) {
            NSWorkspace.shared.open(u)
        }
    }
    
    @objc private func onOpenFastFlagEditor() {
        let alert = NSAlert()
        alert.messageText = "FastFlag Editor"
        alert.informativeText = "Allowlisted FastFlags are configured directly in:\n~/Library/Application Support/Roblox/ClientSettings/ClientAppSettings.json"
        alert.addButton(withTitle: "Open Settings Folder")
        alert.addButton(withTitle: "Done")
        if alert.runModal() == .alertFirstButtonReturn {
            let folder = FastFlagManager.shared.clientSettingsURL.deletingLastPathComponent()
            NSWorkspace.shared.selectFile(FastFlagManager.shared.clientSettingsURL.path, inFileViewerRootedAtPath: folder.path)
        }
    }
    
    @objc private func onOpenFastFlagHelp() {
        if let url = URL(string: "https://bloxstraplabs.com/wiki/features/fastflags/") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func onOpenStore() {
        if let url = URL(string: "https://bloxstrapgold.github.io#pricing") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func onChangeKeyClicked() {
        AppState.shared.deauthenticate()
        updateAuthenticationState()
    }
    
    // MARK: - Multi-Instance Actions
    @objc private func onLaunchInstance() {
        let res = MultiInstanceManager.shared.launchNewInstance()
        showToast(res.success ? "✓ New Roblox Instance Launched" : "Launch Failed")
        updateInstanceList()
    }
    
    @objc private func onTerminateAllInstances() {
        _ = MultiInstanceManager.shared.terminateAllInstances()
        showToast("🛑 Closed all running clients")
        updateInstanceList()
    }
    
    private func updateInstanceList() {
        let pids = MultiInstanceManager.shared.getRunningInstances()
        multiInstanceStatusLabel?.stringValue = "Active Instances: \(pids.count) running"
        
        guard let stack = instancesStackView else { return }
        stack.subviews.forEach { $0.removeFromSuperview() }
        
        if pids.isEmpty {
            let empty = NSTextField(labelWithString: "🎮 No active Roblox processes. Click 'Launch Extra Instance' to start one.")
            empty.font = .systemFont(ofSize: 11)
            empty.textColor = .gray
            stack.addArrangedSubview(empty)
        } else {
            for (i, pid) in pids.enumerated() {
                let row = NSView(frame: NSRect(x: 0, y: 0, width: 660, height: 26))
                let dot = NSTextField(labelWithString: "🟢")
                dot.frame = NSRect(x: 4, y: 5, width: 16, height: 16)
                row.addSubview(dot)
                
                let l = NSTextField(labelWithString: "Client #\(i + 1) • PID: \(pid) • \(MultiInstanceManager.shared.getMemoryForPid(pid: pid)) MB RAM")
                l.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
                l.textColor = .white
                l.frame = NSRect(x: 24, y: 4, width: 350, height: 18)
                row.addSubview(l)
                
                let kBtn = NSButton(frame: NSRect(x: 580, y: 2, width: 65, height: 22))
                kBtn.title = "Kill"
                kBtn.bezelStyle = .inline
                kBtn.tag = pid
                kBtn.target = self
                kBtn.action = #selector(onKillSingleInstance(_:))
                row.addSubview(kBtn)
                
                stack.addArrangedSubview(row)
            }
        }
    }
    
    @objc private func onKillSingleInstance(_ sender: NSButton) {
        kill(pid_t(sender.tag), SIGTERM)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updateInstanceList()
        }
    }
}
