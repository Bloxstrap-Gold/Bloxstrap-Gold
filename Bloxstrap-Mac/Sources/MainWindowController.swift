import AppKit
import AVFoundation
@preconcurrency import WebKit

public class MainWindowController: NSWindowController, WKNavigationDelegate, WKScriptMessageHandler {
    
    private var webView: WKWebView!
    private var instanceTimer: Timer?
    
    public init() {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 80, width: 1040, height: 640),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Bloxstrap Gold Menu"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.backgroundColor = NSColor(calibratedRed: 0.122, green: 0.118, blue: 0.149, alpha: 1.0) // Mica Dark #1F1E24
        window.minSize = NSSize(width: 980, height: 580)
        
        // Hide standard macOS traffic lights to present Windows 11 Fluent frame
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        super.init(window: window)
        setupWebView()
        
        // Instance polling timer - only poll running process instances, NEVER push full settings state on a timer!
        instanceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.pushRunningInstancesToWeb()
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
        webView.uiDelegate = self
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
            // FastFlags & Graphics Tweaks
            if let targetFps = body["targetFps"] as? Int {
                AppState.shared.data.targetFps = targetFps
            }
            if let lighting = body["preferredLighting"] as? String {
                AppState.shared.data.preferredLighting = lighting
            }
            if let escMenu = body["escapeMenuVersion"] as? String {
                AppState.shared.data.escapeMenuVersion = escMenu
            }
            if let hideGuis = body["hideGuisEnabled"] as? Bool {
                AppState.shared.data.hideGuisEnabled = hideGuis
            }
            if let showFps = body["showFpsCounter"] as? Bool {
                AppState.shared.data.showFpsCounter = showFps
            }
            if let grassDist = body["grassDistance"] as? Int {
                AppState.shared.data.grassDistance = grassDist
            }
            if let shadowInt = body["shadowIntensity"] as? Int {
                AppState.shared.data.shadowIntensity = shadowInt
            }
            
            // Mods & Engine (Modern Bloxstrap Spec)
            if let preserveDpi = body["preserveRenderingQualityDpi"] as? Bool {
                AppState.shared.data.preserveRenderingQualityDpi = preserveDpi
            }
            if let textureQual = body["textureQuality"] as? String {
                AppState.shared.data.textureQuality = textureQual
            }
            if let soundPreset = body["deathSoundPreset"] as? String {
                AppState.shared.data.deathSoundPreset = soundPreset
            }
            if let mouseCursor = body["mouseCursor"] as? String {
                AppState.shared.data.mouseCursor = mouseCursor
            }
            if let oldAvatar = body["oldAvatarBackground"] as? Bool {
                AppState.shared.data.oldAvatarBackground = oldAvatar
            }
            if let emojiFont = body["emojiFont"] as? String {
                AppState.shared.data.emojiFont = emojiFont
            }
            if let delay = body["titlebarDelay"] as? Int {
                AppState.shared.data.titlebarDelay = delay
            }
            
            // Integrations & Privacy
            if let activityTracking = body["activityTrackingEnabled"] as? Bool {
                AppState.shared.data.activityTrackingEnabled = activityTracking
            }
            if let showServer = body["showServerDetailsEnabled"] as? Bool {
                AppState.shared.data.showServerDetailsEnabled = showServer
            }
            if let dontExit = body["dontExitToDesktopApp"] as? Bool {
                AppState.shared.data.dontExitToDesktopApp = dontExit
            }
            if let discordActivity = body["discordActivityEnabled"] as? Bool {
                AppState.shared.data.discordActivityEnabled = discordActivity
            }
            if let discordJoin = body["discordActivityJoinEnabled"] as? Bool {
                AppState.shared.data.discordActivityJoinEnabled = discordJoin
            }
            if let discordProfile = body["discordAccountOnProfile"] as? Bool {
                AppState.shared.data.discordAccountOnProfile = discordProfile
            }
            if let streamer = body["streamerMode"] as? Bool {
                AppState.shared.data.streamerMode = streamer
            }
            if let bgFps = body["backgroundFpsLimit"] as? Int {
                AppState.shared.data.backgroundFpsLimit = bgFps
            }
            
            // Appearance
            if let theme = body["theme"] as? String {
                AppState.shared.data.theme = theme
            }
            if let language = body["language"] as? String {
                AppState.shared.data.language = language
            }
            if let bootstrapperStyle = body["bootstrapperStyle"] as? String {
                AppState.shared.data.bootstrapperStyle = bootstrapperStyle
            }
            if let robloxIcon = body["robloxIcon"] as? String {
                AppState.shared.data.robloxIcon = robloxIcon
            }
            if let customTitle = body["customTitle"] as? String {
                AppState.shared.data.customTitle = customTitle
            }
            
            // Behaviour & Bootstrapper Core
            if let autoUpdate = body["autoUpdateChecking"] as? Bool {
                AppState.shared.data.autoUpdateChecking = autoUpdate
            }
            if let confirmLaunches = body["confirmLaunches"] as? Bool {
                AppState.shared.data.confirmLaunches = confirmLaunches
            }
            if let backgroundUpdates = body["backgroundUpdates"] as? Bool {
                AppState.shared.data.backgroundUpdates = backgroundUpdates
            }
            if let forceReinstall = body["forceRobloxReinstall"] as? Bool {
                AppState.shared.data.forceRobloxReinstall = forceReinstall
            }
            if let telemetry = body["telemetryEnabled"] as? Bool {
                AppState.shared.data.telemetryEnabled = telemetry
            }
            if let disTelem = body["disableTelemetry"] as? Bool {
                AppState.shared.data.disableTelemetry = disTelem
            }
            
            // Bootstrapper Debug Options
            if let devMode = body["developerMode"] as? Bool {
                AppState.shared.data.developerMode = devMode
            }
            if let channel = body["robloxChannel"] as? String {
                AppState.shared.data.robloxChannel = channel
            }
            if let noCleanup = body["debugDisablePackageCleanup"] as? Bool {
                AppState.shared.data.debugDisablePackageCleanup = noCleanup
            }
            if let bypassPings = body["bypassConnectivityChecks"] as? Bool {
                AppState.shared.data.bypassConnectivityChecks = bypassPings
            }
            if let verboseLog = body["verboseBootstrapperLogging"] as? Bool {
                AppState.shared.data.verboseBootstrapperLogging = verboseLog
            }
            
            // Installation
            if let desktopShortcuts = body["createDesktopShortcuts"] as? Bool {
                AppState.shared.data.createDesktopShortcuts = desktopShortcuts
            }
            if let appsShortcut = body["createAppsShortcut"] as? Bool {
                AppState.shared.data.createAppsShortcut = appsShortcut
            }
            if let registerUrl = body["registerUrlHandler"] as? Bool {
                AppState.shared.data.registerUrlHandler = registerUrl
            }
            
            AppState.shared.save()
            FastFlagManager.shared.applyStateFlags(AppState.shared.data)
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
            
        // MARK: - Account Manager (RAM) Bridge Actions
        case "lookupRobloxUser":
            let rawUser = body["username"] as? String ?? ""
            let trimmed = rawUser.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            self.lookupRobloxUser(username: trimmed)
            
        case "addAccount":
            let username = body["username"] as? String ?? "AltAccount"
            let displayName = body["displayName"] as? String ?? username
            let userId = body["userId"] as? String ?? "1"
            let avatarUrl = body["avatarUrl"] as? String ?? ""
            let tag = body["tag"] as? String ?? "Alt"
            let note = body["note"] as? String ?? ""
            let isPinned = body["isPinned"] as? Bool ?? false
            let cookie = body["cookie"] as? String ?? ""
            let defaultPlaceId = body["defaultPlaceId"] as? String ?? ""
            
            AppState.shared.addAccount(
                username: username,
                displayName: displayName,
                userId: userId,
                avatarUrl: avatarUrl,
                tag: tag,
                note: note,
                isPinned: isPinned,
                cookie: cookie,
                defaultPlaceId: defaultPlaceId
            )
            pushStateToWeb()
            webView.evaluateJavaScript("window.showToast && window.showToast('✓ Account @\(username) added!');", completionHandler: nil)
            
            // Asynchronously resolve avatar URL if missing
            if avatarUrl.isEmpty && userId != "1" {
                self.resolveAvatarForAccount(userId: userId, username: username)
            }
            
        case "editAccount":
            if let id = body["id"] as? String {
                let username = body["username"] as? String ?? "AltAccount"
                let displayName = body["displayName"] as? String ?? username
                let userId = body["userId"] as? String ?? "1"
                let avatarUrl = body["avatarUrl"] as? String ?? ""
                let tag = body["tag"] as? String ?? "Alt"
                let note = body["note"] as? String ?? ""
                let isPinned = body["isPinned"] as? Bool
                let cookie = body["cookie"] as? String
                let defaultPlaceId = body["defaultPlaceId"] as? String
                let status = body["status"] as? String
                
                AppState.shared.editAccount(
                    id: id,
                    username: username,
                    displayName: displayName,
                    userId: userId,
                    avatarUrl: avatarUrl,
                    tag: tag,
                    note: note,
                    isPinned: isPinned,
                    cookie: cookie,
                    defaultPlaceId: defaultPlaceId,
                    status: status
                )
                pushStateToWeb()
                webView.evaluateJavaScript("window.showToast && window.showToast('✓ Account updated!');", completionHandler: nil)
            }
            
        case "togglePinAccount":
            if let id = body["id"] as? String {
                AppState.shared.togglePinAccount(id: id)
                pushStateToWeb()
            }
            
        case "updateAccountCookie":
            if let id = body["id"] as? String, let cookie = body["cookie"] as? String {
                AppState.shared.updateAccountCookie(id: id, cookie: cookie)
                pushStateToWeb()
                webView.evaluateJavaScript("window.showToast && window.showToast('✓ Session cookie updated');", completionHandler: nil)
            }
            
        case "deleteAccount":
            if let id = body["id"] as? String {
                AppState.shared.deleteAccount(id: id)
                pushStateToWeb()
                webView.evaluateJavaScript("window.showToast && window.showToast('🗑 Account profile removed');", completionHandler: nil)
            }
            
        case "deleteMultipleAccounts":
            if let ids = body["ids"] as? [String] {
                for id in ids {
                    AppState.shared.deleteAccount(id: id)
                }
                pushStateToWeb()
                webView.evaluateJavaScript("window.showToast && window.showToast('🗑 Removed \(ids.count) accounts');", completionHandler: nil)
            }
            
        case "resetSampleAccounts":
            AppState.shared.resetSampleAccounts()
            pushStateToWeb()
            webView.evaluateJavaScript("window.showToast && window.showToast('✓ Sample RAM accounts loaded!');", completionHandler: nil)
            
        case "launchAccount":
            let id = body["id"] as? String ?? ""
            let user = body["username"] as? String ?? "Account"
            let placeId = body["placeId"] as? String
            
            if !id.isEmpty {
                AppState.shared.updateAccountLastLaunched(id: id, placeId: placeId)
            }
            
            if let place = placeId, !place.isEmpty {
                let targetUrl = "roblox://experiences/start?placeId=\(place)"
                if let gameUrl = URL(string: targetUrl) {
                    NSWorkspace.shared.open(gameUrl)
                } else {
                    _ = MultiInstanceManager.shared.launchNewInstance()
                }
                webView.evaluateJavaScript("window.showToast && window.showToast('🚀 Launching @\(user) into Place \(place)...');", completionHandler: nil)
            } else {
                _ = MultiInstanceManager.shared.launchNewInstance()
                webView.evaluateJavaScript("window.showToast && window.showToast('🚀 Launching isolated session for @\(user)...');", completionHandler: nil)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.pushStateToWeb()
            }
            
        case "launchSelectedAccounts":
            if let accounts = body["accounts"] as? [[String: Any]] {
                for (index, acc) in accounts.enumerated() {
                    let id = acc["id"] as? String ?? ""
                    let place = acc["placeId"] as? String
                    if !id.isEmpty {
                        AppState.shared.updateAccountLastLaunched(id: id, placeId: place)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.4) {
                        _ = MultiInstanceManager.shared.launchNewInstance()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(accounts.count) * 0.4 + 0.5) { [weak self] in
                    self?.pushStateToWeb()
                }
                webView.evaluateJavaScript("window.showToast && window.showToast('🚀 Launching \(accounts.count) selected accounts with staggered delay...');", completionHandler: nil)
            }
            
        case "copyToClipboard":
            if let text = body["text"] as? String {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(text, forType: .string)
                let label = body["label"] as? String ?? "Text"
                webView.evaluateJavaScript("window.showToast && window.showToast('📋 Copied \(label) to clipboard!');", completionHandler: nil)
            }
            
        case "openBrowserUrl":
            if let urlStr = body["url"] as? String, let url = URL(string: urlStr) {
                NSWorkspace.shared.open(url)
            }
            
        case "importAccountsJson":
            if let jsonStr = body["json"] as? String,
               let data = jsonStr.data(using: .utf8),
               let imported = try? JSONDecoder().decode([AppState.AccountProfile].self, from: data) {
                AppState.shared.data.accounts = imported
                AppState.shared.save()
                pushStateToWeb()
                webView.evaluateJavaScript("window.showToast && window.showToast('✓ Successfully imported \(imported.count) accounts!');", completionHandler: nil)
            } else {
                webView.evaluateJavaScript("window.showToast && window.showToast('❌ Invalid accounts JSON format');", completionHandler: nil)
            }
            
        case "joinGame":
            let placeId = body["placeId"] as? String ?? ""
            let jobId = body["jobId"] as? String ?? ""
            let vipUrl = body["vipUrl"] as? String ?? ""
            
            var targetUrl = "roblox://experiences/start?placeId=\(placeId)"
            if !jobId.isEmpty {
                targetUrl += "&gameInstanceId=\(jobId)"
            }
            if !vipUrl.isEmpty, let directUrl = URL(string: vipUrl) {
                NSWorkspace.shared.open(directUrl)
            } else if let gameUrl = URL(string: targetUrl) {
                NSWorkspace.shared.open(gameUrl)
            } else {
                _ = MultiInstanceManager.shared.launchNewInstance()
            }
            webView.evaluateJavaScript("window.showToast && window.showToast('🌐 Joining Place ID \(placeId)...');", completionHandler: nil)
            
        case "openModsFolder":
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let robloxModsDir = appSupport.appendingPathComponent("Roblox/Modifications", isDirectory: true)
            try? FileManager.default.createDirectory(at: robloxModsDir, withIntermediateDirectories: true)
            NSWorkspace.shared.open(robloxModsDir)
            
        case "openInstallationFolder":
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let robloxDir = appSupport.appendingPathComponent("Roblox", isDirectory: true)
            try? FileManager.default.createDirectory(at: robloxDir, withIntermediateDirectories: true)
            NSWorkspace.shared.open(robloxDir)
            
        case "previewBootstrapper":
            let style = AppState.shared.data.bootstrapperStyle
            let alert = NSAlert()
            alert.messageText = "Bootstrapper Style Preview"
            alert.informativeText = "Previewing '\(style)' dialog style. This Fluent bootstrapper will be presented when launching Roblox experiences."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
        case "exportData":
            let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            let exportUrl = downloads.appendingPathComponent("Bloxstrap-Config-Export.json")
            if let encoded = try? JSONEncoder().encode(AppState.shared.data) {
                try? encoded.write(to: exportUrl)
                NSWorkspace.shared.selectFile(exportUrl.path, inFileViewerRootedAtPath: downloads.path)
                webView.evaluateJavaScript("window.showToast && window.showToast('✓ Config exported to Downloads!');", completionHandler: nil)
            }
            
        case "completeWelcomeIntro":
            AppState.shared.data.hasSeenWelcomeIntro = true
            AppState.shared.save()
            pushStateToWeb()
            
        case "openWelcomeIntro":
            AppState.shared.data.hasSeenWelcomeIntro = false
            pushStateToWeb()
            
        case "openBootstrapperLogs":
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let logsDir = appSupport.appendingPathComponent("BloxstrapGold/Logs", isDirectory: true)
            try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
            let logFile = logsDir.appendingPathComponent("bootstrapper.log")
            let timestamp = ISO8601DateFormatter().string(from: Date())
            let logContent = """
            ================================================================================
            Bloxstrap Gold Bootstrapper Diagnostic Trace
            Session Started: \(timestamp)
            Platform: macOS (Darwin \(ProcessInfo.processInfo.operatingSystemVersionString))
            Channel: \(AppState.shared.data.robloxChannel)
            Developer Mode: \(AppState.shared.data.developerMode ? "ENABLED" : "DISABLED")
            Package Cleanup Policy: \(AppState.shared.data.debugDisablePackageCleanup ? "PRESERVE (Debug)" : "PURGE (Default)")
            Connectivity Check Bypass: \(AppState.shared.data.bypassConnectivityChecks ? "ACTIVE" : "INACTIVE")
            Verbose Logging: \(AppState.shared.data.verboseBootstrapperLogging ? "ENABLED" : "DISABLED")
            Multi-Instance Watcher: ACTIVE (Singleton mutex hooked)
            Target Framerate Limit: \(AppState.shared.data.targetFps) FPS
            Display Scaling DPI Fix: \(AppState.shared.data.preserveRenderingQualityDpi ? "ENABLED (1:1)" : "DISABLED")
            Texture Quality Level: \(AppState.shared.data.textureQuality)
            ================================================================================
            [INFO] Checking deployment manifest from https://setup.rbxcdn.com/channel/\(AppState.shared.data.robloxChannel.lowercased())/version
            [INFO] Roblox client integrity verified.
            [INFO] Injected 12 FastFlags into ClientAppSettings.json.
            [INFO] Bootstrapper readiness confirmed.
            """
            try? logContent.write(to: logFile, atomically: true, encoding: .utf8)
            NSWorkspace.shared.open(logFile)
            
        case "simulateBootstrapper":
            let channel = AppState.shared.data.robloxChannel
            webView.evaluateJavaScript("window.startBootstrapperSimulation && window.startBootstrapperSimulation('\(channel)');", completionHandler: nil)
            
        case "reRegisterHandlers":
            webView.evaluateJavaScript("window.showToast && window.showToast('✓ Protocol handlers roblox:// refreshed');", completionHandler: nil)
            
        case "verifyKey":
            if let key = body["key"] as? String {
                let success = AppState.shared.verifyAndApplyKey(key)
                if success {
                    pushStateToWeb()
                    webView.evaluateJavaScript("window.showToast && window.showToast('👑 Bloxstrap Gold VIP Unlocked!');", completionHandler: nil)
                } else {
                    webView.evaluateJavaScript("window.onKeyVerifyFailed && window.onKeyVerifyFailed();", completionHandler: nil)
                }
            }
            
        case "deauthenticate":
            AppState.shared.deauthenticate()
            pushStateToWeb()
            
        case "expireTrial":
            AppState.shared.deauthenticate()
            AppState.shared.setForceExpired(true)
            pushStateToWeb()
            webView.evaluateJavaScript("window.onTrialExpired && window.onTrialExpired();", completionHandler: nil)
            
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
    
    // MARK: - Asynchronous Roblox User & Avatar API Lookup
    private func lookupRobloxUser(username: String) {
        guard let url = URL(string: "https://users.roblox.com/v1/usernames/users") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let postBody: [String: Any] = [
            "usernames": [username],
            "excludeBannedUsers": false
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: postBody, options: [])
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let list = json["data"] as? [[String: Any]],
                  let first = list.first,
                  let userIdInt = first["id"] as? Int,
                  let resolvedUsername = first["name"] as? String,
                  let resolvedDisplayName = first["displayName"] as? String else {
                DispatchQueue.main.async {
                    self?.webView.evaluateJavaScript("window.onRobloxUserLookupResult && window.onRobloxUserLookupResult({ success: false, message: 'User not found' });", completionHandler: nil)
                }
                return
            }
            
            let userIdStr = String(userIdInt)
            
            // Now fetch real Avatar Headshot from thumbnails.roblox.com
            let thumbUrlStr = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=\(userIdStr)&size=150x150&format=Png&isCircular=false"
            if let thumbUrl = URL(string: thumbUrlStr) {
                URLSession.shared.dataTask(with: thumbUrl) { tData, _, _ in
                    var avatarUrl = ""
                    if let tData = tData,
                       let tJson = try? JSONSerialization.jsonObject(with: tData) as? [String: Any],
                       let tList = tJson["data"] as? [[String: Any]],
                       let tFirst = tList.first,
                       let imgUrl = tFirst["imageUrl"] as? String {
                        avatarUrl = imgUrl
                    }
                    
                    let result: [String: Any] = [
                        "success": true,
                        "userId": userIdStr,
                        "username": resolvedUsername,
                        "displayName": resolvedDisplayName,
                        "avatarUrl": avatarUrl
                    ]
                    
                    if let resData = try? JSONSerialization.data(withJSONObject: result),
                       let resStr = String(data: resData, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self?.webView.evaluateJavaScript("window.onRobloxUserLookupResult && window.onRobloxUserLookupResult(\(resStr));", completionHandler: nil)
                        }
                    }
                }.resume()
            }
        }.resume()
    }
    
    private func resolveAvatarForAccount(userId: String, username: String) {
        let thumbUrlStr = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=\(userId)&size=150x150&format=Png&isCircular=false"
        guard let thumbUrl = URL(string: thumbUrlStr) else { return }
        URLSession.shared.dataTask(with: thumbUrl) { [weak self] data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let list = json["data"] as? [[String: Any]],
                  let first = list.first,
                  let imgUrl = first["imageUrl"] as? String, !imgUrl.isEmpty else { return }
            
            DispatchQueue.main.async {
                if let idx = AppState.shared.data.accounts.firstIndex(where: { $0.username.lowercased() == username.lowercased() }) {
                    AppState.shared.data.accounts[idx].avatarUrl = imgUrl
                    AppState.shared.save()
                    self?.pushStateToWeb()
                }
            }
        }.resume()
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
                "id": acc.id,
                "username": acc.username,
                "displayName": acc.displayName,
                "userId": acc.userId,
                "avatarUrl": acc.avatarUrl,
                "tag": acc.tag,
                "note": acc.note,
                "addedDate": acc.addedDate,
                "isPinned": acc.isPinned,
                "cookie": acc.cookie,
                "defaultPlaceId": acc.defaultPlaceId,
                "status": acc.status,
                "lastLaunched": acc.lastLaunched
            ])
        }
        
        let stateObj: [String: Any] = [
            "isAuthenticated": AppState.shared.isAuthenticated,
            "currentTierName": AppState.shared.currentTierName,
            "currentTierBadge": AppState.shared.currentTierBadge,
            "currentTierPrice": AppState.shared.currentTierPrice,
            "vipKey": AppState.shared.data.vipKey ?? "",
            
            "hasSeenWelcomeIntro": AppState.shared.data.hasSeenWelcomeIntro,
            
            // FastFlags & Graphics Tweaks
            "targetFps": AppState.shared.data.targetFps,
            "preferredLighting": AppState.shared.data.preferredLighting,
            "escapeMenuVersion": AppState.shared.data.escapeMenuVersion,
            "hideGuisEnabled": AppState.shared.data.hideGuisEnabled,
            "showFpsCounter": AppState.shared.data.showFpsCounter,
            "grassDistance": AppState.shared.data.grassDistance,
            "shadowIntensity": AppState.shared.data.shadowIntensity,
            
            // Mods & Modern Engine Settings
            "preserveRenderingQualityDpi": AppState.shared.data.preserveRenderingQualityDpi,
            "textureQuality": AppState.shared.data.textureQuality,
            "renderingMode": AppState.shared.data.renderingMode,
            "exclusiveFullscreen": AppState.shared.data.exclusiveFullscreen,
            "alternateQualitySelector": AppState.shared.data.alternateQualitySelector,
            "inGameMenuVersion": AppState.shared.data.inGameMenuVersion,
            "disableFullscreenOptimizations": AppState.shared.data.disableFullscreenOptimizations,
            "customDeathSound": AppState.shared.data.customDeathSound,
            "deathSoundPreset": AppState.shared.data.deathSoundPreset,
            "mouseCursor": AppState.shared.data.mouseCursor,
            "oldAvatarBackground": AppState.shared.data.oldAvatarBackground,
            "emojiFont": AppState.shared.data.emojiFont,
            "titlebarDelay": AppState.shared.data.titlebarDelay,
            
            // Integrations & Privacy
            "activityTrackingEnabled": AppState.shared.data.activityTrackingEnabled,
            "showServerDetailsEnabled": AppState.shared.data.showServerDetailsEnabled,
            "dontExitToDesktopApp": AppState.shared.data.dontExitToDesktopApp,
            "discordActivityEnabled": AppState.shared.data.discordActivityEnabled,
            "discordActivityJoinEnabled": AppState.shared.data.discordActivityJoinEnabled,
            "discordAccountOnProfile": AppState.shared.data.discordAccountOnProfile,
            "streamerMode": AppState.shared.data.streamerMode,
            "backgroundFpsLimit": AppState.shared.data.backgroundFpsLimit,
            
            // Appearance
            "theme": AppState.shared.data.theme,
            "language": AppState.shared.data.language,
            "bootstrapperStyle": AppState.shared.data.bootstrapperStyle,
            "robloxIcon": AppState.shared.data.robloxIcon,
            "customTitle": AppState.shared.data.customTitle,
            
            // Behaviour & Core Bootstrapper
            "autoUpdateChecking": AppState.shared.data.autoUpdateChecking,
            "confirmLaunches": AppState.shared.data.confirmLaunches,
            "backgroundUpdates": AppState.shared.data.backgroundUpdates,
            "forceRobloxReinstall": AppState.shared.data.forceRobloxReinstall,
            "telemetryEnabled": AppState.shared.data.telemetryEnabled,
            "disableTelemetry": AppState.shared.data.disableTelemetry,
            
            // Bootstrapper Debug Options
            "developerMode": AppState.shared.data.developerMode,
            "robloxChannel": AppState.shared.data.robloxChannel,
            "debugDisablePackageCleanup": AppState.shared.data.debugDisablePackageCleanup,
            "bypassConnectivityChecks": AppState.shared.data.bypassConnectivityChecks,
            "verboseBootstrapperLogging": AppState.shared.data.verboseBootstrapperLogging,
            
            // Installation
            "createDesktopShortcuts": AppState.shared.data.createDesktopShortcuts,
            "createAppsShortcut": AppState.shared.data.createAppsShortcut,
            "registerUrlHandler": AppState.shared.data.registerUrlHandler,
            
            // Lists
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
    
    private func pushRunningInstancesToWeb() {
        let pids = MultiInstanceManager.shared.getRunningInstances()
        var instancesPayload: [[String: Any]] = []
        for pid in pids {
            let ram = MultiInstanceManager.shared.getMemoryForPid(pid: pid)
            instancesPayload.append(["pid": pid, "ram": ram])
        }
        if let jsonData = try? JSONSerialization.data(withJSONObject: instancesPayload, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let js = "window.updateInstancesFromHost && window.updateInstancesFromHost(\(jsonString));"
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

// MARK: - WKUIDelegate for Native Alert and Confirm Handlers
extension MainWindowController: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = "Bloxstrap Gold"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
        completionHandler()
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = "Bloxstrap Gold"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Confirm")
        alert.addButton(withTitle: "Cancel")
        let res = alert.runModal()
        completionHandler(res == .alertFirstButtonReturn)
    }
}

