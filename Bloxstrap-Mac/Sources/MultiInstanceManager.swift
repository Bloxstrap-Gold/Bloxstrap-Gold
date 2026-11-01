import Foundation

public class MultiInstanceManager {
    public static let shared = MultiInstanceManager()
    
    public var robloxAppPath: String {
        return RobloxPathResolver.robloxAppPath ?? "/Applications/Roblox.app"
    }
    
    public var isRobloxInstalled: Bool {
        return RobloxPathResolver.isRobloxInstalled
    }
    
    public func getRunningInstances() -> [Int] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        process.arguments = ["-x", "RobloxPlayer"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output.components(separatedBy: .newlines)
                    .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            }
        } catch {}
        return []
    }
    
    public func getMemoryForPid(pid: Int) -> Int {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-o", "rss=", "-p", "\(pid)"]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8),
               let kb = Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return max(120, kb / 1024)
            }
        } catch {}
        return 0
    }
    
    public func launchNewInstance() -> (success: Bool, message: String) {
        guard let appPath = RobloxPathResolver.robloxAppPath else {
            return (false, "Roblox.app not found in /Applications or ~/Applications. Please install official Roblox first.")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        // -n flag opens a brand new, isolated application instance even if one is already running
        process.arguments = ["-n", "-a", appPath]
        
        do {
            try process.run()
            return (true, "New Roblox client process launched!")
        } catch {
            return (false, "Failed to launch: \(error.localizedDescription)")
        }
    }
    
    public func terminateAllInstances() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        process.arguments = ["RobloxPlayer"]
        do {
            try process.run()
            process.waitUntilExit()
            return true
        } catch {
            return false
        }
    }
}
