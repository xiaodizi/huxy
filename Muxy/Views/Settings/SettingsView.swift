import SwiftUI

struct SettingsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            backgroundMaterial

            TabView(selection: $selectedTab) {
                GeneralSettingsView()
                    .tabItem {
                        Label("General", systemImage: selectedTab == 0 ? "gearshape.fill" : "gearshape")
                    }
                    .tag(0)
                AppearanceSettingsView()
                    .tabItem {
                        Label("Appearance", systemImage: selectedTab == 1 ? "paintbrush.fill" : "paintbrush")
                    }
                    .tag(1)
                EditorSettingsView()
                    .tabItem {
                        Label("Editor", systemImage: selectedTab == 2 ? "pencil.line" : "pencil.line")
                    }
                    .tag(2)
                KeyboardShortcutsSettingsView()
                    .tabItem {
                        Label("Shortcuts", systemImage: selectedTab == 3 ? "keyboard.fill" : "keyboard")
                    }
                    .tag(3)
                NotificationSettingsView()
                    .tabItem {
                        Label("Notifications", systemImage: selectedTab == 4 ? "bell.fill" : "bell")
                    }
                    .tag(4)
                MobileSettingsView()
                    .tabItem {
                        Label("Mobile", systemImage: selectedTab == 5 ? "iphone.fill" : "iphone")
                    }
                    .tag(5)
                AIUsageSettingsView()
                    .tabItem {
                        Label("AI Usage", systemImage: selectedTab == 6 ? "chart.bar.fill" : "chart.bar")
                    }
                    .tag(6)
            }
            .tabViewStyle(.automatic)
            .frame(width: 560, height: 560)
            .resetsSettingsFocusOnOutsideClick()
        }
    }

    private var backgroundMaterial: some View {
        GlassBlurView(material: .hudWindow, blendingMode: .behindWindow)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}
