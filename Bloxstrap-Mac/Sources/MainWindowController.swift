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
        window.title = "Bloxstrap Menu"
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
            // FastFlags
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
            
            // Mods
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
            if let mouseCursor = body["mouseCursor"] as? String {
                AppState.shared.data.mouseCursor = mouseCursor
            }
            if let oldAvatar = body["oldAvatarBackground"] as? Bool {
                AppState.shared.data.oldAvatarBackground = oldAvatar
            }
            if let emojiFont = body["emojiFont"] as? String {
                AppState.shared.data.emojiFont = emojiFont
            }
            
            // Integrations
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
            
            // Behaviour
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
            AppState.shared.addAccount(username: username, displayName: displayName, userId: userId, avatarUrl: avatarUrl, tag: tag, note: note)
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
                AppState.shared.editAccount(id: id, username: username, displayName: displayName, userId: userId, avatarUrl: avatarUrl, tag: tag, note: note)
                pushStateToWeb()
                webView.evaluateJavaScript("window.showToast && window.showToast('✓ Account updated!');", completionHandler: nil)
            }
            
        case "deleteAccount":
            if let id = body["id"] as? String {
                AppState.shared.deleteAccount(id: id)
                pushStateToWeb()
                webView.evaluateJavaScript("window.showToast && window.showToast('🗑 Account profile removed');", completionHandler: nil)
            }
            
        case "resetSampleAccounts":
            AppState.shared.resetSampleAccounts()
            pushStateToWeb()
            webView.evaluateJavaScript("window.showToast && window.showToast('✓ Sample RAM accounts loaded!');", completionHandler: nil)
            
        case "launchAccount":
            _ = MultiInstanceManager.shared.launchNewInstance()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.pushStateToWeb()
            }
            let user = body["username"] as? String ?? "Account"
            webView.evaluateJavaScript("window.showToast && window.showToast('🚀 Launching isolated session for @\(user)...');", completionHandler: nil)
            
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
                "addedDate": acc.addedDate
            ])
        }
        
        let stateObj: [String: Any] = [
            "isAuthenticated": AppState.shared.isAuthenticated,
            "currentTierName": AppState.shared.currentTierName,
            "currentTierBadge": AppState.shared.currentTierBadge,
            "currentTierPrice": AppState.shared.currentTierPrice,
            "vipKey": AppState.shared.data.vipKey ?? "",
            
            // FastFlags
            "targetFps": AppState.shared.data.targetFps,
            "preferredLighting": AppState.shared.data.preferredLighting,
            "escapeMenuVersion": AppState.shared.data.escapeMenuVersion,
            "hideGuisEnabled": AppState.shared.data.hideGuisEnabled,
            
            // Mods
            "renderingMode": AppState.shared.data.renderingMode,
            "exclusiveFullscreen": AppState.shared.data.exclusiveFullscreen,
            "alternateQualitySelector": AppState.shared.data.alternateQualitySelector,
            "inGameMenuVersion": AppState.shared.data.inGameMenuVersion,
            "disableFullscreenOptimizations": AppState.shared.data.disableFullscreenOptimizations,
            "customDeathSound": AppState.shared.data.customDeathSound,
            "mouseCursor": AppState.shared.data.mouseCursor,
            "oldAvatarBackground": AppState.shared.data.oldAvatarBackground,
            "emojiFont": AppState.shared.data.emojiFont,
            
            // Integrations
            "activityTrackingEnabled": AppState.shared.data.activityTrackingEnabled,
            "showServerDetailsEnabled": AppState.shared.data.showServerDetailsEnabled,
            "dontExitToDesktopApp": AppState.shared.data.dontExitToDesktopApp,
            "discordActivityEnabled": AppState.shared.data.discordActivityEnabled,
            "discordActivityJoinEnabled": AppState.shared.data.discordActivityJoinEnabled,
            "discordAccountOnProfile": AppState.shared.data.discordAccountOnProfile,
            
            // Appearance
            "theme": AppState.shared.data.theme,
            "language": AppState.shared.data.language,
            "bootstrapperStyle": AppState.shared.data.bootstrapperStyle,
            "robloxIcon": AppState.shared.data.robloxIcon,
            "customTitle": AppState.shared.data.customTitle,
            
            // Behaviour
            "autoUpdateChecking": AppState.shared.data.autoUpdateChecking,
            "confirmLaunches": AppState.shared.data.confirmLaunches,
            "backgroundUpdates": AppState.shared.data.backgroundUpdates,
            "forceRobloxReinstall": AppState.shared.data.forceRobloxReinstall,
            "telemetryEnabled": AppState.shared.data.telemetryEnabled,
            
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
