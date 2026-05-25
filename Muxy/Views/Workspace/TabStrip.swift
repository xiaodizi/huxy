import MuxyShared
import SwiftUI
import UniformTypeIdentifiers

extension View {
    @ViewBuilder
    func applyIf<Content: View>(_ condition: Bool, _ transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct PaneTabStrip: View {
    struct TabSnapshot: Identifiable {
        let id: UUID
        let title: String
        let kind: TerminalTab.Kind
        let isPinned: Bool
        let hasCustomTitle: Bool
        let colorID: String?
    }

    let areaID: UUID
    let tabs: [TabSnapshot]
    let activeTabID: UUID?
    let isFocused: Bool
    var isWindowTitleBar: Bool = false
    var showVCSButton = true
    var showDevelopmentBadge = false
    var openInIDEProjectPath: String?
    var openInIDEFilePath: String?
    var openInIDECursorProvider: () -> (line: Int?, column: Int?) = { (nil, nil) }
    let projectID: UUID
    let onSelectTab: (UUID) -> Void
    let onCreateTab: () -> Void
    let onCreateVCSTab: () -> Void
    let onCloseTab: (UUID) -> Void
    let onCloseOtherTabs: (UUID) -> Void
    let onCloseTabsToLeft: (UUID) -> Void
    let onCloseTabsToRight: (UUID) -> Void
    let onSplit: (SplitDirection) -> Void
    let onDropAction: (TabDragCoordinator.DropResult) -> Void
    let onCreateTabAdjacent: (UUID, TabArea.InsertSide) -> Void
    let onTogglePin: (UUID) -> Void
    let onSetCustomTitle: (UUID, String?) -> Void
    let onSetColorID: (UUID, String?) -> Void
    let onReorderTab: (IndexSet, Int) -> Void
    @Environment(TabDragCoordinator.self) private var dragCoordinator
    @State private var dragState = TabDragState()
    @State private var tabFrames: [UUID: CGRect] = [:]
    @State private var containerFrame: CGRect = .zero

    private let stripBackground = Color(white: 0.16)
    private let stripGradientTop = Color(white: 0.22)
    private let stripGradientBottom = Color(white: 0.12)

    static func snapshots(from tabs: [TerminalTab]) -> [TabSnapshot] {
        tabs.map { tab in
            TabSnapshot(
                id: tab.id,
                title: tab.title,
                kind: tab.kind,
                isPinned: tab.isPinned,
                hasCustomTitle: tab.customTitle != nil,
                colorID: tab.colorID
            )
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            leftToolbarButtons

            capsuleContainer
                .layoutPriority(1)

            rightToolbarButtons
        }
        .frame(height: 32)
        .background(
            ZStack {
                LinearGradient(
                    colors: [stripGradientTop, stripGradientBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                Rectangle()
                    .fill(stripBackground)
            }
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
        }
        .onPreferenceChange(TabFramePreferenceKey.self) { frames in
            tabFrames = frames
            guard dragState.draggedID != nil else { return }
            dragState.frames = frames
        }
    }

private var capsuleContainer: some View {
    ZStack {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                if tab.id == activeTabID {
                    // Active tab: draw capsule inside tab with close, title, badge
                    HStack(spacing: 0) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(6)
                                .background(Color.white.opacity(0.03))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 0.5))
                                .onTapGesture { onCloseTab(tab.id) }

                            Text(tab.title)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            // Shortcut badge on right
                            if index < 9 {
                                Text(KeyBindingStore.shared.combo(for: ShortcutAction.tabAction(for: index + 1) ?? .newTab).displayString)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color(white: 0.8))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.black.opacity(0.18))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 24)
                        // Do not draw a full capsule here — MainWindow already provides the pill background.
                        // Instead, use a subtle inner highlight and stroke for the active tab content.
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.06), lineWidth: 0.6)
                                .blendMode(.overlay)
                        )
                    }
                    .background {
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: TabFramePreferenceKey.self,
                                value: [tab.id: geo.frame(in: .named("TabStripCapsuleSpace"))]
                            )
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named(DragCoordinateSpace.mainWindow))
                            .onChanged { value in
                                handleDragChanged(
                                    tab: tab,
                                    globalLocation: value.location,
                                    dragStartGlobalLocation: value.startLocation
                                )
                            }
                            .onEnded { value in
                                handleDragEnded(
                                    tab: tab,
                                    globalLocation: value.location,
                                    dragStartGlobalLocation: value.startLocation
                                )
                            }
                    )
                } else {
                    HStack(spacing: 0) {
                        TabCell(
                            tab: tab,
                            active: false,
                            paneFocused: isFocused,
                            areaID: areaID,
                            hasUnread: NotificationStore.shared.hasUnread(tabID: tab.id),
                            isAnyDragging: dragState.draggedID != nil,
                            shortcutIndex: index < 9 ? index + 1 : nil,
                            closableOthersCount: closableOthersCount(excluding: tab.id),
                            closableLeftCount: closableCount(leftOf: index),
                            closableRightCount: closableCount(rightOf: index),
                            onSelect: { onSelectTab(tab.id) },
                            onCloseOthers: { onCloseOtherTabs(tab.id) },
                            onCloseLeft: { onCloseTabsToLeft(tab.id) },
                            onCloseRight: { onCloseTabsToRight(tab.id) },
                            onCreateLeft: { onCreateTabAdjacent(tab.id, .left) },
                            onCreateRight: { onCreateTabAdjacent(tab.id, .right) },
                            onTogglePin: { onTogglePin(tab.id) },
                            onSetCustomTitle: { onSetCustomTitle(tab.id, $0) },
                            onSetColorID: { onSetColorID(tab.id, $0) }
                        )

                        if !tab.isPinned {
                            CloseButton(
                                onTap: { onCloseTab(tab.id) }
                            )
                            .padding(.trailing, 8)
                        }
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(white: 0.25),
                                Color(white: 0.18)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
                    .background {
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: TabFramePreferenceKey.self,
                                value: [tab.id: geo.frame(in: .named("TabStripCapsuleSpace"))]
                            )
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named(DragCoordinateSpace.mainWindow))
                            .onChanged { value in
                                handleDragChanged(
                                    tab: tab,
                                    globalLocation: value.location,
                                    dragStartGlobalLocation: value.startLocation
                                )
                            }
                            .onEnded { value in
                                handleDragEnded(
                                    tab: tab,
                                    globalLocation: value.location,
                                    dragStartGlobalLocation: value.startLocation
                                )
                            }
                    )
                }

                if index < tabs.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 1)
                        .padding(.vertical, 6)
                }
            }
        }
        .padding(.horizontal, 6)

        .coordinateSpace(name: "TabStripCapsuleSpace")
    }
}

    private var leftToolbarButtons: some View {
        HStack(spacing: 0) {
            if showDevelopmentBadge {
                DebugButton()
                    .padding(.trailing, 4)
            }
            if isWindowTitleBar {
                OpenInIDEControl(
                    projectPath: openInIDEProjectPath,
                    filePath: openInIDEFilePath,
                    cursorProvider: openInIDECursorProvider
                )
                LayoutPickerMenu(projectID: projectID)
            }
        }
        .padding(.leading, 8)
        .fixedSize(horizontal: true, vertical: false)
        .background(WindowDragRepresentable(alwaysEnabled: isWindowTitleBar))
    }

    private var rightToolbarButtons: some View {
        HStack(spacing: 0) {
            if isWindowTitleBar, let version = UpdateService.shared.availableUpdateVersion {
                UpdateBadge(version: version) {
                    UpdateService.shared.checkForUpdates()
                }
                .padding(.trailing, 4)
            }
            IconButton(symbol: "square.split.2x1", accessibilityLabel: "Split Right") { onSplit(.horizontal) }
                .help(shortcutTooltip("Split Right", for: .splitRight))
            IconButton(symbol: "square.split.1x2", accessibilityLabel: "Split Down") { onSplit(.vertical) }
                .help(shortcutTooltip("Split Down", for: .splitDown))
            IconButton(symbol: "plus", accessibilityLabel: "New Tab") { onCreateTab() }
                .help(shortcutTooltip("New Tab", for: .newTab))
            if showVCSButton {
                IconButton(symbol: "doc.text", size: 12, accessibilityLabel: "Quick Open") {
                    NotificationCenter.default.post(name: .quickOpen, object: nil)
                }
                .help(shortcutTooltip("Quick Open", for: .quickOpen))
                FileDiffIconButton(action: onCreateVCSTab)
                    .help(shortcutTooltip("Source Control", for: .openVCSTab))
                FileTreeIconButton {
                    NotificationCenter.default.post(name: .toggleFileTree, object: nil)
                }
                .help(shortcutTooltip("File Tree", for: .toggleFileTree))
            }
        }
        .padding(.trailing, 8)
        .fixedSize(horizontal: true, vertical: false)
        .background(WindowDragRepresentable(alwaysEnabled: isWindowTitleBar))
    }

    private func closableOthersCount(excluding tabID: UUID) -> Int {
        tabs.count(where: { $0.id != tabID && !$0.isPinned })
    }

    private func closableCount(leftOf index: Int) -> Int {
        tabs.prefix(index).count(where: { !$0.isPinned })
    }

    private func closableCount(rightOf index: Int) -> Int {
        tabs.suffix(from: index + 1).count(where: { !$0.isPinned })
    }

    private func shortcutTooltip(_ name: String, for action: ShortcutAction) -> String {
        "\(name) (\(KeyBindingStore.shared.combo(for: action).displayString))"
    }

    private static let dragActivationDistance: CGFloat = 4

    private func handleDragChanged(
        tab: TabSnapshot,
        globalLocation: CGPoint,
        dragStartGlobalLocation: CGPoint
    ) {
        if !dragState.didSelect {
            dragState.didSelect = true
            onSelectTab(tab.id)
        }

        let dx = globalLocation.x - dragStartGlobalLocation.x
        let dy = globalLocation.y - dragStartGlobalLocation.y
        let distance = (dx * dx + dy * dy).squareRoot()

        if dragState.draggedID == nil {
            guard distance >= Self.dragActivationDistance else { return }
            dragState.draggedID = tab.id
            dragState.lastReorderTargetID = nil
        }

        if dragState.isInSplitMode {
            dragCoordinator.updatePosition(globalLocation)
            return
        }

        if abs(dy) > 24, !tab.isPinned {
            dragState.isInSplitMode = true
            dragCoordinator.beginDrag(tabID: tab.id, sourceAreaID: areaID, projectID: projectID)
            dragCoordinator.updatePosition(globalLocation)
            return
        }

        reorderIfNeeded(at: globalLocation)
    }

    private func handleDragEnded(
        tab: TabSnapshot,
        globalLocation: CGPoint,
        dragStartGlobalLocation: CGPoint
    ) {
        if !dragState.didSelect {
            onSelectTab(tab.id)
        }
        if dragState.isInSplitMode {
            if let result = dragCoordinator.endDrag() {
                onDropAction(result)
            }
        }
        withAnimation(.easeInOut(duration: 0.15)) {
            dragState.draggedID = nil
            dragState.isInSplitMode = false
            dragState.frames = [:]
            dragState.lastReorderTargetID = nil
            dragState.didSelect = false
        }
    }

    private func reorderIfNeeded(at location: CGPoint) {
        guard let draggedID = dragState.draggedID else { return }
        var hoveredTargetID: UUID?

        for (id, frame) in dragState.frames where id != draggedID {
            guard frame.contains(location) else { continue }
            hoveredTargetID = id
            guard dragState.lastReorderTargetID != id else { return }

            guard let sourceIndex = tabs.firstIndex(where: { $0.id == draggedID }),
                  let destIndex = tabs.firstIndex(where: { $0.id == id })
            else { return }

            dragState.lastReorderTargetID = id
            let offset = destIndex > sourceIndex ? destIndex + 1 : destIndex
            withAnimation(.easeInOut(duration: 0.15)) {
                onReorderTab(IndexSet(integer: sourceIndex), offset)
            }
            return
        }

        if hoveredTargetID == nil {
            dragState.lastReorderTargetID = nil
        }
    }
}

private struct TabDragState {
    var draggedID: UUID?
    var frames: [UUID: CGRect] = [:]
    var isInSplitMode = false
    var lastReorderTargetID: UUID?
    var didSelect = false
}

private typealias TabFramePreferenceKey = UUIDFramePreferenceKey<TabFrameTag>

private struct TabWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct CloseButton: View {
    let onTap: () -> Void
    @State private var hovered = false

    var body: some View {
        Image(systemName: "xmark")
            .font(.system(size: 8, weight: .medium))
            .foregroundStyle(.white.opacity(0.35))
            .opacity(hovered ? 1 : 0.5)
            .scaleEffect(hovered ? 1.1 : 1.0)
            .animation(.easeOut(duration: 0.15), value: hovered)
            .animation(.easeOut(duration: 0.15), value: hovered)
        .onHover { hovering in
            hovered = hovering
        }
        .onTapGesture(perform: onTap)
        .accessibilityLabel("Close Tab")
        .accessibilityAddTraits(.isButton)
        .overlay {
            MiddleClickView(action: onTap)
                .allowsHitTesting(false)
        }
    }
}

private struct TabCell: View {
    static let minWidth: CGFloat = 44
    static let maxWidth: CGFloat = 200
    static let titleHideThreshold: CGFloat = 80

    let tab: PaneTabStrip.TabSnapshot
    let active: Bool
    let paneFocused: Bool
    let areaID: UUID
    var hasUnread: Bool = false
    var isAnyDragging: Bool = false
    var shortcutIndex: Int?
    var closableOthersCount: Int = 0
    var closableLeftCount: Int = 0
    var closableRightCount: Int = 0
    let onSelect: () -> Void
    let onCloseOthers: () -> Void
    let onCloseLeft: () -> Void
    let onCloseRight: () -> Void
    let onCreateLeft: () -> Void
    let onCreateRight: () -> Void
    let onTogglePin: () -> Void
    let onSetCustomTitle: (String?) -> Void
    let onSetColorID: (String?) -> Void
    @State private var hovered = false
    @State private var isRenaming = false
    @State private var renameText = ""
    @State private var showColorPicker = false
    @State private var measuredWidth: CGFloat = TabCell.maxWidth
    @State private var externalDragOverCell = false
    @State private var springLoadTask: Task<Void, any Error>?
    @FocusState private var renameFieldFocused: Bool

    private static let springLoadDelay: Duration = .milliseconds(250)

    private var titleHidden: Bool {
        measuredWidth < Self.titleHideThreshold
    }

    private var tabColor: Color? {
        ProjectIconColor.color(for: tab.colorID)
    }

    private var tabBackground: Color {
        if active {
            return Color.white.opacity(0.08)
        }
        if hovered {
            return Color.white.opacity(0.05)
        }
        return .clear
    }

    private var showBadge: Bool {
        guard let shortcutIndex,
              let action = ShortcutAction.tabAction(for: shortcutIndex)
        else { return false }
        return ModifierKeyMonitor.shared.isHolding(
            modifiers: KeyBindingStore.shared.combo(for: action).modifiers
        )
    }

    var body: some View {
        HStack(spacing: 6) {
            tabIconView
                .foregroundStyle(active ? .white : Color(white: 0.63))
                .opacity(titleHidden && hovered && !tab.isPinned ? 0 : 1)
                .overlay(alignment: .topTrailing) {
                    if hasUnread, !active {
                        Circle()
                            .fill(MuxyTheme.accent)
                            .frame(width: 6, height: 6)
                            .offset(x: 3, y: -3)
                    }
                }

            if isRenaming {
                TextField("", text: $renameText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, weight: active ? .medium : .regular))
                    .foregroundStyle(.white)
                    .focused($renameFieldFocused)
                    .onSubmit { commitRename() }
                    .onExitCommand { cancelRename() }
                    .onChange(of: renameFieldFocused) { _, focused in
                        if !focused, isRenaming { commitRename() }
                    }
            } else if !titleHidden {
                Text(tab.title)
                    .font(.system(size: 12, weight: active ? .medium : .regular))
                    .foregroundStyle(active ? .white : Color(white: 0.63))
                    .lineLimit(1)
                    .truncationMode(.head)
            }

            if !titleHidden && showBadge, let shortcutIndex,
               let action = ShortcutAction.tabAction(for: shortcutIndex)
            {
                Text(KeyBindingStore.shared.combo(for: action).displayString)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(white: 0.5))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 24)
        .background {
            GeometryReader { geo in
                Color.clear.preference(key: TabWidthPreferenceKey.self, value: geo.size.width)
            }
        }
        .onPreferenceChange(TabWidthPreferenceKey.self) { measuredWidth = $0 }
        .overlay {
            DoubleClickView(action: startRename)
                .accessibilityHidden(true)
        }
        .background(tabBackground)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            guard !isAnyDragging else { return }
            hovered = hovering
        }
        .onChange(of: isAnyDragging) { _, dragging in
            if dragging { hovered = false }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(tabAccessibilityLabel)
        .accessibilityAddTraits(active ? .isSelected : [])
        .accessibilityAddTraits(.isButton)
        .contextMenu {
            TabContextMenu(
                tab: tab,
                closableOthersCount: closableOthersCount,
                closableLeftCount: closableLeftCount,
                closableRightCount: closableRightCount,
                showColorPicker: $showColorPicker,
                onCreateLeft: onCreateLeft,
                onCreateRight: onCreateRight,
                onRename: startRename,
                onSetCustomTitle: onSetCustomTitle,
                onSetColorID: onSetColorID,
                onTogglePin: onTogglePin,
                onCloseOthers: onCloseOthers,
                onCloseLeft: onCloseLeft,
                onCloseRight: onCloseRight
            )
        }
        .popover(isPresented: $showColorPicker, arrowEdge: .bottom) {
            ProjectIconColorPicker(title: "Tab Color", selectedID: tab.colorID) { id in
                onSetColorID(id)
                showColorPicker = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .renameActiveTab)) { _ in
            guard active else { return }
            startRename()
        }
        .onDrop(of: [.fileURL], isTargeted: $externalDragOverCell) { _, _ in false }
        .onChange(of: externalDragOverCell) { _, hovering in
            handleExternalDragHover(hovering: hovering)
        }
        .onDisappear {
            springLoadTask?.cancel()
        }
    }

    private func handleExternalDragHover(hovering: Bool) {
        NotificationCenter.default.post(
            name: .externalDragHoverChanged,
            object: nil,
            userInfo: [
                ExternalDragHoverUserInfoKey.isHovering: hovering,
                ExternalDragHoverUserInfoKey.areaID: areaID,
            ]
        )
        springLoadTask?.cancel()
        guard hovering, !active else {
            springLoadTask = nil
            return
        }
        springLoadTask = Task { @MainActor in
            try await Task.sleep(for: Self.springLoadDelay)
            onSelect()
        }
    }

    private func startRename() {
        renameText = tab.title
        isRenaming = true
        renameFieldFocused = true
    }

    private func commitRename() {
        let trimmed = renameText.trimmingCharacters(in: .whitespaces)
        onSetCustomTitle(trimmed.isEmpty ? nil : trimmed)
        isRenaming = false
    }

    private func cancelRename() {
        isRenaming = false
    }

    private var tabAccessibilityLabel: String {
        var label = tab.title
        switch tab.kind {
        case .terminal: label += ", Terminal"
        case .vcs: label += ", Source Control"
        case .editor: label += ", Editor"
        case .diffViewer: label += ", Diff Viewer"
        }
        if tab.isPinned { label += ", Pinned" }
        if hasUnread { label += ", Unread" }
        return label
    }

    @ViewBuilder
    private var tabIconView: some View {
        if tab.isPinned {
            Image(systemName: "pin.fill")
                .font(.system(size: 10, weight: .semibold))
        } else if tab.kind == .vcs {
            FileDiffIcon()
                .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .frame(width: 12, height: 12)
        } else if tab.kind == .editor {
            Image(systemName: "pencil.line")
                .font(.system(size: 12, weight: .semibold))
        } else if tab.kind == .diffViewer {
            Image(systemName: "rectangle.split.2x1")
                .font(.system(size: 11, weight: .semibold))
        } else {
            Image(systemName: "terminal")
                .font(.system(size: 12, weight: .semibold))
        }
    }
}

private struct TabContextMenu: View {
    let tab: PaneTabStrip.TabSnapshot
    let closableOthersCount: Int
    let closableLeftCount: Int
    let closableRightCount: Int
    @Binding var showColorPicker: Bool
    let onCreateLeft: () -> Void
    let onCreateRight: () -> Void
    let onRename: () -> Void
    let onSetCustomTitle: (String?) -> Void
    let onSetColorID: (String?) -> Void
    let onTogglePin: () -> Void
    let onCloseOthers: () -> Void
    let onCloseLeft: () -> Void
    let onCloseRight: () -> Void

    var body: some View {
        Group {
            Button("New Tab to the Left") { onCreateLeft() }
            Button("New Tab to the Right") { onCreateRight() }
            Divider()
            Button("Rename Tab") { onRename() }
            if tab.hasCustomTitle {
                Button("Reset Title") { onSetCustomTitle(nil) }
            }
            Button("Set Tab Color…") { showColorPicker = true }
            if tab.colorID != nil {
                Button("Reset Tab Color") { onSetColorID(nil) }
            }
            Divider()
            if tab.isPinned {
                Button("Unpin Tab") { onTogglePin() }
            } else {
                Button("Pin Tab") { onTogglePin() }
            }
            if !tab.isPinned {
                Divider()
                Button("Close Other Tabs") { onCloseOthers() }
                    .disabled(closableOthersCount == 0)
                Button("Close Tabs to the Left") { onCloseLeft() }
                    .disabled(closableLeftCount == 0)
                Button("Close Tabs to the Right") { onCloseRight() }
                    .disabled(closableRightCount == 0)
            }
        }
    }
}
