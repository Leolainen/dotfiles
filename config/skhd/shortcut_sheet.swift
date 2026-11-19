import AppKit

final class ShortcutSheet: NSObject, NSApplicationDelegate {
    private var panel: NSPanel!
    private var keyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let size = NSSize(width: 560, height: 460)

        let text = NSTextView()
        text.string = """
        WINDOWS
        ⌃⌥ H/J/K/L       Focus west/south/north/east
        ⇧⌃⌥ H/J/K/L      Swap with neighbor
        ⌃⌥ Arrows        Resize
        ⌃⌥ F             Toggle float
        ⌃⌥ M             Maximize
        ⌃⌥ R / X / Y     Rotate / mirror
        ⌃⌥ 0             Balance layout

        SPACES AND DISPLAYS
        ⌃⌥ 1–9           Focus space
        ⇧⌃⌥ 1–9          Send window to space
        ⌃⌥ W / E / Q     Focus next / previous / recent display
        ⇧⌃⌥ W / E        Send window to next / previous display
        ⇧⌃⌥ ← / →        Send window to previous / next space

        YABAI
        ⇧⌃⌥ R            Restart Yabai (start if stopped)

        APPS
        ⌃⌥ S             Open (S)lack
        ⌃⌥ T             Open (T)erminal (Ghostty)
        ⇧⌃⌥ T            Open new (T)erminal window
        ⌃⌥ B             Open (B)rowser (Chrome)
        ⌃⌥ O             Open (O)bsidian
        ⌃⌥ I             Open System Sett(I)ngs
        ⌃⌥ D             Open (D)ev-agent app (Herdr)
        ⌃⌥ P             Open music (P)layer (Spotify)
        ⌃⌥ G             Open Fi(G)ma
        ⌃⌥ N             Open Teams (key: N)
        ⌃⌥ U             Open Outlook (key: U)

        Esc             Close this sheet
        ⌃⌥ Space        Toggle this sheet
        """
        text.isEditable = false
        text.isSelectable = false
        text.drawsBackground = false
        text.textColor = .labelColor
        text.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        text.textContainerInset = NSSize(width: 22, height: 18)
        text.frame = NSRect(origin: .zero, size: size)
        text.isVerticallyResizable = true
        text.isHorizontallyResizable = false
        text.autoresizingMask = [.width]

        let scrollView = NSScrollView(frame: NSRect(origin: .zero, size: size))
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = false
        scrollView.documentView = text

        panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.title = "Keyboard Shortcuts"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = scrollView
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.keyCode == 53 else { return event }
            NSApp.terminate(nil)
            return nil
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

let application = NSApplication.shared
let shortcutSheet = ShortcutSheet()
application.delegate = shortcutSheet
application.run()
