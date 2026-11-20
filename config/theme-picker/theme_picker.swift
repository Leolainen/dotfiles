import AppKit
import UniformTypeIdentifiers

private struct ThemeSummary: Decodable {
    let id: String
    let name: String
    let appearance: String
}

private struct Theme: Decodable {
    let name: String
    let appearance: String
    let colors: [String: String]
    let ansi: [String]
    let contrastChecks: [String]
    let wallpaper: Wallpaper?

    struct Wallpaper: Decodable {
        let path: String?

        init(from decoder: Decoder) throws {
            if let path = try? decoder.singleValueContainer().decode(String.self) {
                self.path = path
            } else {
                let fields = try decoder.container(keyedBy: CodingKeys.self)
                path = try fields.decodeIfPresent(String.self, forKey: .path)
            }
        }

        enum CodingKeys: String, CodingKey { case path }
    }
}

private let command = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    .appendingPathComponent("../../scripts/dotfiles-theme").standardizedFileURL

private func run(_ arguments: [String], completion: @escaping (Result<Data, Error>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        let result = Result<Data, Error> {
            let process = Process()
            let pipe = Pipe()
            process.executableURL = command
            process.arguments = arguments
            process.standardOutput = pipe
            process.standardError = pipe
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else {
                throw NSError(domain: "dotfiles-theme", code: Int(process.terminationStatus),
                              userInfo: [NSLocalizedDescriptionKey: String(decoding: data, as: UTF8.self)])
            }
            return data
        }
        DispatchQueue.main.async { completion(result) }
    }
}

private func swatch(_ hex: String) -> NSAttributedString {
    let rgb = Int(hex.dropFirst(), radix: 16) ?? 0
    let color = NSColor(srgbRed: CGFloat(rgb >> 16) / 255,
                        green: CGFloat((rgb >> 8) & 255) / 255,
                        blue: CGFloat(rgb & 255) / 255, alpha: 1)
    return NSAttributedString(string: "■", attributes: [.foregroundColor: color])
}

private struct PixabayPhoto: Codable {
    let id: Int
    let user: String
    let pageURL: URL
    let webformatURL: URL
    let largeImageURL: URL
}

private struct SavedPhoto: Decodable {
    let id: Int
    let pageURL: URL? // Older Pexels records used "url".
    var filename: String { (pageURL == nil ? "pexels-" : "pixabay-") + String(id) + ".jpg" }
}

private func pixabayColor(_ hex: String) -> String {
    let palette = [("red", 0xd83838), ("orange", 0xee8822), ("yellow", 0xeace36),
                   ("green", 0x559246), ("turquoise", 0x47b6ac), ("blue", 0x467fc5),
                   ("lilac", 0xab84cd), ("pink", 0xe598b5), ("white", 0xffffff),
                   ("gray", 0x888888), ("black", 0x181818), ("brown", 0x926342)]
    let rgb = Int(hex.dropFirst(), radix: 16) ?? 0
    func distance(_ candidate: Int) -> Int {
        [16, 8, 0].reduce(0) { sum, shift in
            let delta = ((rgb >> shift) & 255) - ((candidate >> shift) & 255)
            return sum + delta * delta
        }
    }
    return palette.min { distance($0.1) < distance($1.1) }!.0
}

private let photoSession = URLSession(configuration: .ephemeral)

private func fetch(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
    photoSession.dataTask(with: request) { data, response, error in
        let result = Result<Data, Error> {
            if let error = error { throw URLError(URLError.Code(rawValue: (error as NSError).code)) }
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard status == 200, let data = data else {
                let hint = status == 429 ? "Try again after the Pixabay rate limit resets." :
                    status == 400 || status == 401 || status == 403 ? "Check your Pixabay API key." : "Please try again later."
                throw NSError(domain: "Pixabay", code: status, userInfo: [NSLocalizedDescriptionKey: "Pixabay HTTP \(status). " + hint])
            }
            return data
        }
        DispatchQueue.main.async { completion(result) }
    }.resume()
}

private final class Picker: NSObject, NSApplicationDelegate, NSWindowDelegate, NSSearchFieldDelegate, NSTableViewDataSource, NSTableViewDelegate {
    let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 570, height: 525),
                        styleMask: [.titled, .closable], backing: .buffered, defer: false)
    let search = NSSearchField()
    let appearanceFilter = NSSegmentedControl(labels: ["All", "Light", "Dark"], trackingMode: .selectOne, target: nil, action: nil)
    let choices = NSTableView()
    private var filtering = false
    var matches: [ThemeSummary] = []
    let preview = NSTextField(wrappingLabelWithString: "")
    let image = NSImageView()
    let apply = NSButton(title: "Apply theme", target: nil, action: nil)
    let importImage = NSButton(title: "Import image…", target: nil, action: nil)
    private var candidates: [PixabayPhoto] = []
    private var candidateIndex = 0
    private let photoCredit = NSButton()
    private let downloadMatch = NSButton(title: "Download & Set Desktop Picture", target: nil, action: nil)
    private let nextMatch = NSButton(title: "Next match", target: nil, action: nil)
    private let cancelMatch = NSButton(title: "Cancel", target: nil, action: nil)
    private lazy var matchActions = NSStackView(views: [downloadMatch, nextMatch, cancelMatch])
    let findPhoto = NSButton(title: "Find wallpaper…", target: nil, action: nil)
    private var selectedColors: [String: String] = [:]
    private let configHome = URL(fileURLWithPath: ProcessInfo.processInfo.environment["XDG_CONFIG_HOME"]
        ?? NSHomeDirectory() + "/.config").appendingPathComponent("dotfiles")
    private let pictures = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("dotfiles-theme/wallpapers")
    let setDesktop = NSButton(title: "Set desktop picture", target: nil, action: nil)
    let importTheme = NSButton(title: "Import theme…", target: nil, action: nil)
    let exportTheme = NSButton(title: "Export theme…", target: nil, action: nil)
    let restore = NSButton(title: "Restore original files…", target: nil, action: nil)
    var wallpaperURL: URL?
    var themes: [ThemeSummary] = []
    var selectedID: String?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        panel.delegate = self
        panel.title = "Theme Picker"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        search.placeholderString = "Search themes"
        search.delegate = self
        appearanceFilter.selectedSegment = 0
        appearanceFilter.target = self
        appearanceFilter.action = #selector(changeFilter)
        appearanceFilter.setAccessibilityLabel("Filter themes by appearance")
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("theme"))
        column.resizingMask = .autoresizingMask
        choices.addTableColumn(column)
        choices.headerView = nil
        choices.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        choices.dataSource = self
        choices.delegate = self
        let list = NSScrollView()
        list.hasVerticalScroller = true
        list.documentView = choices
        list.heightAnchor.constraint(equalToConstant: 76).isActive = true
        apply.target = self
        apply.action = #selector(applyTheme)
        apply.isEnabled = false
        image.imageScaling = .scaleProportionallyUpOrDown
        image.isHidden = true
        let results = NSTextView.scrollableTextView()
        let log = results.documentView as! NSTextView
        log.isEditable = false
        log.font = .systemFont(ofSize: NSFont.systemFontSize)
        resultView = log
        for (button, action) in [(downloadMatch, #selector(useMatch)), (nextMatch, #selector(advanceMatch)),
                                 (cancelMatch, #selector(cancelMatches)), (photoCredit, #selector(openPhotoCredit(_:)))] {
            button.target = self
            button.action = action
        }
        matchActions.isHidden = true
        photoCredit.isHidden = true
        findPhoto.target = self
        findPhoto.action = #selector(findWallpaper)
        importImage.target = self
        importImage.action = #selector(chooseImage)
        importImage.isEnabled = false
        setDesktop.target = self
        setDesktop.action = #selector(setDesktopPicture)
        setDesktop.isHidden = true
        importTheme.target = self
        importTheme.action = #selector(chooseManifest)
        exportTheme.target = self
        exportTheme.action = #selector(saveManifest)
        restore.target = self
        restore.action = #selector(confirmRestore)
        choices.setAccessibilityLabel("Theme")
        log.setAccessibilityLabel("Theme checks and operation results")
        let files = NSStackView(views: [importTheme, exportTheme, restore])
        setBusy(true)
        let actions = NSStackView(views: [apply, importImage, findPhoto, setDesktop])
        let stack = NSStackView(views: [search, appearanceFilter, list, preview, image, photoCredit, matchActions, actions, files, results])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.edgeInsets = NSEdgeInsets(top: 16, left: 18, bottom: 16, right: 18)
        panel.contentView = stack
        for view in [search, list, preview, image, results] as [NSView] {
            view.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -36).isActive = true
        }
        image.heightAnchor.constraint(equalToConstant: 78).isActive = true
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(search)
        NSApp.activate(ignoringOtherApps: true)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.keyCode == 53, NSApp.keyWindow === self.panel else { return event }
            NSApp.terminate(nil)
            return nil
        }

        refresh()
    }

    private func refresh(selecting id: String? = nil) {
        run(["list", "--json"]) { result in
            do {
                self.themes = try JSONDecoder().decode([ThemeSummary].self, from: result.get())
                if let id = id, let imported = self.themes.first(where: { $0.id == id }),
                   let mode = self.filteredAppearance, mode != imported.appearance {
                    self.appearanceFilter.selectedSegment = 0
                }
                self.filter(selecting: id)
            } catch { self.resultView.string = error.localizedDescription }
            self.setBusy(false)
        }
    }

    private func setBusy(_ busy: Bool) {
        operationBusy = busy
        for control in [search, appearanceFilter, choices, importImage, importTheme, restore, setDesktop] as [NSControl] {
            control.isEnabled = !busy
        }
        apply.isEnabled = !busy && previewReady
        exportTheme.isEnabled = apply.isEnabled
        findPhoto.isEnabled = apply.isEnabled
    }

    private var operationBusy = false
    private var previewReady = false

    @objc private func chooseImage() { chooseFile(imageFile: true) }
    @objc private func chooseManifest() { chooseFile(imageFile: false) }

    private func chooseFile(imageFile: Bool) {
        let dialog = NSOpenPanel()
        dialog.allowedContentTypes = imageFile ? [.image] : [.json]
        dialog.prompt = imageFile ? "Import image" : "Import theme"
        dialog.beginSheetModal(for: panel) { response in
            guard response == .OK, let url = dialog.url, url.isFileURL else { return }
            self.selectedID = nil
            self.wallpaperURL = nil
            self.previewReady = false
            self.setBusy(true)
            self.setDesktop.isHidden = true
            self.image.isHidden = true
            self.preview.stringValue = imageFile ? "Extracting palette…" : "Importing theme…"
            self.resultView.string = ""
            run([imageFile ? "import-wallpaper" : "import", url.path]) { result in
                do {
                    let id = String(decoding: try result.get(), as: UTF8.self)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    self.search.stringValue = ""
                    self.refresh(selecting: id)
                } catch {
                    self.preview.stringValue = error.localizedDescription
                    self.setBusy(false)
                    self.choices.deselectAll(nil)
                }
            }
        }
    }

    @objc private func saveManifest() {
        guard let id = selectedID else { return }
        let dialog = NSSavePanel()
        dialog.allowedContentTypes = [.json]
        dialog.nameFieldStringValue = id + ".json"
        dialog.beginSheetModal(for: panel) { response in
            guard response == .OK, let url = dialog.url else { return }
            self.setBusy(true)
            run(["export", id]) { result in
                do {
                    try result.get().write(to: url, options: .atomic)
                    self.resultView.string = "Exported " + url.lastPathComponent
                } catch { self.resultView.string = error.localizedDescription }
                self.setBusy(false)
            }
        }
    }

    @objc private func confirmRestore() {
        let alert = NSAlert()
        alert.messageText = "Restore original managed files?"
        alert.informativeText = "Return app configuration to its state before the first theme application in this session. Desktop pictures and manual app settings are managed separately."
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Restore files")
        alert.beginSheetModal(for: panel) { response in
            guard response == .alertSecondButtonReturn else { return }
            self.performCommand(["restore"], progress: "Restoring files…")
        }
    }

    @objc private func findWallpaper() {
        guard selectedID != nil, let accent = selectedColors["accent"] else { return }
        let keyFile = configHome.appendingPathComponent("pixabay-api-key")
        let key = (ProcessInfo.processInfo.environment["PIXABAY_API_KEY"] ?? (try? String(contentsOf: keyFile, encoding: .utf8)) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            resultView.string = "Save your Pixabay API key in " + keyFile.path + " to search for wallpapers."
            return
        }
        let colors = [accent, selectedColors["background"] ?? accent].map(pixabayColor)
        let filter = colors[0] == colors[1] ? colors[0] : colors.joined(separator: ",")
        let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("dotfiles-theme/pixabay-nature-v1")
            .appendingPathComponent(filter + ".json")
        var search = URLComponents(string: "https://pixabay.com/api/")!
        search.queryItems = ["key": key, "category": "nature", "orientation": "horizontal",
                             "image_type": "photo", "colors": filter, "per_page": "24", "safesearch": "true"]
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        setBusy(true)
        resultView.string = "Finding matching nature photos on Pixabay…"
        func show(_ result: Result<Data, Error>, cacheResponse: Bool) {
            do {
                struct SearchResult: Decodable { let hits: [PixabayPhoto] }
                let data = try result.get()
                let photos = try JSONDecoder().decode(SearchResult.self, from: data).hits.filter { photo in
                    [photo.pageURL, photo.webformatURL, photo.largeImageURL].allSatisfy {
                        $0.scheme == "https" && ($0.host == "pixabay.com" || $0.host?.hasSuffix(".pixabay.com") == true)
                    }
                }
                if cacheResponse {
                    try FileManager.default.createDirectory(at: cache.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try data.write(to: cache, options: .atomic)
                }
                if photos.isEmpty {
                    self.resultView.string = "Pixabay returned no matching landscape photos."
                    self.setBusy(false)
                } else {
                    self.candidates = photos
                    self.candidateIndex = 0
                    self.previewPhoto()
                }
            } catch {
                self.resultView.string = error.localizedDescription
                self.setBusy(false)
            }
        }
        if let date = try? cache.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
           Date().timeIntervalSince(date) < 86400, let data = try? Data(contentsOf: cache) {
            show(.success(data), cacheResponse: false)
        } else {
            var request = URLRequest(url: search.url!)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("DotfilesThemePicker/1.0 (macOS)", forHTTPHeaderField: "User-Agent")
            fetch(request) { show($0, cacheResponse: true) }
        }
    }

    private func previewPhoto() {
        let photo = candidates[candidateIndex]
        matchActions.isHidden = true
        photoCredit.isHidden = true
        resultView.string = "Loading wallpaper preview…"
        fetch(URLRequest(url: photo.webformatURL)) { result in
            do {
                guard let thumbnail = NSImage(data: try result.get()) else { throw CocoaError(.fileReadCorruptFile) }
                self.image.image = thumbnail
                self.image.isHidden = false
                self.photoCredit.title = "Photo by " + photo.user + " on Pixabay ↗"
                self.photoCredit.toolTip = photo.pageURL.absoluteString
                self.photoCredit.isHidden = false
                self.nextMatch.isEnabled = self.candidates.count > 1
                self.matchActions.isHidden = false
                self.resultView.string = "Wallpaper match \(self.candidateIndex + 1) of \(self.candidates.count)"
            } catch {
                self.endMatches()
                self.resultView.string = error.localizedDescription
                self.setBusy(false)
            }
        }
    }

    private func endMatches() {
        candidates.removeAll()
        matchActions.isHidden = true
        photoCredit.isHidden = true
        image.image = wallpaperURL.flatMap { NSImage(contentsOf: $0) }
        image.isHidden = image.image == nil
    }

    @objc private func cancelMatches() {
        endMatches()
        resultView.string = "Wallpaper search closed."
        setBusy(false)
    }

    @objc private func advanceMatch() {
        guard !candidates.isEmpty else { return }
        candidateIndex = (candidateIndex + 1) % candidates.count
        previewPhoto()
    }

    @objc private func useMatch() {
        guard let id = selectedID, candidates.indices.contains(candidateIndex) else { return }
        let photo = candidates[candidateIndex]
        endMatches()
        downloadPhoto(photo, themeID: id)
    }

    @objc private func openPhotoCredit(_ sender: NSButton) {
        if let link = sender.toolTip, let url = URL(string: link) { NSWorkspace.shared.open(url) }
    }

    private func downloadPhoto(_ photo: PixabayPhoto, themeID: String) {
        resultView.string = "Downloading desktop picture…"
        fetch(URLRequest(url: photo.largeImageURL)) { result in
            do {
                let data = try result.get()
                guard let downloaded = NSImage(data: data) else { throw CocoaError(.fileReadCorruptFile) }
                try FileManager.default.createDirectory(at: self.pictures, withIntermediateDirectories: true)
                let url = self.pictures.appendingPathComponent("pixabay-\(photo.id).jpg")
                try data.write(to: url, options: .atomic)
                try JSONEncoder().encode(photo).write(to: self.pictures.appendingPathComponent(themeID + ".json"), options: .atomic)
                self.wallpaperURL = url
                self.image.image = downloaded
                self.image.isHidden = false
                self.setDesktop.isHidden = false
                self.setDesktopPicture()
            } catch {
                self.showWallpaperError("Could not finish saving the wallpaper", detail: error.localizedDescription)
            }
            self.setBusy(false)
        }
    }

    @objc private func setDesktopPicture() {
        guard let url = wallpaperURL else { return }
        guard let screen = panel.screen else {
            showWallpaperError("Desktop picture could not be set", detail: "No display is available. Picture: " + url.path)
            return
        }
        do {
            try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
            resultView.string = "Desktop picture set on " + screen.localizedName + ".\nPicture: " + url.path
        } catch {
            showWallpaperError("Desktop picture could not be set", detail: error.localizedDescription + "\nPicture: " + url.path)
        }
    }

    private func showWallpaperError(_ title: String, detail: String) {
        resultView.string = title + "\n" + detail
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = detail
        alert.beginSheetModal(for: panel)
    }

    private var resultView: NSTextView!

    func controlTextDidChange(_ notification: Notification) { filter() }

    private var filteredAppearance: String? {
        switch appearanceFilter.selectedSegment {
        case 1: return "light"
        case 2: return "dark"
        default: return nil
        }
    }

    @objc private func changeFilter() { filter(selecting: selectedID) }

    private func filter(selecting id: String? = nil) {
        filtering = true
        matches = themes.filter { theme in
            let matchesSearch = search.stringValue.isEmpty || theme.name.localizedCaseInsensitiveContains(search.stringValue)
                || theme.id.localizedCaseInsensitiveContains(search.stringValue)
            return matchesSearch && (filteredAppearance == nil || theme.appearance == filteredAppearance)
        }
        choices.reloadData()
        if matches.isEmpty {
            choices.deselectAll(nil)
        } else {
            let row = matches.firstIndex { $0.id == id } ?? 0
            choices.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            choices.scrollRowToVisible(row)
        }
        filtering = false
        selectTheme()
    }

    func numberOfRows(in tableView: NSTableView) -> Int { matches.count }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        matches[row].name
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if !filtering { selectTheme() }
    }

    private func selectTheme() {
        let row = choices.selectedRow
        let id = matches.indices.contains(row) ? matches[row].id : nil
        previewReady = false
        exportTheme.isEnabled = false
        findPhoto.isEnabled = false
        wallpaperURL = nil
        setDesktop.isHidden = true
        selectedID = id
        apply.isEnabled = false
        image.isHidden = true
        resultView.string = ""
        guard let id = selectedID else {
            preview.stringValue = "No matching themes"
            return
        }
        preview.stringValue = "Loading preview…"
        run(["preview", id]) { result in
            guard self.selectedID == id else { return }
            do {
                let theme = try JSONDecoder().decode(Theme.self, from: result.get())
                let text = NSMutableAttributedString(string: theme.appearance.capitalized + "\n")
                for key in theme.colors.keys.sorted() {
                    text.append(swatch(theme.colors[key]!))
                    text.append(NSAttributedString(string: " " + key + "   "))
                }
                text.append(NSAttributedString(string: "\nANSI   "))
                for hex in theme.ansi { text.append(swatch(hex)) }
                self.preview.attributedStringValue = text
                let descriptions = theme.colors.keys.sorted().map { "\($0) \(theme.colors[$0]!)" }
                self.preview.setAccessibilityLabel(([theme.appearance] + descriptions).joined(separator: ", "))
                self.selectedColors = theme.colors
                let record = self.pictures.appendingPathComponent(id + ".json")
                let photo = (try? Data(contentsOf: record)).flatMap { try? JSONDecoder().decode(SavedPhoto.self, from: $0) }
                let saved = photo.map { self.pictures.appendingPathComponent($0.filename).path }
                if let path = saved.flatMap({ FileManager.default.fileExists(atPath: $0) ? $0 : nil }) ?? theme.wallpaper?.path {
                    self.image.image = NSImage(contentsOfFile: (path as NSString).expandingTildeInPath)
                    self.image.isHidden = self.image.image == nil
                    if self.image.image != nil {
                        self.wallpaperURL = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
                        self.setDesktop.isHidden = false
                    }
                }
                self.resultView.string = "Ghostty, SketchyBar and Yabai borders update where configured. Light and dark themes set macOS appearance on apply. Running Herdr selects the palette for its current layout."
                if theme.wallpaper?.path != nil && self.wallpaperURL == nil {
                    self.resultView.string += "\nWallpaper image is unavailable at its saved path."
                }
                self.resultView.string += "\n\n" + theme.contrastChecks.joined(separator: "\n")
                let ansi = theme.ansi.enumerated().map { "\($0.offset) \($0.element)" }
                self.resultView.string += "\nANSI colors: " + ansi.joined(separator: ", ")
                self.previewReady = true
                self.apply.isEnabled = !self.operationBusy
                self.exportTheme.isEnabled = !self.operationBusy
                self.findPhoto.isEnabled = !self.operationBusy
            } catch { self.preview.stringValue = error.localizedDescription }
        }
    }

    @objc private func applyTheme() {
        guard let id = selectedID else { return }
        performCommand(["apply", id], progress: "Applying theme…")
    }

    private func performCommand(_ arguments: [String], progress: String) {
        setBusy(true)
        resultView.string = progress
        run(arguments) { result in
            do { self.resultView.string = String(decoding: try result.get(), as: UTF8.self) }
            catch { self.resultView.string = error.localizedDescription }
            self.setBusy(false)
        }
    }

    func windowWillClose(_ notification: Notification) {
        if notification.object as? NSWindow === panel { NSApp.terminate(nil) }
    }
}

let application = NSApplication.shared
private let picker = Picker()
application.delegate = picker
application.run()
