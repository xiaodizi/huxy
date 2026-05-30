import SwiftUI

struct AppearanceSettingsView: View {
    @State private var themeService = ThemeService.shared
    @State private var showLightThemePicker = false
    @State private var showDarkThemePicker = false
    @State private var currentLightTheme: String?
    @State private var currentDarkTheme: String?
    @State private var draftWindowOpacity: Double = 0.92
    @State private var isAdjustingWindowOpacity = false
    @State private var pendingWindowOpacityCommitTask: Task<Void, Never>?
    @State private var pendingTerminalBackgroundSyncTask: Task<Void, Never>?
    @State private var lastAppliedBackgroundOpacity: String?
    @State private var lastAppliedBackgroundBlur: String?
    @AppStorage("muxy.blurEnabled") private var blurEnabled = true
    @AppStorage("muxy.blurStrength") private var blurStrength: Double = 0.5
    @AppStorage("muxy.sidebarGradientOpacity") private var sidebarGradientOpacity: Double = 0.92
    @AppStorage("muxy.windowOpacity") private var windowOpacity: Double = 0.92
    @AppStorage("muxy.vcsDisplayMode") private var vcsDisplayMode = VCSDisplayMode.attached.rawValue
    @AppStorage(SidebarCollapsedStyle.storageKey) private var sidebarCollapsedStyle = SidebarCollapsedStyle.defaultValue.rawValue
    @AppStorage(SidebarExpandedStyle.storageKey) private var sidebarExpandedStyle = SidebarExpandedStyle.defaultValue.rawValue

    var body: some View {
        SettingsContainer {
            SettingsSection("Window") {
                SettingsRow("透明模糊背景") {
                    Toggle("", isOn: $blurEnabled)
                        .labelsHidden()
                }
                SettingsRow("窗口透明度") {
                    HStack(spacing: 12) {
                        Slider(
                            value: Binding(
                                get: { draftWindowOpacity },
                                set: { draftWindowOpacity = $0 }
                            ),
                            in: 0.0...1.0,
                            step: 0.01,
                            onEditingChanged: { editing in
                                isAdjustingWindowOpacity = editing
                                if editing {
                                    pendingWindowOpacityCommitTask?.cancel()
                                    return
                                }
                                scheduleWindowOpacityCommit()
                            }
                        )
                        Text("\(Int(draftWindowOpacity * 100))%")
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 40)
                    }
                }
                SettingsRow("模糊强度") {
                    HStack(spacing: 12) {
                        Slider(value: $blurStrength, in: 0.0...1.0, step: 0.01)
                        Text("\(Int(blurStrength * 100))%")
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 40)
                    }
                }
                SettingsRow("侧边栏透明度") {
                    HStack(spacing: 12) {
                        Slider(value: $sidebarGradientOpacity, in: 0.0...1.0, step: 0.01)
                        Text("\(Int(sidebarGradientOpacity * 100))%")
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 40)
                    }
                }
            }

            SettingsSection("Terminal") {
                SettingsRow("Light Theme") {
                    themeButton(
                        title: currentLightTheme ?? "Default",
                        isPresented: $showLightThemePicker,
                        mode: .light
                    )
                }
                SettingsRow("Dark Theme") {
                    themeButton(
                        title: currentDarkTheme ?? "Default",
                        isPresented: $showDarkThemePicker,
                        mode: .dark
                    )
                }
            }

            SettingsSection("Sidebar") {
                SettingsRow("Collapsed Style") {
                    HStack {
                        Spacer()
                        Picker("", selection: $sidebarCollapsedStyle) {
                            ForEach(SidebarCollapsedStyle.allCases) { style in
                                Text(style.title).tag(style.rawValue)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                    .frame(width: SettingsMetrics.controlWidth)
                }

                SettingsRow("Expanded Style") {
                    HStack {
                        Spacer()
                        Picker("", selection: $sidebarExpandedStyle) {
                            ForEach(SidebarExpandedStyle.allCases) { style in
                                Text(style.title).tag(style.rawValue)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                    .frame(width: SettingsMetrics.controlWidth)
                }
            }

            SettingsSection("Source Control", showsDivider: false) {
                SettingsRow("Display Mode") {
                    Picker("", selection: $vcsDisplayMode) {
                        ForEach(VCSDisplayMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: SettingsMetrics.controlWidth)
                }
            }
        }
        .task {
            refreshThemeNames()
            draftWindowOpacity = windowOpacity
            scheduleTerminalBackgroundSync(immediate: true)
        }
        .onReceive(NotificationCenter.default.publisher(for: .themeDidChange)) { _ in
            refreshThemeNames()
        }
        .onChange(of: windowOpacity) {
            if !isAdjustingWindowOpacity {
                draftWindowOpacity = windowOpacity
            }
            scheduleTerminalBackgroundSync(immediate: true)
        }
        .onChange(of: blurStrength) {
            scheduleTerminalBackgroundSync()
        }
        .onChange(of: blurEnabled) {
            scheduleTerminalBackgroundSync()
        }
        .onDisappear {
            pendingWindowOpacityCommitTask?.cancel()
            pendingWindowOpacityCommitTask = nil
            pendingTerminalBackgroundSyncTask?.cancel()
            pendingTerminalBackgroundSyncTask = nil
        }
    }

    private func themeButton(
        title: String,
        isPresented: Binding<Bool>,
        mode: ThemePickerMode
    ) -> some View {
        Button {
            isPresented.wrappedValue.toggle()
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: SettingsMetrics.labelFontSize))
                    .lineLimit(1)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .popover(isPresented: isPresented) {
            ThemePicker(mode: mode)
                .environment(themeService)
        }
    }

    private func refreshThemeNames() {
        currentLightTheme = themeService.currentLightThemeName()
        currentDarkTheme = themeService.currentDarkThemeName()
    }

    private func scheduleWindowOpacityCommit() {
        pendingWindowOpacityCommitTask?.cancel()
        pendingWindowOpacityCommitTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            windowOpacity = draftWindowOpacity
        }
    }

    private func scheduleTerminalBackgroundSync(immediate: Bool = false) {
        pendingTerminalBackgroundSyncTask?.cancel()
        pendingTerminalBackgroundSyncTask = Task { @MainActor in
            if !immediate {
                try? await Task.sleep(nanoseconds: 220_000_000)
            }
            applyTerminalBackgroundSettingsIfNeeded()
        }
    }

    private func applyTerminalBackgroundSettingsIfNeeded() {
        let opacityValue = max(0, min(1, 1 - windowOpacity))
        let blurActive = blurEnabled && blurStrength > 0.01
        let opacityString = String(format: "%.2f", opacityValue)

        let backgroundBlurString = blurActive ? "true" : "false"
        let shouldUpdateOpacity = lastAppliedBackgroundOpacity != opacityString
        let shouldUpdateBlur = lastAppliedBackgroundBlur != backgroundBlurString
        guard shouldUpdateOpacity || shouldUpdateBlur else { return }

        if shouldUpdateOpacity {
            MuxyConfig.shared.updateConfigValue("background-opacity", value: opacityString)
            lastAppliedBackgroundOpacity = opacityString
        }
        if shouldUpdateBlur {
            MuxyConfig.shared.updateConfigValue("background-blur", value: backgroundBlurString)
            lastAppliedBackgroundBlur = backgroundBlurString
        }
        GhosttyService.shared.reloadConfig()
    }
}
