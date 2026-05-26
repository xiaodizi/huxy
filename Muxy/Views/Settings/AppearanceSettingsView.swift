import SwiftUI

struct AppearanceSettingsView: View {
    @State private var themeService = ThemeService.shared
    @State private var showLightThemePicker = false
    @State private var showDarkThemePicker = false
    @State private var currentLightTheme: String?
    @State private var currentDarkTheme: String?
    @State private var isUpdatingTerminalBackground = false
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
                        Slider(value: $windowOpacity, in: 0.0...1.0, step: 0.01)
                        Text("\(Int(windowOpacity * 100))%")
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
            syncTerminalBackgroundSettings()
        }
        .onReceive(NotificationCenter.default.publisher(for: .themeDidChange)) { _ in
            refreshThemeNames()
        }
        .onChange(of: windowOpacity) {
            syncTerminalBackgroundSettings()
        }
        .onChange(of: blurStrength) {
            syncTerminalBackgroundSettings()
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

    private func syncTerminalBackgroundSettings() {
        guard !isUpdatingTerminalBackground else { return }
        isUpdatingTerminalBackground = true
        let opacityValue = max(0, min(1, windowOpacity))
        let blurEnabled = blurStrength > 0.01
        let opacityString = String(format: "%.2f", opacityValue)
        MuxyConfig.shared.updateConfigValue("background-opacity", value: opacityString)
        MuxyConfig.shared.updateConfigValue("background-blur", value: blurEnabled ? "true" : "false")
        GhosttyService.shared.reloadConfig()
        DispatchQueue.main.async {
            isUpdatingTerminalBackground = false
        }
    }
}
