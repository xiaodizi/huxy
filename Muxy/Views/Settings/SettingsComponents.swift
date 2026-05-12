import AppKit
import SwiftUI

enum SettingsMetrics {
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 12
    static let rowVerticalPadding: CGFloat = 8
    static let sectionHeaderTopPadding: CGFloat = 14
    static let sectionHeaderBottomPadding: CGFloat = 8
    static let sectionFooterTopPadding: CGFloat = 6
    static let sectionFooterBottomPadding: CGFloat = 14
    static let labelFontSize: CGFloat = 13
    static let footnoteFontSize: CGFloat = 11
    static let controlWidth: CGFloat = 210
    static let cardCornerRadius: CGFloat = 10
}

struct SettingsContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let footer: String?
    let showsDivider: Bool
    @ViewBuilder var content: Content

    init(
        _ title: String,
        footer: String? = nil,
        showsDivider: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.showsDivider = showsDivider
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.custom("JetBrainsMono Nerd Font", size: SettingsMetrics.footnoteFontSize).weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, SettingsMetrics.horizontalPadding)
                .padding(.top, SettingsMetrics.sectionHeaderTopPadding)
                .padding(.bottom, SettingsMetrics.sectionHeaderBottomPadding)

            content

            if let footer {
                Text(footer)
                    .font(.custom("JetBrainsMono Nerd Font", size: SettingsMetrics.footnoteFontSize))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, SettingsMetrics.horizontalPadding)
                    .padding(.top, SettingsMetrics.sectionFooterTopPadding)
                    .padding(.bottom, SettingsMetrics.sectionFooterBottomPadding)
            }

            if showsDivider {
                Divider().padding(.horizontal, SettingsMetrics.horizontalPadding)
            }
        }
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: SettingsMetrics.cardCornerRadius)
        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }
}

struct SettingsRow<Content: View>: View {
    let label: String
    @ViewBuilder var content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.custom("JetBrainsMono Nerd Font", size: SettingsMetrics.labelFontSize).weight(.medium))
            Spacer()
            content
        }
        .padding(.horizontal, SettingsMetrics.horizontalPadding)
        .padding(.vertical, SettingsMetrics.rowVerticalPadding)
        .background(rowBackground)
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.clear)
    }
}

struct SettingsToggleRow: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        SettingsRow(label) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
    }
}

struct SettingsPickerRow<Option: CaseIterable & Identifiable & RawRepresentable>: View
    where Option.RawValue == String, Option.AllCases: RandomAccessCollection
{
    let label: String
    @Binding var selection: String
    var width: CGFloat = SettingsMetrics.controlWidth

    var body: some View {
        SettingsRow(label) {
            Picker("", selection: $selection) {
                ForEach(Option.allCases) { option in
                    Text(option.rawValue).tag(option.rawValue)
                }
            }
            .labelsHidden()
            .frame(width: width, alignment: .trailing)
        }
    }
}

extension View {
    func resetsSettingsFocusOnOutsideClick() -> some View {
        background(SettingsFocusResetView())
    }
}

private struct SettingsFocusResetView: NSViewRepresentable {
    func makeNSView(context: Context) -> SettingsFocusResetNSView {
        SettingsFocusResetNSView()
    }

    func updateNSView(_ nsView: SettingsFocusResetNSView, context: Context) {}
}

private final class SettingsFocusResetNSView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(nil)
        super.mouseDown(with: event)
    }
}
