import AppKit
import AVFoundation
@preconcurrency import WebKit

public class MainWindowController: NSWindowController, WKNavigationDelegate, WKScriptMessageHandler {
    
    private var webView: WKWebView!
    private var instanceTimer: Timer?
    
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
        window.backgroundColor = NSColor(calibratedRed: 0.122, green: 0.118, blue: 0.149, alpha: 1.0) // Mica Dark #1F1E24
        window.minSize = NSSize(width: 960, height: 560)
        
        // Hide standard macOS traffic lights to present Windows 11 Fluent frame
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        super.init(window: window)
        setupWebView()
        
        // Instance polling timer
        instanceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.pushStateToWeb()
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        instanceTimer?.invalidate()
    }
    
    private func setupWebView() {
        guard let contentView = window?.contentView else { return }
        
        let config = WKWebViewConfiguration()
        let userContent = WKUserContentController()
        userContent.add(self, name: "bloxstrap")
        config.userContentController = userContent
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        webView = WKWebView(frame: contentView.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        webView.setValue(false, forKey: "drawsBackground") // Transparent backdrop
        
        contentView.addSubview(webView)
        loadUI()
    }
    
    private func loadUI() {
        // 1. Try App Bundle Resources
        if let bundleUrl = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "ui") {
            webView.loadFileURL(bundleUrl, allowingReadAccessTo: bundleUrl.deletingLastPathComponent())
            return
        }
        
        // 2. Try adjacent Resources directory
        let localPath = "/Users/t4cs/Documents/antigravity/lively-bell/Bloxstrap-Mac/Resources/ui/index.html"
        let fileUrl = URL(fileURLWithPath: localPath)
        if FileManager.default.fileExists(atPath: localPath) {
            webView.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl.deletingLastPathComponent())
            return
        }
        
        print("❌ Could not find ui/index.html")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pushStateToWeb()
    }
    
    // MARK: - Script Message Handler (Bridge to JS)
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "bloxstrap", let body = message.body as? [String: Any] else { return }
        let action = body["action"] as? String ?? ""
        
        switch action {
        case "appReady":
            pushStateToWeb()
            
        case "saveSettings":
            if let targetFps = body["targetFps"] as? Int {
                AppState.shared.data.targetFps = targetFps
                FastFlagManager.shared.setFlag(key: "DFIntTaskSchedulerTargetFps", value: targetFps)
            }
            if let lighting = body["preferredLighting"] as? String {
                AppState.shared.data.preferredLighting = lighting
            }
            if let escMenu = body["escapeMenuVersion"] as? String {
                AppState.shared.data.escapeMenuVersion = escMenu
            }
            if let hideGuis = body["hideGuisEnabled"] as? Bool {
                AppState.shared.data.hideGuisEnabled = hideGuis
                if hideGuis {
                    FastFlagManager.shared.setFlag(key: "DFIntCanHideGuiGroupId", value: 34970455)
                } else {
                    FastFlagManager.shared.removeFlag(key: "DFIntCanHideGuiGroupId")
                }
            }
            if let renderingMode = body["renderingMode"] as? String {
                AppState.shared.data.renderingMode = renderingMode
            }
            if let exclusiveFullscreen = body["exclusiveFullscreen"] as? Bool {
                AppState.shared.data.exclusiveFullscreen = exclusiveFullscreen
            }
            if let altQuality = body["alternateQualitySelector"] as? Bool {
                AppState.shared.data.alternateQualitySelector = altQuality
            }
            if let inGameMenu = body["inGameMenuVersion"] as? String {
                AppState.shared.data.inGameMenuVersion = inGameMenu
            }
            if let disableFso = body["disableFullscreenOptimizations"] as? Bool {
                AppState.shared.data.disableFullscreenOptimizations = disableFso
            }
            AppState.shared.save()
            webView.evaluateJavaScript("window.onSettingsSaved && window.onSettingsSaved();", completionHandler: nil)
            
        case "playOof":
            SoundManager.shared.playPreview()
            
        case "toggleOof":
            if let enabled = body["enabled"] as? Bool {
                AppState.shared.data.customDeathSound = enabled
                AppState.shared.save()
                if enabled {
                    _ = SoundManager.shared.installOofIntoRoblox()
                    SoundManager.shared.playPreview()
                } else {
                    _ = SoundManager.shared.restoreOriginalSound()
                }
            }
            
        case "launchInstance":
            _ = MultiInstanceManager.shared.launchNewInstance()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.pushStateToWeb()
            }
            
        case "killInstance":
            if let pid = body["pid"] as? Int32 {
                kill(pid, SIGTERM)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.pushStateToWeb()
                }
            }
            
        case "killAllInstances":
            _ = MultiInstanceManager.shared.terminateAllInstances()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.pushStateToWeb()
            }
            
        case "addAccount":
            let count = AppState.shared.data.accounts.count + 1
            let newAcc = AppState.AccountProfile(
                username: "AltAccount_\(count)",
                displayName: "Alt Profile #\(count)",
                addedDate: "2026-10-23"
            )
            AppState.shared.data.accounts.append(newAcc)
            AppState.shared.save()
            pushStateToWeb()
            
        case "verifyKey":
            if let key = body["key"] as? String {
                let success = AppState.shared.verifyAndApplyKey(key)
                if success {
                    pushStateToWeb()
                } else {
                    webView.evaluateJavaScript("document.getElementById('modalDetectedTier').textContent = '❌ Invalid key! Must begin with GOLD-7DAY-';", completionHandler: nil)
                }
            }
            
        case "deauthenticate":
            AppState.shared.deauthenticate()
            pushStateToWeb()
            
        case "closeWindow":
            window?.performClose(nil)
            
        case "minimizeWindow":
            window?.miniaturize(nil)
            
        case "maximizeWindow":
            window?.zoom(nil)
            
        case "openHelp", "openFastFlagHelp":
            if let u = URL(string: "https://bloxstraplabs.com/wiki/features/fastflags/") {
                NSWorkspace.shared.open(u)
            }
            
        case "openStore":
            if let u = URL(string: "https://bloxstrapgold.github.io#pricing") {
                NSWorkspace.shared.open(u)
            }
            
        case "openFastFlagEditor":
            let folder = FastFlagManager.shared.clientSettingsURL.deletingLastPathComponent()
            NSWorkspace.shared.selectFile(FastFlagManager.shared.clientSettingsURL.path, inFileViewerRootedAtPath: folder.path)
            
        case "openShortcutsHelp":
            if let u = URL(string: "https://bloxstraplabs.com/wiki/") {
                NSWorkspace.shared.open(u)
            }
            
        case "openGroupLink":
            if let u = URL(string: "https://www.roblox.com/communities/34970455/catfries-production-company#!/about") {
                NSWorkspace.shared.open(u)
            }
            
        case "openFsoLink":
            if let u = URL(string: "https://devblogs.microsoft.com/directx/demystifying-full-screen-optimizations/") {
                NSWorkspace.shared.open(u)
            }
            
        case "openContributors":
            if let u = URL(string: "https://github.com/Bloxstrap-Gold/Bloxstrap-Gold/graphs/contributors") {
                NSWorkspace.shared.open(u)
            }
            
        default:
            break
        }
    }
    
    private func pushStateToWeb() {
        let pids = MultiInstanceManager.shared.getRunningInstances()
        var instancesPayload: [[String: Any]] = []
        for pid in pids {
            let ram = MultiInstanceManager.shared.getMemoryForPid(pid: pid)
            instancesPayload.append(["pid": pid, "ram": ram])
        }
        
        var accountsPayload: [[String: Any]] = []
        for acc in AppState.shared.data.accounts {
            accountsPayload.append([
                "username": acc.username,
                "displayName": acc.displayName,
                "addedDate": acc.addedDate
            ])
        }
        
        let stateObj: [String: Any] = [
            "isAuthenticated": AppState.shared.isAuthenticated,
            "currentTierName": AppState.shared.currentTierName,
            "currentTierBadge": AppState.shared.currentTierBadge,
            "currentTierPrice": AppState.shared.currentTierPrice,
            "vipKey": AppState.shared.data.vipKey ?? "",
            "targetFps": AppState.shared.data.targetFps,
            "preferredLighting": AppState.shared.data.preferredLighting,
            "escapeMenuVersion": AppState.shared.data.escapeMenuVersion,
            "hideGuisEnabled": AppState.shared.data.hideGuisEnabled,
            "renderingMode": AppState.shared.data.renderingMode,
            "exclusiveFullscreen": AppState.shared.data.exclusiveFullscreen,
            "alternateQualitySelector": AppState.shared.data.alternateQualitySelector,
            "inGameMenuVersion": AppState.shared.data.inGameMenuVersion,
            "disableFullscreenOptimizations": AppState.shared.data.disableFullscreenOptimizations,
            "customDeathSound": AppState.shared.data.customDeathSound,
            "instances": instancesPayload,
            "accounts": accountsPayload
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: stateObj, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let js = "window.updateStateFromHost && window.updateStateFromHost(\(jsonString));"
            DispatchQueue.main.async { [weak self] in
                self?.webView.evaluateJavaScript(js, completionHandler: nil)
            }
        }
    }
    
    public func handleDeepLinkActivation(key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if AppState.shared.verifyAndApplyKey(trimmed) {
            pushStateToWeb()
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc public func showAboutTab() {
        webView.evaluateJavaScript("document.querySelector('[data-tab=\"about\"]').click();", completionHandler: nil)
    }
}
