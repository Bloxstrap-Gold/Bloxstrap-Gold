import AppKit

public class RunawayCanvasView: NSView {
    public var onPaymentFailed: (() -> Void)?
    public var onPayLaterClick: (() -> Void)?
    
    private var payButton: NSButton!
    private var payLaterButton: NSButton!
    private var statusLabel: NSTextField!
    private var progressIndicator: NSProgressIndicator!
    private var isProcessing: Bool = false
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(calibratedRed: 0.12, green: 0.08, blue: 0.08, alpha: 0.85).cgColor
        layer?.cornerRadius = 8
        layer?.borderColor = NSColor(calibratedRed: 0.90, green: 0.35, blue: 0.35, alpha: 0.5).cgColor
        layer?.borderWidth = 1.0
        
        // Stationary "Pay later" button directly available
        payLaterButton = NSButton(frame: NSRect(x: 16, y: 13, width: 130, height: 34))
        payLaterButton.title = "Pay later"
        payLaterButton.bezelStyle = .rounded
        payLaterButton.font = .systemFont(ofSize: 12, weight: .bold)
        payLaterButton.target = self
        payLaterButton.action = #selector(payLaterClicked)
        addSubview(payLaterButton)
        
        // Stationary "PAY FOR IT" button (no cursor evasion per latest spec)
        payButton = NSButton(frame: NSRect(x: 160, y: 13, width: 230, height: 34))
        payButton.title = "💳 PAY FOR IT ($999.99/mo)"
        payButton.bezelStyle = .rounded
        payButton.wantsLayer = true
        payButton.layer?.backgroundColor = NSColor(calibratedRed: 0.98, green: 0.75, blue: 0.14, alpha: 1.0).cgColor
        payButton.contentTintColor = .black
        payButton.font = .systemFont(ofSize: 12, weight: .heavy)
        payButton.target = self
        payButton.action = #selector(payButtonClicked)
        addSubview(payButton)
        
        // Button to open GitHub Pages store directly
        let webBtn = NSButton(frame: NSRect(x: 405, y: 13, width: 235, height: 34))
        webBtn.title = "🌐 Buy on bloxstrapgold.github.io"
        webBtn.bezelStyle = .rounded
        webBtn.font = .systemFont(ofSize: 11, weight: .semibold)
        webBtn.target = self
        webBtn.action = #selector(openWebStore)
        addSubview(webBtn)
        
        // Live processing spinner and status label
        progressIndicator = NSProgressIndicator(frame: NSRect(x: 650, y: 20, width: 20, height: 20))
        progressIndicator.style = .spinning
        progressIndicator.controlSize = .small
        progressIndicator.isHidden = true
        addSubview(progressIndicator)
        
        statusLabel = NSTextField(labelWithString: "")
        statusLabel.font = .systemFont(ofSize: 11, weight: .medium)
        statusLabel.textColor = NSColor(calibratedRed: 0.88, green: 0.75, blue: 0.46, alpha: 0.9)
        statusLabel.frame = NSRect(x: 675, y: 20, width: 220, height: 20)
        statusLabel.isHidden = true
        addSubview(statusLabel)
    }
    
    @objc private func openWebStore() {
        if let url = URL(string: "https://bloxstrapgold.github.io#pricing") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func payButtonClicked() {
        guard !isProcessing else { return }
        isProcessing = true
        
        payButton.isEnabled = false
        payLaterButton.isEnabled = false
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        statusLabel.isHidden = false
        
        // Stage 1: Contacting payment network
        statusLabel.stringValue = "Contacting payment network..."
        
        // Stage 2: Authorizing with card issuer (900ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            guard let self = self, self.isProcessing else { return }
            self.statusLabel.stringValue = "Authorizing with card issuer..."
        }
        
        // Stage 3: Finalizing 3D Secure protocol (1800ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            guard let self = self, self.isProcessing else { return }
            self.statusLabel.stringValue = "Finalizing 3D Secure protocol..."
        }
        
        // Stage 4: Declined error banner (2600ms total latency)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) { [weak self] in
            guard let self = self else { return }
            self.isProcessing = false
            self.payButton.isEnabled = true
            self.payLaterButton.isEnabled = true
            self.progressIndicator.stopAnimation(nil)
            self.progressIndicator.isHidden = true
            self.statusLabel.isHidden = true
            
            self.onPaymentFailed?()
        }
    }
    
    @objc private func payLaterClicked() {
        onPayLaterClick?()
    }
}
