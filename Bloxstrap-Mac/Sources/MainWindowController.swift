import AppKit
import AVFoundation
@preconcurrency import WebKit

// MARK: - Official Bloxstrap Logo Provider
func getBloxstrapLogoImage() -> NSImage? {
    if let bundlePath = Bundle.main.path(forResource: "Bloxstrap", ofType: "png"),
       let img = NSImage(contentsOfFile: bundlePath) {
        return img
    }
    let localPath = "/Users/t4cs/Documents/antigravity/lively-bell/Images/Bloxstrap.png"
    if FileManager.default.fileExists(atPath: localPath),
       let img = NSImage(contentsOfFile: localPath) {
        return img
    }
    return nil
}

// MARK: - Fallback Vector Logo (Perspective 4-Square Gradient)
class BloxstrapLogoView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let img = getBloxstrapLogoImage() {
            img.draw(in: bounds, from: .zero, operation: .sourceOver, fraction: 1.0)
            return
        }
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        let w = bounds.width
        let h = bounds.height
        
        ctx.saveGState()
        // Center rotation for isometric Bloxstrap diamond look
        ctx.translateBy(x: w / 2, y: h / 2)
        ctx.rotate(by: -18 * .pi / 180)
        
        let tileSize = w * 0.38
        let gap = w * 0.08
        let corner = tileSize * 0.22
        
        let colors = [
            NSColor(calibratedRed: 0.85, green: 0.35, blue: 0.95, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.40, green: 0.30, blue: 0.95, alpha: 1.0).cgColor
        ] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) else {
            ctx.restoreGState()
            return
        }
        
        let tiles: [CGRect] = [
            CGRect(x: -tileSize - gap/2, y: gap/2, width: tileSize, height: tileSize),
            CGRect(x: gap/2, y: gap/2, width: tileSize, height: tileSize),
            CGRect(x: -tileSize - gap/2, y: -tileSize - gap/2, width: tileSize, height: tileSize),
            CGRect(x: gap/2, y: -tileSize - gap/2, width: tileSize, height: tileSize)
        ]
        
        for r in tiles {
            let p = CGPath(roundedRect: r, cornerWidth: corner, cornerHeight: corner, transform: nil)
            ctx.saveGState()
            ctx.addPath(p)
            ctx.clip()
            ctx.drawLinearGradient(gradient, start: CGPoint(x: r.minX, y: r.maxY), end: CGPoint(x: r.maxX, y: r.minY), options: [])
            ctx.restoreGState()
        }
        ctx.restoreGState()
    }
}

// MARK: - Windows 11 Fluent Caption Control Button
class WindowsCaptionButton: NSButton {
    enum ButtonType {
        case help
        case minimize
        case maximize
        case close
    }
    
    let btnType: ButtonType
    private var trackingArea: NSTrackingArea?
    private var isHovered = false
    
    init(type: ButtonType, frame: NSRect) {
        self.btnType = type
        super.init(frame: frame)
        self.isBordered = false
        self.wantsLayer = true
        self.focusRingType = .none
        
        switch type {
        case .help:
            self.title = "？"
            self.font = .systemFont(ofSize: 12, weight: .bold)
        case .minimize:
            self.title = "─"
            self.font = .systemFont(ofSize: 11, weight: .regular)
        case .maximize:
            self.title = "□"
            self.font = .systemFont(ofSize: 12, weight: .bold)
        case .close:
            self.title = "✕"
            self.font = .systemFont(ofSize: 11, weight: .regular)
        }
        self.contentTintColor = NSColor(calibratedWhite: 0.82, alpha: 1.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        self.trackingArea = area
    }
    
    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        needsDisplay = true
    }
    
    override func mouseExited(with event: NSEvent) {
        isHovered = false
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isHovered {
            if btnType == .close {
                NSColor(calibratedRed: 0.91, green: 0.07, blue: 0.14, alpha: 1.0).setFill() // Windows Close Red #E81123
            } else {
                NSColor(calibratedWhite: 1.0, alpha: 0.09).setFill()
            }
            dirtyRect.fill()
        }
        super.draw(dirtyRect)
    }
}

// MARK: - Draggable Custom Windows TitleBar
class CustomTitleBarView: NSView {
    override func mouseDown(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        if hitTest(loc) is NSButton {
            super.mouseDown(with: event)
        } else {
            window?.performDrag(with: event)
        }
    }
}

// MARK: - Windows 11 Fluent Toggle Switch (Pixel-Identical to WPF UI)
class FluentToggleSwitch: NSControl {
    var isOn: Bool = false {
        didSet {
            needsDisplay = true
            sendAction(action, to: target)
        }
    }
    
    // Bloxstrap Purple Accent (#B084F9)
    var onTrackColor = NSColor(calibratedRed: 0.69, green: 0.52, blue: 0.98, alpha: 1.0)
    var onThumbColor = NSColor(calibratedRed: 0.09, green: 0.08, blue: 0.14, alpha: 1.0)
    var offBorderColor = NSColor(calibratedWhite: 0.55, alpha: 0.85)
    var offThumbColor = NSColor(calibratedWhite: 0.88, alpha: 1.0)
    var offTrackColor = NSColor(calibratedRed: 0.12, green: 0.11, blue: 0.15, alpha: 1.0)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: frameRect.origin.x, y: frameRect.origin.y, width: 44, height: 22))
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        let trackRect = NSRect(x: 2, y: 2, width: 40, height: 18)
        let corner = trackRect.height / 2
        let path = CGPath(roundedRect: trackRect, cornerWidth: corner, cornerHeight: corner, transform: nil)
        
        if isOn {
            // Filled track with accent color
            ctx.setFillColor(onTrackColor.cgColor)
            ctx.addPath(path)
            ctx.fillPath()
            
            // Dark thumb on right side (exact screenshot style)
            ctx.setFillColor(onThumbColor.cgColor)
            let thumbRect = NSRect(x: trackRect.maxX - 15.5, y: trackRect.minY + 2.5, width: 13, height: 13)
            let thumbPath = CGPath(roundedRect: thumbRect, cornerWidth: 6.5, cornerHeight: 6.5, transform: nil)
            ctx.addPath(thumbPath)
            ctx.fillPath()
        } else {
            // Dark track inside
            ctx.setFillColor(offTrackColor.cgColor)
            ctx.addPath(path)
            ctx.fillPath()
            
            // Border outline
            ctx.setStrokeColor(offBorderColor.cgColor)
            ctx.setLineWidth(1.5)
            ctx.addPath(path)
            ctx.strokePath()
            
            // Light thumb on left side
            ctx.setFillColor(offThumbColor.cgColor)
            let thumbRect = NSRect(x: trackRect.minX + 2.5, y: trackRect.minY + 2.5, width: 13, height: 13)
            let thumbPath = CGPath(roundedRect: thumbRect, cornerWidth: 6.5, cornerHeight: 6.5, transform: nil)
            ctx.addPath(thumbPath)
            ctx.fillPath()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        isOn.toggle()
    }
}

// MARK: - Sidebar Item Button with Hover Tracking
class SidebarItemButton: NSButton {
    private var trackingArea: NSTrackingArea?
    var isCurrentSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    private var isHovered: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.isBordered = false
        self.wantsLayer = true
        self.layer?.cornerRadius = 5
        self.alignment = .left
        self.font = .systemFont(ofSize: 13, weight: .medium)
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        self.trackingArea = area
    }
    
    override func mouseEntered(with event: NSEvent) {
        isHovered = true
    }
    
    override func mouseExited(with event: NSEvent) {
        isHovered = false
    }
    
    private func updateAppearance() {
        if isCurrentSelected {
            layer?.backgroundColor = NSColor(calibratedRed: 0.173, green: 0.169, blue: 0.212, alpha: 1.0).cgColor // Selected #2C2B36
            contentTintColor = .white
        } else if isHovered {
            layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.04).cgColor
            contentTintColor = NSColor(calibratedRed: 0.90, green: 0.90, blue: 0.94, alpha: 1.0)
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            contentTintColor = NSColor(calibratedRed: 0.72, green: 0.71, blue: 0.77, alpha: 1.0)
        }
    }
}

// MARK: - Flipped Container for Top-Down Layout
class FlippedContainerView: NSView {
    override var isFlipped: Bool { return true }
}

// MARK: - Pixel-Identical Bloxstrap Main Window
public class MainWindowController: NSWindowController, WKNavigationDelegate, NSTextFieldDelegate {
    
    // Windows TitleBar & Navigation
    private var customTitleBar: CustomTitleBarView!
    private var sidebarView: NSView!
    private var sidebarButtons: [SidebarItemButton] = []
    private var activeIndicators: [NSView] = []
    private var contentContainer: NSView!
    private var tabViews: [NSView] = []
    private var currentTabIndex: Int = 2 // Default: FastFlags (matching Screenshot 1)
    
    // Bottom Status Bar
    private var statusBarView: NSView!
    private var toastLabel: NSTextField!
    private var tierBadgeLabel: NSTextField!
    
    // Key Gate Overlay
    private var keyGateOverlay: NSView!
    private var keyGateInputField: NSTextField!
    private var keyGateTierLabel: NSTextField!
    private var keyGateErrorLabel: NSTextField!
    
    // Dynamic Control Fields
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
    
    // Multi-Instance Status
    private var multiInstanceStatusLabel: NSTextField!
    private var instancesStackView: NSStackView!
    private var accountsStackView: NSStackView!
    private var instanceTimer: Timer?
    
    // Authentic Bloxstrap Navigation Items
    private let pageNames: [String] = [
        "Integrations",
        "Mods",
        "FastFlags",
        "Appearance",
        "Behaviour",
        "Installation",
        "Bloxstrap Gold",
        "About"
    ]
    
    private let pageIcons: [String] = [
        "＋",
        "🔧",
        "⚐",
        "🖥",
        "⚙",
        "🖫",
        "👑",
        "❓"
    ]
    
    public init() {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 80, width: 1000, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Bloxstrap Menu"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.backgroundColor = NSColor(calibratedRed: 0.122, green: 0.118, blue: 0.149, alpha: 1.0) // Mica Dark #1F1E26
        window.minSize = NSSize(width: 960, height: 560)
        
        // Hide standard macOS traffic lights to present Windows 11 Fluent frame
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        super.init(window: window)
        setupUI()
        
        // Instance polling timer
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
        contentView.layer?.backgroundColor = NSColor(calibratedRed: 0.122, green: 0.118, blue: 0.149, alpha: 1.0).cgColor
        
        let bounds = contentView.bounds
        
        // 1. Windows TitleBar (Flush with top, height: 38px)
        setupCustomTitleBar(bounds: bounds)
        
        // 2. Bottom Status Bar (Flush with bottom, height: 52px)
        setupBottomStatusBar(bounds: bounds)
        
        // 3. Left Sidebar (Width: 216px)
        let bodyY: CGFloat = 52
        let bodyH: CGFloat = bounds.height - 52 - 38
        sidebarView = NSView(frame: NSRect(x: 0, y: bodyY, width: 216, height: bodyH))
        sidebarView.wantsLayer = true
        sidebarView.layer?.backgroundColor = NSColor(calibratedRed: 0.098, green: 0.094, blue: 0.125, alpha: 1.0).cgColor // Sidebar #191820
        sidebarView.autoresizingMask = [.height, .maxXMargin]
        contentView.addSubview(sidebarView)
        setupSidebar()
        
        // 4. Right Content Container (Width: bounds.width - 216)
        contentContainer = NSView(frame: NSRect(x: 216, y: bodyY, width: bounds.width - 216, height: bodyH))
        contentContainer.wantsLayer = true
        contentContainer.layer?.backgroundColor = NSColor(calibratedRed: 0.122, green: 0.118, blue: 0.149, alpha: 1.0).cgColor
        contentContainer.autoresizingMask = [.width, .height]
        contentView.addSubview(contentContainer)
        
        // Build the authentic Bloxstrap pages
        tabViews = [
            buildIntegrationsPage(bounds: contentContainer.bounds),
            buildModsPage(bounds: contentContainer.bounds),
            buildFastFlagsPage(bounds: contentContainer.bounds),
            buildAppearancePage(bounds: contentContainer.bounds),
            buildBehaviourPage(bounds: contentContainer.bounds),
            buildInstallationPage(bounds: contentContainer.bounds),
            buildGoldPage(bounds: contentContainer.bounds),
            buildAboutPage(bounds: contentContainer.bounds)
        ]
        
        for tab in tabViews {
            tab.autoresizingMask = [.width, .height]
            tab.isHidden = true
            contentContainer.addSubview(tab)
        }
        
        // Select initial tab (FastFlags, index 2, matching Screenshot 1)
        selectTab(index: 2)
        
        // 5. Key Gate Modal Overlay
        setupKeyGateOverlay(bounds: bounds)
        updateAuthenticationState()
    }
    
    // MARK: - Windows 11 TitleBar
    private func setupCustomTitleBar(bounds: NSRect) {
        guard let contentView = window?.contentView else { return }
        
        customTitleBar = CustomTitleBarView(frame: NSRect(x: 0, y: bounds.height - 38, width: bounds.width, height: 38))
        customTitleBar.wantsLayer = true
        customTitleBar.layer?.backgroundColor = NSColor(calibratedRed: 0.098, green: 0.094, blue: 0.125, alpha: 1.0).cgColor
        customTitleBar.autoresizingMask = [.width, .minYMargin]
        contentView.addSubview(customTitleBar)
        
        // Official Bloxstrap Logo (18x18) on Top Left
        let logoContainer = NSView(frame: NSRect(x: 14, y: 10, width: 18, height: 18))
        if let img = getBloxstrapLogoImage() {
            let iv = NSImageView(frame: logoContainer.bounds)
            iv.image = img
            iv.imageScaling = .scaleProportionallyUpOrDown
            logoContainer.addSubview(iv)
        } else {
            let fallback = BloxstrapLogoView(frame: logoContainer.bounds)
            logoContainer.addSubview(fallback)
        }
        customTitleBar.addSubview(logoContainer)
        
        let titleLabel = NSTextField(labelWithString: "Bloxstrap Menu")
        titleLabel.font = .systemFont(ofSize: 12.5, weight: .regular)
        titleLabel.textColor = .white
        titleLabel.frame = NSRect(x: 38, y: 10, width: 140, height: 18)
        customTitleBar.addSubview(titleLabel)
        
        // Tier Header Tag on right side of title bar
        tierBadgeLabel = NSTextField(labelWithString: AppState.shared.currentTierBadge)
        tierBadgeLabel.font = .boldSystemFont(ofSize: 9.5)
        tierBadgeLabel.alignment = .center
        tierBadgeLabel.textColor = .black
        tierBadgeLabel.wantsLayer = true
        tierBadgeLabel.layer?.backgroundColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0).cgColor
        tierBadgeLabel.layer?.cornerRadius = 3
        tierBadgeLabel.frame = NSRect(x: customTitleBar.bounds.width - 310, y: 9, width: 110, height: 20)
        tierBadgeLabel.autoresizingMask = [.minXMargin]
        customTitleBar.addSubview(tierBadgeLabel)
        
        // Windows 11 Caption Controls: [ ? ] [ ─ ] [ □ ] [ ✕ ]
        let helpBtn = WindowsCaptionButton(type: .help, frame: NSRect(x: customTitleBar.bounds.width - 184, y: 0, width: 46, height: 38))
        helpBtn.target = self
        helpBtn.action = #selector(onOpenStore)
        helpBtn.autoresizingMask = [.minXMargin]
        customTitleBar.addSubview(helpBtn)
        
        let minBtn = WindowsCaptionButton(type: .minimize, frame: NSRect(x: customTitleBar.bounds.width - 138, y: 0, width: 46, height: 38))
        minBtn.target = self
        minBtn.action = #selector(onMinimizeClicked)
        minBtn.autoresizingMask = [.minXMargin]
        customTitleBar.addSubview(minBtn)
        
        let maxBtn = WindowsCaptionButton(type: .maximize, frame: NSRect(x: customTitleBar.bounds.width - 92, y: 0, width: 46, height: 38))
        maxBtn.target = self
        maxBtn.action = #selector(onMaximizeClicked)
        maxBtn.autoresizingMask = [.minXMargin]
        customTitleBar.addSubview(maxBtn)
        
        let closeBtn = WindowsCaptionButton(type: .close, frame: NSRect(x: customTitleBar.bounds.width - 46, y: 0, width: 46, height: 38))
        closeBtn.target = self
        closeBtn.action = #selector(onCloseClicked)
        closeBtn.autoresizingMask = [.minXMargin]
        customTitleBar.addSubview(closeBtn)
    }
    
    @objc private func onMinimizeClicked() {
        window?.miniaturize(nil)
    }
    
    @objc private func onMaximizeClicked() {
        window?.zoom(nil)
    }
    
    // MARK: - Key Gate Modal (Requires GOLD-7DAY-)
    private func setupKeyGateOverlay(bounds: NSRect) {
        guard let contentView = window?.contentView else { return }
        
        keyGateOverlay = NSView(frame: bounds)
        keyGateOverlay.wantsLayer = true
        keyGateOverlay.layer?.backgroundColor = NSColor(calibratedWhite: 0.0, alpha: 0.80).cgColor
        keyGateOverlay.autoresizingMask = [.width, .height]
        
        let cardW: CGFloat = 520
        let cardH: CGFloat = 360
        let card = NSView(frame: NSRect(x: (bounds.width - cardW) / 2, y: (bounds.height - cardH) / 2, width: cardW, height: cardH))
        card.wantsLayer = true
        card.layer?.backgroundColor = NSColor(calibratedRed: 0.145, green: 0.141, blue: 0.176, alpha: 1.0).cgColor
        card.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.08).cgColor
        card.layer?.borderWidth = 1.0
        card.layer?.cornerRadius = 8
        card.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        keyGateOverlay.addSubview(card)
        
        let crown = NSTextField(labelWithString: "👑")
        crown.font = .systemFont(ofSize: 42)
        crown.frame = NSRect(x: (cardW - 50) / 2, y: cardH - 68, width: 50, height: 50)
        card.addSubview(crown)
        
        let title = NSTextField(labelWithString: "Bloxstrap Gold Activation")
        title.font = .boldSystemFont(ofSize: 18)
        title.textColor = .white
        title.alignment = .center
        title.frame = NSRect(x: 20, y: cardH - 102, width: cardW - 40, height: 24)
        card.addSubview(title)
        
        let desc = NSTextField(labelWithString: "Please enter your license key to authenticate and access Bloxstrap Gold.\nKeys must start with GOLD-7DAY- (e.g. GOLD-7DAY-ULTRA-XXXX-XXXX-XXXX).")
        desc.font = .systemFont(ofSize: 12)
        desc.textColor = NSColor(calibratedRed: 0.70, green: 0.70, blue: 0.78, alpha: 1.0)
        desc.alignment = .center
        desc.frame = NSRect(x: 20, y: cardH - 150, width: cardW - 40, height: 34)
        card.addSubview(desc)
        
        keyGateInputField = NSTextField(frame: NSRect(x: 40, y: cardH - 196, width: cardW - 80, height: 34))
        keyGateInputField.placeholderString = "GOLD-7DAY-ULTRA-XXXX-XXXX-XXXX"
        keyGateInputField.font = .monospacedSystemFont(ofSize: 12, weight: .bold)
        keyGateInputField.textColor = .white
        keyGateInputField.wantsLayer = true
        keyGateInputField.layer?.backgroundColor = NSColor(calibratedRed: 0.098, green: 0.094, blue: 0.125, alpha: 1.0).cgColor
        keyGateInputField.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.12).cgColor
        keyGateInputField.layer?.borderWidth = 1.0
        keyGateInputField.layer?.cornerRadius = 4
        keyGateInputField.delegate = self
        card.addSubview(keyGateInputField)
        
        keyGateTierLabel = NSTextField(labelWithString: "🔑 Enter a valid key to detect your tier")
        keyGateTierLabel.font = .boldSystemFont(ofSize: 11.5)
        keyGateTierLabel.textColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0)
        keyGateTierLabel.alignment = .center
        keyGateTierLabel.frame = NSRect(x: 20, y: cardH - 228, width: cardW - 40, height: 18)
        card.addSubview(keyGateTierLabel)
        
        keyGateErrorLabel = NSTextField(labelWithString: "")
        keyGateErrorLabel.font = .systemFont(ofSize: 11)
        keyGateErrorLabel.textColor = NSColor(calibratedRed: 0.95, green: 0.35, blue: 0.35, alpha: 1.0)
        keyGateErrorLabel.alignment = .center
        keyGateErrorLabel.frame = NSRect(x: 20, y: cardH - 250, width: cardW - 40, height: 18)
        card.addSubview(keyGateErrorLabel)
        
        let unlockBtn = NSButton(frame: NSRect(x: 40, y: 56, width: cardW - 80, height: 36))
        unlockBtn.title = "Unlock Bloxstrap Gold"
        unlockBtn.isBordered = false
        unlockBtn.font = .boldSystemFont(ofSize: 13)
        unlockBtn.wantsLayer = true
        unlockBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0).cgColor
        unlockBtn.layer?.cornerRadius = 4
        unlockBtn.contentTintColor = .black
        unlockBtn.target = self
        unlockBtn.action = #selector(onActivateKeyClicked)
        card.addSubview(unlockBtn)
        
        let storeBtn = NSButton(frame: NSRect(x: 40, y: 20, width: cardW - 80, height: 26))
        storeBtn.title = "🛒 Get a key at bloxstrapgold.github.io"
        storeBtn.isBordered = false
        storeBtn.font = .systemFont(ofSize: 11, weight: .semibold)
        storeBtn.contentTintColor = NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.85, alpha: 1.0)
        storeBtn.target = self
        storeBtn.action = #selector(onOpenStore)
        card.addSubview(storeBtn)
        
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
            showToast("✓ Unlocked: \(AppState.shared.currentTierName)")
        } else {
            keyGateErrorLabel.stringValue = "Invalid key! Must start with GOLD-7DAY- (e.g. GOLD-7DAY-ULTRA-...)"
        }
    }
    
    private func updateAuthenticationState() {
        let auth = AppState.shared.isAuthenticated
        keyGateOverlay.isHidden = auth
        tierBadgeLabel.stringValue = AppState.shared.currentTierBadge
    }
    
    public func handleDeepLinkActivation(key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if AppState.shared.verifyAndApplyKey(trimmed) {
            updateAuthenticationState()
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            showToast("✓ Activated: \(AppState.shared.currentTierName)")
        }
    }
    
    // MARK: - Sidebar Setup (Verbatim NavigationFluent from Screenshots)
    private func setupSidebar() {
        sidebarButtons.removeAll()
        activeIndicators.removeAll()
        sidebarView.subviews.forEach { $0.removeFromSuperview() }
        
        let startY: CGFloat = sidebarView.bounds.height - 40
        for (i, name) in pageNames.enumerated() {
            let y = startY - CGFloat(i * 38)
            let row = NSView(frame: NSRect(x: 6, y: y, width: sidebarView.bounds.width - 12, height: 34))
            row.autoresizingMask = [.width, .minYMargin]
            
            // Left active purple pill indicator (|)
            let indicator = NSView(frame: NSRect(x: 2, y: 8, width: 3.5, height: 18))
            indicator.wantsLayer = true
            indicator.layer?.backgroundColor = NSColor(calibratedRed: 0.69, green: 0.52, blue: 0.98, alpha: 1.0).cgColor // #B084F9
            indicator.layer?.cornerRadius = 1.75
            indicator.isHidden = (i != currentTabIndex)
            row.addSubview(indicator)
            activeIndicators.append(indicator)
            
            let btn = SidebarItemButton(frame: NSRect(x: 8, y: 0, width: row.bounds.width - 8, height: 34))
            btn.title = "  \(pageIcons[i])   \(name)"
            btn.tag = i
            btn.target = self
            btn.action = #selector(onSidebarTabClicked(_:))
            btn.autoresizingMask = [.width]
            btn.isCurrentSelected = (i == currentTabIndex)
            row.addSubview(btn)
            sidebarButtons.append(btn)
            
            sidebarView.addSubview(row)
        }
    }
    
    @objc private func onSidebarTabClicked(_ sender: NSButton) {
        selectTab(index: sender.tag)
    }
    
    @objc public func showAboutTab() {
        selectTab(index: 7)
    }
    
    private func selectTab(index: Int) {
        currentTabIndex = index
        for (i, btn) in sidebarButtons.enumerated() {
            let isSelected = (i == index)
            btn.isCurrentSelected = isSelected
            activeIndicators[i].isHidden = !isSelected
        }
        for (i, v) in tabViews.enumerated() {
            v.isHidden = (i != index)
        }
        if index == 6 {
            updateInstanceList()
        }
    }
    
    // MARK: - Bottom Status Bar
    private func setupBottomStatusBar(bounds: NSRect) {
        guard let contentView = window?.contentView else { return }
        
        statusBarView = NSView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: 52))
        statusBarView.wantsLayer = true
        statusBarView.layer?.backgroundColor = NSColor(calibratedRed: 0.098, green: 0.094, blue: 0.125, alpha: 1.0).cgColor
        statusBarView.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.06).cgColor
        statusBarView.layer?.borderWidth = 1.0
        statusBarView.autoresizingMask = [.width, .maxYMargin]
        contentView.addSubview(statusBarView)
        
        let isInstalled = MultiInstanceManager.shared.isRobloxInstalled
        let dot = NSTextField(labelWithString: isInstalled ? "🟢" : "🟡")
        dot.font = .systemFont(ofSize: 9)
        dot.frame = NSRect(x: 16, y: 18, width: 16, height: 16)
        statusBarView.addSubview(dot)
        
        let statusLbl = NSTextField(labelWithString: isInstalled ? "Roblox.app Detected" : "Roblox Not Found")
        statusLbl.font = .systemFont(ofSize: 12, weight: .medium)
        statusLbl.textColor = isInstalled ? NSColor(calibratedRed: 0.18, green: 0.80, blue: 0.44, alpha: 1.0) : .systemYellow
        statusLbl.frame = NSRect(x: 36, y: 17, width: 180, height: 18)
        statusBarView.addSubview(statusLbl)
        
        toastLabel = NSTextField(labelWithString: "")
        toastLabel.font = .boldSystemFont(ofSize: 11.5)
        toastLabel.textColor = NSColor(calibratedRed: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        toastLabel.frame = NSRect(x: 230, y: 17, width: 280, height: 18)
        toastLabel.isHidden = true
        statusBarView.addSubview(toastLabel)
        
        // Exact Bloxstrap Cancel button: dark flat rectangle
        let cancelBtn = NSButton(frame: NSRect(x: statusBarView.bounds.width - 92, y: 11, width: 78, height: 30))
        cancelBtn.title = "Cancel"
        cancelBtn.isBordered = false
        cancelBtn.wantsLayer = true
        cancelBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.173, green: 0.169, blue: 0.204, alpha: 1.0).cgColor // #2B2A34
        cancelBtn.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.10).cgColor
        cancelBtn.layer?.borderWidth = 1.0
        cancelBtn.layer?.cornerRadius = 4
        cancelBtn.font = .systemFont(ofSize: 12, weight: .medium)
        cancelBtn.contentTintColor = .white
        cancelBtn.target = self
        cancelBtn.action = #selector(onCloseClicked)
        cancelBtn.autoresizingMask = [.minXMargin]
        statusBarView.addSubview(cancelBtn)
        
        // Exact Bloxstrap Save button: #B084F9 purple pill
        let saveBtn = NSButton(frame: NSRect(x: statusBarView.bounds.width - 180, y: 11, width: 80, height: 30))
        saveBtn.title = "Save"
        saveBtn.isBordered = false
        saveBtn.wantsLayer = true
        saveBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.69, green: 0.52, blue: 0.98, alpha: 1.0).cgColor // #B084F9
        saveBtn.layer?.cornerRadius = 4
        saveBtn.font = .boldSystemFont(ofSize: 12.5)
        saveBtn.contentTintColor = NSColor(calibratedRed: 0.09, green: 0.08, blue: 0.14, alpha: 1.0)
        saveBtn.target = self
        saveBtn.action = #selector(onSaveClicked)
        saveBtn.autoresizingMask = [.minXMargin]
        statusBarView.addSubview(saveBtn)
    }
    
    @objc private func onSaveClicked() {
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
    
    // MARK: - PAGE 1: FASTFLAGS (EXACT SCREENSHOT 1)
    private func buildFastFlagsPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        
        let title = createPageHeader(title: "FastFlags", subtitle: "Control how specific Roblox engine parameters and features are configured.")
        stack.addArrangedSubview(title)
        
        // Two Action Cards side-by-side: [ FastFlag Editor > ]  [ Help > ]
        let cardRow = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 56))
        cardRow.translatesAutoresizingMaskIntoConstraints = false
        cardRow.heightAnchor.constraint(equalToConstant: 56).isActive = true
        cardRow.widthAnchor.constraint(equalToConstant: 720).isActive = true
        
        let card1 = createCardAction(frame: NSRect(x: 0, y: 0, width: 352, height: 56), icon: "⚙", title: "FastFlag Editor", desc: "Manage your own FastFlags.", action: #selector(onOpenFastFlagEditor))
        let card2 = createCardAction(frame: NSRect(x: 368, y: 0, width: 352, height: 56), icon: "❓", title: "Help", desc: "Learn more about FastFlags.", action: #selector(onOpenFastFlagHelp))
        cardRow.addSubview(card1)
        cardRow.addSubview(card2)
        stack.addArrangedSubview(cardRow)
        
        // Section: Presets
        let presetHeader = createSectionHeader("Presets")
        stack.addArrangedSubview(presetHeader)
        
        let presetSub = createSubtitleLabel("FastFlags for Direct3D exclusive fullscreen (Alt+Enter) and DPI scaling fixes are already enabled by default.")
        stack.addArrangedSubview(presetSub)
        
        // Option 1: Framerate limit (?)
        fpsInputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 150, height: 28))
        fpsInputField.stringValue = "\(AppState.shared.data.targetFps)"
        fpsInputField.font = .monospacedSystemFont(ofSize: 12.5, weight: .bold)
        fpsInputField.textColor = .white
        fpsInputField.alignment = .right
        fpsInputField.wantsLayer = true
        fpsInputField.layer?.backgroundColor = NSColor(calibratedRed: 0.173, green: 0.169, blue: 0.204, alpha: 1.0).cgColor
        fpsInputField.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.10).cgColor
        fpsInputField.layer?.borderWidth = 1.0
        fpsInputField.layer?.cornerRadius = 4
        let optFps = createOptionControl(header: "Framerate limit", hasHelpBadge: true, desc: "Use a large number like 9999 for no limit. Set as 0 for defaults.", control: fpsInputField)
        stack.addArrangedSubview(optFps)
        
        // Option 2: Preferred lighting technology
        lightingPopup = createStyledPopup(items: ["Chosen by game", "Compatibility (Phase 1)", "ShadowMap (Phase 2)", "Future (Phase 3)"], selected: AppState.shared.data.preferredLighting)
        let optLight = createOptionControl(header: "Preferred lighting technology", hasHelpBadge: false, desc: "Choose which lighting technology should be forced enabled in all games.", control: lightingPopup)
        stack.addArrangedSubview(optLight)
        
        // Option 3: Preferred escape menu version (?)
        escapeMenuPopup = createStyledPopup(items: ["Default", "Version 1 (2015)", "Version 2 (2020)", "Version 4 (2023)"], selected: AppState.shared.data.escapeMenuVersion)
        let optEsc = createOptionControl(header: "Preferred escape menu version", hasHelpBadge: true, desc: "Choose which version of the escape menu to use.", control: escapeMenuPopup)
        stack.addArrangedSubview(optEsc)
        
        // Option 4: Enable ability to hide GUIs (?)
        hideGuisSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        hideGuisSwitch.isOn = AppState.shared.data.hideGuisEnabled
        let optHide = createOptionControl(header: "Enable ability to hide GUIs", hasHelpBadge: true, desc: "Toggled with keyboard shortcuts. Only works if you're in the Bloxstrap group.", control: hideGuisSwitch)
        stack.addArrangedSubview(optHide)
        
        return scrollView
    }
    
    // MARK: - PAGE 2: MODS (EXACT SCREENSHOT 2)
    private func buildModsPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        
        let title = createPageHeader(title: "Mods", subtitle: "")
        stack.addArrangedSubview(title)
        
        // Option 1: Rendering mode
        renderingModePopup = createStyledPopup(items: ["Direct3D 11", "Metal (macOS Default)", "Vulkan / MoltenVK", "OpenGL"], selected: AppState.shared.data.renderingMode)
        let optRen = createOptionControl(header: "Rendering mode", hasHelpBadge: false, desc: "Select which renderer Roblox should use. ReShade requires Direct3D 11.", control: renderingModePopup)
        stack.addArrangedSubview(optRen)
        
        // Option 2: Use exclusive fullscreen
        exclusiveFullscreenSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        exclusiveFullscreenSwitch.isOn = AppState.shared.data.exclusiveFullscreen
        let optFull = createOptionControl(header: "Use exclusive fullscreen", hasHelpBadge: false, desc: "Enables using Alt + Enter to enter exclusive fullscreen. Only works with Direct3D 11.", control: exclusiveFullscreenSwitch)
        stack.addArrangedSubview(optFull)
        
        // Option 3: Use alternate graphics quality selector
        altQualitySwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        altQualitySwitch.isOn = AppState.shared.data.alternateQualitySelector
        let optAlt = createOptionControl(header: "Use alternate graphics quality selector", hasHelpBadge: false, desc: "Toggle between using the consolidated 1-10 / fine-grained 1-21 graphics quality slider.", control: altQualitySwitch)
        stack.addArrangedSubview(optAlt)
        
        // Option 4: In-game menu version
        inGameMenuPopup = createStyledPopup(items: ["Default", "Version 1 (2015)", "Version 2 (2020)", "Version 3 (2021)", "Version 4 (2023)"], selected: AppState.shared.data.inGameMenuVersion)
        let optMenu = createOptionControl(header: "In-game menu version", hasHelpBadge: false, desc: "Choose which version of the in-game menu to use. Current default is v1.", control: inGameMenuPopup)
        stack.addArrangedSubview(optMenu)
        
        // Section: Miscellaneous
        let miscHeader = createSectionHeader("Miscellaneous")
        stack.addArrangedSubview(miscHeader)
        
        // Option 5: Disable full-screen optimizations
        disableFsoSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        disableFsoSwitch.isOn = AppState.shared.data.disableFullscreenOptimizations
        let optFso = createOptionControl(header: "Disable full-screen optimizations", hasHelpBadge: false, desc: "A Windows feature that can potentially cause problems - click here for more info.", control: disableFsoSwitch)
        stack.addArrangedSubview(optFso)
        
        // Option 6: Classic 2006 Death Sound + Preview
        let soundControls = NSView(frame: NSRect(x: 0, y: 0, width: 140, height: 26))
        
        let playBtn = NSButton(frame: NSRect(x: 0, y: 1, width: 85, height: 24))
        playBtn.title = "▶ Preview"
        playBtn.isBordered = false
        playBtn.wantsLayer = true
        playBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.22, green: 0.21, blue: 0.26, alpha: 1.0).cgColor
        playBtn.layer?.cornerRadius = 4
        playBtn.font = .systemFont(ofSize: 11, weight: .medium)
        playBtn.contentTintColor = .white
        playBtn.target = self
        playBtn.action = #selector(onPlayOofPreview)
        soundControls.addSubview(playBtn)
        
        deathSoundSwitch = FluentToggleSwitch(frame: NSRect(x: 94, y: 2, width: 44, height: 22))
        deathSoundSwitch.isOn = AppState.shared.data.customDeathSound
        deathSoundSwitch.target = self
        deathSoundSwitch.action = #selector(onDeathSoundToggled)
        soundControls.addSubview(deathSoundSwitch)
        
        let optSound = createOptionControl(header: "Classic 2006 \"OOF\" death sound", hasHelpBadge: false, desc: "Restores the nostalgic sound and backs up default Roblox audio.", control: soundControls)
        stack.addArrangedSubview(optSound)
        
        return scrollView
    }
    
    @objc private func onPlayOofPreview() {
        SoundManager.shared.playPreview()
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
    
    // MARK: - PAGE 3: ABOUT (EXACT SCREENSHOT 3)
    private func buildAboutPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        
        let title = createPageHeader(title: "About", subtitle: "")
        stack.addArrangedSubview(title)
        
        let heroCard = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 110))
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.heightAnchor.constraint(equalToConstant: 110).isActive = true
        heroCard.widthAnchor.constraint(equalToConstant: 720).isActive = true
        
        // Official Bloxstrap Logo (48x48)
        let logoContainer = NSView(frame: NSRect(x: 0, y: 40, width: 48, height: 48))
        if let img = getBloxstrapLogoImage() {
            let iv = NSImageView(frame: logoContainer.bounds)
            iv.image = img
            iv.imageScaling = .scaleProportionallyUpOrDown
            logoContainer.addSubview(iv)
        } else {
            let fallback = BloxstrapLogoView(frame: logoContainer.bounds)
            logoContainer.addSubview(fallback)
        }
        heroCard.addSubview(logoContainer)
        
        let appName = NSTextField(labelWithString: "Bloxstrap  Version 2.3.0")
        appName.font = .boldSystemFont(ofSize: 18)
        appName.textColor = .white
        appName.frame = NSRect(x: 58, y: 64, width: 400, height: 24)
        heroCard.addSubview(appName)
        
        let appDesc = NSTextField(labelWithString: "An open-source, feature-packed alternative bootstrapper for Roblox\nDeveloped by pizzaboxer - if you like this, please consider leaving a star on GitHub!")
        appDesc.font = .systemFont(ofSize: 12)
        appDesc.textColor = NSColor(calibratedRed: 0.70, green: 0.70, blue: 0.78, alpha: 1.0)
        appDesc.frame = NSRect(x: 58, y: 22, width: 620, height: 36)
        heroCard.addSubview(appDesc)
        
        stack.addArrangedSubview(heroCard)
        
        // Exact Pill Buttons Row from Screenshot 3
        let pillsRow = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 36))
        pillsRow.translatesAutoresizingMaskIntoConstraints = false
        pillsRow.heightAnchor.constraint(equalToConstant: 36).isActive = true
        pillsRow.widthAnchor.constraint(equalToConstant: 720).isActive = true
        
        let p1 = createActionPill(frame: NSRect(x: 0, y: 2, width: 165, height: 30), icon: "</>", title: "GitHub repository", url: "https://github.com/Bloxstrap-Gold/Bloxstrap-Gold")
        let p2 = createActionPill(frame: NSRect(x: 175, y: 2, width: 145, height: 30), icon: "🗩", title: "Report an issue", url: "https://github.com/Bloxstrap-Gold/Bloxstrap-Gold/issues")
        let p3 = createActionPill(frame: NSRect(x: 330, y: 2, width: 125, height: 30), icon: "🕮", title: "Help topics", url: "https://bloxstraplabs.com")
        pillsRow.addSubview(p1)
        pillsRow.addSubview(p2)
        pillsRow.addSubview(p3)
        stack.addArrangedSubview(pillsRow)
        
        // Contributors Section
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
            ("Extravi", "Allowing their presets to be bundled with Bloxstrap, and helping with...")
        ]
        
        for c in contributors {
            let row = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 26))
            row.translatesAutoresizingMaskIntoConstraints = false
            row.heightAnchor.constraint(equalToConstant: 26).isActive = true
            row.widthAnchor.constraint(equalToConstant: 720).isActive = true
            
            let n = NSTextField(labelWithString: c.name)
            n.font = .systemFont(ofSize: 12.5, weight: .semibold)
            n.textColor = NSColor(calibratedRed: 0.69, green: 0.52, blue: 0.98, alpha: 1.0) // Bloxstrap purple
            n.frame = NSRect(x: 4, y: 4, width: 160, height: 18)
            row.addSubview(n)
            
            let d = NSTextField(labelWithString: c.desc)
            d.font = .systemFont(ofSize: 12)
            d.textColor = NSColor(calibratedRed: 0.70, green: 0.70, blue: 0.78, alpha: 1.0)
            d.frame = NSRect(x: 170, y: 4, width: 540, height: 18)
            row.addSubview(d)
            
            stack.addArrangedSubview(row)
        }
        
        let allCodeBtn = createActionPill(frame: NSRect(x: 0, y: 0, width: 200, height: 30), icon: "👥", title: "See all code contributors", url: "https://github.com/Bloxstrap-Gold/Bloxstrap-Gold/graphs/contributors")
        stack.addArrangedSubview(allCodeBtn)
        
        let licHeader = createSectionHeader("Licenses")
        stack.addArrangedSubview(licHeader)
        let licDesc = createSubtitleLabel("Bloxstrap Gold is distributed under the GNU General Public License v3.0 (GPL-3.0). Free forever.")
        stack.addArrangedSubview(licDesc)
        
        return scrollView
    }
    
    // MARK: - PAGE 4: BLOXSTRAP GOLD TAB
    private func buildGoldPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        
        let title = createPageHeader(title: "Bloxstrap Gold Edition", subtitle: "Manage license authentication, multi-instance Roblox clients, and account profiles.")
        stack.addArrangedSubview(title)
        
        let statusCard = createOptionCard(height: 95)
        let t1 = NSTextField(labelWithString: "👑 ACTIVE TIER: \(AppState.shared.currentTierName.uppercased())")
        t1.font = .boldSystemFont(ofSize: 14)
        t1.textColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0)
        t1.frame = NSRect(x: 16, y: 60, width: 450, height: 20)
        statusCard.addSubview(t1)
        
        let t2 = NSTextField(labelWithString: "License Key: \(AppState.shared.data.vipKey ?? "None") • Mode: \(AppState.shared.currentTierPrice)")
        t2.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        t2.textColor = NSColor(calibratedRed: 0.70, green: 0.70, blue: 0.78, alpha: 1.0)
        t2.frame = NSRect(x: 16, y: 36, width: 450, height: 18)
        statusCard.addSubview(t2)
        
        let changeKeyBtn = NSButton(frame: NSRect(x: 16, y: 8, width: 140, height: 24))
        changeKeyBtn.title = "🔑 Change Key"
        changeKeyBtn.isBordered = false
        changeKeyBtn.wantsLayer = true
        changeKeyBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.22, green: 0.21, blue: 0.26, alpha: 1.0).cgColor
        changeKeyBtn.layer?.cornerRadius = 4
        changeKeyBtn.font = .systemFont(ofSize: 11, weight: .medium)
        changeKeyBtn.contentTintColor = .white
        changeKeyBtn.target = self
        changeKeyBtn.action = #selector(onChangeKeyClicked)
        statusCard.addSubview(changeKeyBtn)
        
        let webBtn = NSButton(frame: NSRect(x: 165, y: 8, width: 185, height: 24))
        webBtn.title = "🌐 bloxstrapgold.github.io"
        webBtn.isBordered = false
        webBtn.wantsLayer = true
        webBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.22, green: 0.21, blue: 0.26, alpha: 1.0).cgColor
        webBtn.layer?.cornerRadius = 4
        webBtn.font = .systemFont(ofSize: 11, weight: .medium)
        webBtn.contentTintColor = .white
        webBtn.target = self
        webBtn.action = #selector(onOpenStore)
        statusCard.addSubview(webBtn)
        
        stack.addArrangedSubview(statusCard)
        
        // Multi-Instance Roblox Card
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
        launchBtn.isBordered = false
        launchBtn.wantsLayer = true
        launchBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.898, green: 0.725, blue: 0.282, alpha: 1.0).cgColor
        launchBtn.layer?.cornerRadius = 4
        launchBtn.font = .boldSystemFont(ofSize: 11.5)
        launchBtn.contentTintColor = .black
        launchBtn.target = self
        launchBtn.action = #selector(onLaunchInstance)
        multiCard.addSubview(launchBtn)
        
        let killBtn = NSButton(frame: NSRect(x: 215, y: 12, width: 150, height: 32))
        killBtn.title = "🛑 Close All Instances"
        killBtn.isBordered = false
        killBtn.wantsLayer = true
        killBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.22, green: 0.21, blue: 0.26, alpha: 1.0).cgColor
        killBtn.layer?.cornerRadius = 4
        killBtn.font = .systemFont(ofSize: 11, weight: .medium)
        killBtn.contentTintColor = .white
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
        
        // Account Switcher Card (Roblox Account Manager style)
        let accHeader = createSectionHeader("Account Switcher (Roblox Account Manager)")
        stack.addArrangedSubview(accHeader)
        
        let accCard = createOptionCard(height: 140)
        let accTitle = NSTextField(labelWithString: "Saved Account Profiles")
        accTitle.font = .boldSystemFont(ofSize: 12.5)
        accTitle.textColor = .white
        accTitle.frame = NSRect(x: 16, y: 108, width: 300, height: 18)
        accCard.addSubview(accTitle)
        
        let addAccBtn = NSButton(frame: NSRect(x: 530, y: 104, width: 140, height: 26))
        addAccBtn.title = "＋ Add Alt Profile"
        addAccBtn.isBordered = false
        addAccBtn.wantsLayer = true
        addAccBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.22, green: 0.21, blue: 0.26, alpha: 1.0).cgColor
        addAccBtn.layer?.cornerRadius = 4
        addAccBtn.font = .systemFont(ofSize: 10.5, weight: .medium)
        addAccBtn.contentTintColor = .white
        addAccBtn.target = self
        addAccBtn.action = #selector(onAddAltProfile)
        accCard.addSubview(addAccBtn)
        
        let accScroll = NSScrollView(frame: NSRect(x: 16, y: 12, width: 688, height: 86))
        accScroll.hasVerticalScroller = true
        accScroll.drawsBackground = false
        accountsStackView = NSStackView(frame: accScroll.bounds)
        accountsStackView.orientation = .vertical
        accountsStackView.alignment = .leading
        accountsStackView.spacing = 4
        accScroll.documentView = accountsStackView
        accCard.addSubview(accScroll)
        stack.addArrangedSubview(accCard)
        
        renderAccountsList()
        return scrollView
    }
    
    // MARK: - PAGE 5: INTEGRATIONS
    private func buildIntegrationsPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        let title = createPageHeader(title: "Integrations", subtitle: "Connect Roblox to Discord and external rich presence services.")
        stack.addArrangedSubview(title)
        
        let rpcSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        rpcSwitch.isOn = true
        let optRpc = createOptionControl(header: "Discord Rich Presence", hasHelpBadge: false, desc: "Show game activity, server details, and your Bloxstrap Gold VIP tier on Discord.", control: rpcSwitch)
        stack.addArrangedSubview(optRpc)
        
        let locSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        locSwitch.isOn = true
        let optLoc = createOptionControl(header: "Show server location details", hasHelpBadge: false, desc: "Display region and ping telemetry using server IP queries.", control: locSwitch)
        stack.addArrangedSubview(optLoc)
        return scrollView
    }
    
    // MARK: - PAGE 6: APPEARANCE
    private func buildAppearancePage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        let title = createPageHeader(title: "Appearance", subtitle: "Customize the look and feel of Bloxstrap.")
        stack.addArrangedSubview(title)
        
        let themePopup = createStyledPopup(items: ["Dark (Windows 11 Mica)", "Gold Edition", "Light"], selected: "Dark (Windows 11 Mica)")
        let optTheme = createOptionControl(header: "Theme", hasHelpBadge: false, desc: "Change the visual theme of the Bloxstrap Menu.", control: themePopup)
        stack.addArrangedSubview(optTheme)
        
        let stylePopup = createStyledPopup(items: ["Fluent", "Classic Fluent", "Progress Bar", "Byfron"], selected: "Fluent")
        let optStyle = createOptionControl(header: "Bootstrapper style", hasHelpBadge: false, desc: "Choose the style of dialog shown when Roblox starts.", control: stylePopup)
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
        let optUpdate = createOptionControl(header: "Automatically check for updates", hasHelpBadge: false, desc: "Periodically check for new releases of Bloxstrap Gold.", control: updateSwitch)
        stack.addArrangedSubview(optUpdate)
        
        let multiSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        multiSwitch.isOn = true
        let optMulti = createOptionControl(header: "Allow multi-instance launching", hasHelpBadge: false, desc: "Permit running multiple Roblox clients simultaneously.", control: multiSwitch)
        stack.addArrangedSubview(optMulti)
        return scrollView
    }
    
    // MARK: - PAGE 8: INSTALLATION
    private func buildInstallationPage(bounds: NSRect) -> NSView {
        let (scrollView, stack) = createScrollablePage(bounds: bounds)
        let title = createPageHeader(title: "Installation", subtitle: "Configure bootstrapper install folder and shortcuts.")
        stack.addArrangedSubview(title)
        
        let pathField = NSTextField(frame: NSRect(x: 0, y: 0, width: 220, height: 28))
        pathField.stringValue = "~/Library/Application Support/Roblox"
        pathField.isEditable = false
        pathField.textColor = NSColor(calibratedRed: 0.70, green: 0.70, blue: 0.78, alpha: 1.0)
        pathField.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        pathField.wantsLayer = true
        pathField.layer?.backgroundColor = NSColor(calibratedRed: 0.173, green: 0.169, blue: 0.204, alpha: 1.0).cgColor
        pathField.layer?.cornerRadius = 4
        let optPath = createOptionControl(header: "Install location", hasHelpBadge: false, desc: "Where Roblox client files and mods are stored.", control: pathField)
        stack.addArrangedSubview(optPath)
        
        let shortcutSwitch = FluentToggleSwitch(frame: NSRect(x: 0, y: 0, width: 44, height: 22))
        shortcutSwitch.isOn = true
        let optShort = createOptionControl(header: "Create desktop shortcuts", hasHelpBadge: false, desc: "Add quick launch icons for Roblox Player and Bloxstrap Menu.", control: shortcutSwitch)
        stack.addArrangedSubview(optShort)
        return scrollView
    }
    
    // MARK: - Helper UI Builders
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
    
    // Exact Bloxstrap CardAction
    private func createCardAction(frame: NSRect, icon: String, title: String, desc: String, action: Selector) -> NSButton {
        let btn = NSButton(frame: frame)
        btn.title = ""
        btn.isBordered = false
        btn.wantsLayer = true
        btn.layer?.backgroundColor = NSColor(calibratedRed: 0.145, green: 0.141, blue: 0.176, alpha: 1.0).cgColor // #25242D
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
    
    // Exact Bloxstrap OptionControl Card with Question Mark (?) badge
    private func createOptionControl(header: String, hasHelpBadge: Bool = false, desc: String, control: NSView, height: CGFloat = 64) -> NSView {
        let card = createOptionCard(height: height)
        
        let t = NSTextField(labelWithString: header)
        t.font = .systemFont(ofSize: 13, weight: .semibold)
        t.textColor = .white
        t.sizeToFit()
        t.frame.origin = CGPoint(x: 14, y: height - 26)
        card.addSubview(t)
        
        if hasHelpBadge {
            // Circular (?) Help Badge
            let badge = NSView(frame: NSRect(x: t.frame.maxX + 6, y: height - 24, width: 15, height: 15))
            badge.wantsLayer = true
            badge.layer?.backgroundColor = NSColor(calibratedRed: 0.173, green: 0.169, blue: 0.204, alpha: 1.0).cgColor
            badge.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.15).cgColor
            badge.layer?.borderWidth = 1.0
            badge.layer?.cornerRadius = 7.5
            
            let q = NSTextField(labelWithString: "?")
            q.font = .boldSystemFont(ofSize: 9)
            q.textColor = NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.82, alpha: 1.0)
            q.alignment = .center
            q.frame = NSRect(x: 0, y: -0.5, width: 15, height: 15)
            badge.addSubview(q)
            card.addSubview(badge)
        }
        
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
        card.layer?.backgroundColor = NSColor(calibratedRed: 0.145, green: 0.141, blue: 0.176, alpha: 1.0).cgColor // #25242D
        card.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.06).cgColor
        card.layer?.borderWidth = 1.0
        card.layer?.cornerRadius = 6
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: height).isActive = true
        card.widthAnchor.constraint(equalToConstant: 720).isActive = true
        return card
    }
    
    private func createStyledPopup(items: [String], selected: String) -> NSPopUpButton {
        let popup = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 185, height: 28))
        popup.addItems(withTitles: items)
        if items.contains(selected) {
            popup.selectItem(withTitle: selected)
        }
        return popup
    }
    
    private func createActionPill(frame: NSRect, icon: String, title: String, url: String) -> NSButton {
        let btn = NSButton(frame: frame)
        btn.title = "  \(icon)  \(title)"
        btn.isBordered = false
        btn.wantsLayer = true
        btn.layer?.backgroundColor = NSColor(calibratedRed: 0.173, green: 0.169, blue: 0.204, alpha: 1.0).cgColor // #2B2A34
        btn.layer?.borderColor = NSColor(calibratedWhite: 1.0, alpha: 0.10).cgColor
        btn.layer?.borderWidth = 1.0
        btn.layer?.cornerRadius = 4
        btn.font = .systemFont(ofSize: 11.5, weight: .medium)
        btn.contentTintColor = .white
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
                kBtn.isBordered = false
                kBtn.wantsLayer = true
                kBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.22, green: 0.21, blue: 0.26, alpha: 1.0).cgColor
                kBtn.layer?.cornerRadius = 4
                kBtn.font = .systemFont(ofSize: 10, weight: .bold)
                kBtn.contentTintColor = .white
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
    
    private func renderAccountsList() {
        guard accountsStackView != nil else { return }
        accountsStackView.subviews.forEach { $0.removeFromSuperview() }
        
        for acc in AppState.shared.data.accounts {
            let row = NSView(frame: NSRect(x: 0, y: 0, width: 670, height: 26))
            row.wantsLayer = true
            row.layer?.backgroundColor = NSColor(calibratedRed: 0.173, green: 0.169, blue: 0.204, alpha: 1.0).cgColor
            row.layer?.cornerRadius = 4
            
            let icon = NSTextField(labelWithString: "👤")
            icon.font = .systemFont(ofSize: 11)
            icon.frame = NSRect(x: 8, y: 5, width: 20, height: 16)
            row.addSubview(icon)
            
            let nameLbl = NSTextField(labelWithString: "\(acc.displayName) (@\(acc.username))")
            nameLbl.font = .boldSystemFont(ofSize: 11)
            nameLbl.textColor = .white
            nameLbl.frame = NSRect(x: 30, y: 5, width: 330, height: 16)
            row.addSubview(nameLbl)
            
            let dateLbl = NSTextField(labelWithString: "Added \(acc.addedDate)")
            dateLbl.font = .systemFont(ofSize: 10)
            dateLbl.textColor = NSColor(calibratedRed: 0.60, green: 0.60, blue: 0.68, alpha: 1.0)
            dateLbl.frame = NSRect(x: 380, y: 5, width: 150, height: 16)
            row.addSubview(dateLbl)
            
            let launchBtn = NSButton(frame: NSRect(x: 550, y: 2, width: 110, height: 22))
            launchBtn.title = "▶ Launch Alt"
            launchBtn.isBordered = false
            launchBtn.wantsLayer = true
            launchBtn.layer?.backgroundColor = NSColor(calibratedRed: 0.22, green: 0.21, blue: 0.26, alpha: 1.0).cgColor
            launchBtn.layer?.cornerRadius = 4
            launchBtn.font = .systemFont(ofSize: 9.5, weight: .bold)
            launchBtn.contentTintColor = .white
            launchBtn.target = self
            launchBtn.action = #selector(onLaunchInstance)
            row.addSubview(launchBtn)
            
            accountsStackView.addArrangedSubview(row)
        }
    }
    
    @objc private func onAddAltProfile() {
        let count = AppState.shared.data.accounts.count + 1
        let newAcc = AppState.AccountProfile(
            username: "AltAccount_\(count)",
            displayName: "Alt Profile #\(count)",
            addedDate: "2026-10-22"
        )
        AppState.shared.data.accounts.append(newAcc)
        AppState.shared.save()
        renderAccountsList()
    }
}
