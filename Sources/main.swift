import AppKit
import ServiceManagement

final class App: NSObject, NSApplicationDelegate {
    let journal = Journal(url: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Meeting Mode/session.json"))
    var session: Session?
    var windows: [NSWindow] = []
    var item: NSStatusItem!
    var catMode = UserDefaults.standard.bool(forKey: "catMode")
    var busy = false
    var timer: Timer?
    var hideDesktop = UserDefaults.standard.object(forKey: "hideDesktop") as? Bool ?? true
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        do { session = try journal.read() } catch { report("Recovery state could not be read: \(error.localizedDescription)") }
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in self?.refresh() }
        NotificationCenter.default.addObserver(self, selector: #selector(displaysChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        if session != nil {
            let alert = NSAlert()
            alert.messageText = "Restore unfinished Meeting Mode?"
            alert.informativeText = "The last session did not finish. Desktop covers have already disappeared. Clear the saved session to return to normal. If an older version changed Focus, check it manually in Control Center."
            alert.addButton(withTitle: "Restore")
            alert.addButton(withTitle: "Later")
            if alert.runModal() == .alertFirstButtonReturn { end() }
        }
    }
    func report(_ message: String) {
        let alert = NSAlert(); alert.messageText = "Meeting Mode"; alert.informativeText = message
        alert.runModal()
    }
    func refresh() {
        item.button?.image = NSImage(systemSymbolName: session == nil ? "video" : "video.fill", accessibilityDescription: "Meeting Mode")
        let menu = NSMenu()
        if let state = session {
            let minutes = max(0, Int(Date().timeIntervalSince(state.started) / 60))
            menu.addItem(withTitle: "Active · \(minutes)m", action: nil, keyEquivalent: "")
        }
        let toggle = menu.addItem(withTitle: session == nil ? "Start Meeting Mode" : "End Meeting Mode", action: #selector(toggle), keyEquivalent: "")
        toggle.target = self; toggle.isEnabled = !busy
        let desktop = menu.addItem(withTitle: "Hide desktop icons and widgets", action: #selector(toggleDesktop), keyEquivalent: "")
        desktop.target = self; desktop.state = hideDesktop ? .on : .off; desktop.isEnabled = session == nil && !busy
        let cat = menu.addItem(withTitle: "Cat Mode", action: #selector(toggleCat), keyEquivalent: "")
        cat.target = self; cat.state = catMode ? .on : .off; cat.isEnabled = !busy
        let login = menu.addItem(withTitle: "Open at login", action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self; login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(.separator())
        let quit = menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self; quit.isEnabled = !busy
        item.menu = menu
    }
    @objc func toggleDesktop() { hideDesktop.toggle(); UserDefaults.standard.set(hideDesktop, forKey: "hideDesktop"); refresh() }
    @objc func toggleCat() {
        catMode.toggle()
        UserDefaults.standard.set(catMode, forKey: "catMode")
        for window in windows { if let view = window.contentView { updateCat(in: view) } }
        refresh()
    }
    func updateCat(in view: NSView) {
        view.subviews.forEach { $0.removeFromSuperview() }
        guard catMode, let url = Bundle.main.url(forResource: "meeting-cat", withExtension: "png"),
              let image = NSImage(contentsOf: url) else { return }
        let height = min(460, view.bounds.height * 0.55)
        let width = min(view.bounds.width * 0.6, height * image.size.width / image.size.height)
        let imageView = NSImageView(frame: NSRect(x: (view.bounds.width - width) / 2,
            y: (view.bounds.height - height) / 2, width: width, height: height))
        imageView.image = image
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        view.addSubview(imageView)
    }
    @objc func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled { try SMAppService.mainApp.unregister() }
            else { try SMAppService.mainApp.register() }
        } catch { report("Login setting failed: \(error.localizedDescription)") }
        refresh()
    }
    @objc func toggle() { if session == nil { start() } else { end() } }
    func start() {
        guard session == nil, !busy else { return }
        let state = Session(started: Date(), focusPending: false)
        do { try journal.save(state) } catch { report("Could not save recovery state. Nothing changed. \(error.localizedDescription)"); return }
        session = state; busy = true; refresh()
        if hideDesktop {
            do { try coverDesktop() } catch { report("Desktop cleanup failed: \(error.localizedDescription). Choose End Meeting Mode to recover.") }
        }
        busy = false; refresh()
    }
    func end(completion: ((Bool) -> Void)? = nil) {
        guard session != nil, !busy else { completion?(session == nil); return }
        busy = true; removeCovers()
        do {
            try journal.clear(); session = nil; busy = false; refresh(); completion?(true)
        } catch {
            busy = false; report("Could not clear recovery state: \(error.localizedDescription)")
            refresh(); completion?(false)
        }
    }
    func coverDesktop() throws {
        removeCovers()
        for screen in NSScreen.screens {
            let window = NSWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.normalWindow)) - 1)
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            window.ignoresMouseEvents = true
            window.isReleasedWhenClosed = false
            let view = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor.black.cgColor
            window.backgroundColor = .black
            window.isOpaque = true
            updateCat(in: view)
            window.contentView = view; window.orderFrontRegardless(); windows.append(window)
        }
    }
    func removeCovers() { windows.forEach { $0.close() }; windows.removeAll() }
    @objc func displaysChanged() {
        guard session != nil, !windows.isEmpty else { return }
        do { try coverDesktop() } catch { report("Desktop coverage failed after a display change: \(error.localizedDescription)") }
    }
    @objc func quit() { NSApp.terminate(nil) }
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard session != nil else { return .terminateNow }
        guard !busy else { return .terminateCancel }
        end()
        return session == nil ? .terminateNow : .terminateCancel
    }
}
let delegate = App()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
