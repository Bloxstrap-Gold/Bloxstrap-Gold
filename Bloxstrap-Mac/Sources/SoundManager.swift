import AppKit
import AVFoundation

public class SoundManager {
    public static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    public var isRobloxInstalled: Bool {
        return RobloxPathResolver.isRobloxInstalled
    }
    
    public var isCustomSoundInstalled: Bool {
        guard let backup = RobloxPathResolver.backupSoundPath else { return false }
        return FileManager.default.fileExists(atPath: backup)
    }
    
    public func playPreview() {
        // Try playing bundled oof.wav, fallback to synthesized audio
        if let soundURL = Bundle.main.url(forResource: "oof", withExtension: "wav"),
           let player = try? AVAudioPlayer(contentsOf: soundURL) {
            audioPlayer = player
            audioPlayer?.play()
            return
        }
        
        // Adjacent file fallback (when running directly from Sources)
        let localWav = URL(fileURLWithPath: "Bloxstrap-Mac/oof.wav")
        if let player = try? AVAudioPlayer(contentsOf: localWav) {
            audioPlayer = player
            audioPlayer?.play()
            return
        }
        
        NSSound.beep()
    }
    
    public func installOofIntoRoblox() -> (success: Bool, message: String) {
        guard let soundPath = RobloxPathResolver.ouchSoundPath,
              let backupPath = RobloxPathResolver.backupSoundPath else {
            return (false, "Roblox.app sounds directory not found in /Applications or ~/Applications.")
        }
        
        let oggSourceURL: URL?
        if let bundled = Bundle.main.url(forResource: "oof", withExtension: "ogg") {
            oggSourceURL = bundled
        } else {
            let localOgg = URL(fileURLWithPath: "Bloxstrap-Mac/oof.ogg")
            oggSourceURL = FileManager.default.fileExists(atPath: localOgg.path) ? localOgg : nil
        }
        
        guard let sourceURL = oggSourceURL else {
            return (false, "Classic oof.ogg audio asset could not be located in application bundle.")
        }
        
        let fileManager = FileManager.default
        do {
            // Backup original sound if not already backed up
            if !fileManager.fileExists(atPath: backupPath) && fileManager.fileExists(atPath: soundPath) {
                try fileManager.copyItem(atPath: soundPath, toPath: backupPath)
            }
            
            // Replace ouch.ogg with classic oof
            if fileManager.fileExists(atPath: soundPath) {
                try fileManager.removeItem(atPath: soundPath)
            }
            try fileManager.copyItem(at: sourceURL, to: URL(fileURLWithPath: soundPath))
            return (true, "Classic 2006 'OOF' sound installed into Roblox! Original sound backed up.")
        } catch {
            return (false, "Failed to install sound: \(error.localizedDescription)")
        }
    }
    
    public func restoreOriginalSound() -> (success: Bool, message: String) {
        guard let soundPath = RobloxPathResolver.ouchSoundPath,
              let backupPath = RobloxPathResolver.backupSoundPath else {
            return (false, "Roblox.app sounds directory not found.")
        }
        
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: backupPath) else {
            return (false, "No backup sound found (default sound is already active).")
        }
        
        do {
            if fileManager.fileExists(atPath: soundPath) {
                try fileManager.removeItem(atPath: soundPath)
            }
            try fileManager.moveItem(atPath: backupPath, toPath: soundPath)
            return (true, "Restored default Roblox sound.")
        } catch {
            return (false, "Failed to restore: \(error.localizedDescription)")
        }
    }
}
