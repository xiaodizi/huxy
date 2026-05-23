import SwiftUI


struct NotificationPanelItem: Identifiable {
    let id: UUID
    let title: String
    let body: String
    let isRead: Bool
}

struct NotificationPanel: View {
    @Environment(AppState.self) private var appState
    @Environment(\ .dismiss) private var onDismiss
    private var items: [NotificationPanelItem] {
        NotificationStore.shared.notifications.map { n in
            NotificationPanelItem(
                id: n.id,
                title: n.title,
                body: n.body,
                isRead: n.isRead
            )
        }
    }
    var body: some View {
        ZStack {
            NotificationPanelBlurView()
            VStack(spacing: 0) {
                let currentItems = items
                if currentItems.isEmpty {
                    emptyState
                } else {
                    header
                    Divider().overlay(MuxyTheme.border)
                    notificationList(currentItems)
                }
            }
            .frame(width: 320, height: 400)
        }
=======
        .frame(width: UIMetrics.scaled(320), height: UIMetrics.scaled(400))
>>>>>>> 39aac594430dda14cc0a49ea7f20993e3192a871
    }
    // ...existing code...

    private var header: some View {
        HStack {
            Text("Notifications")
<<<<<<< HEAD
                .font(.custom("JetBrainsMono Nerd Font", size: 12).weight(.semibold))
                .font(.system(size: UIMetrics.fontBody, weight: .semibold))
                .foregroundStyle(MuxyTheme.fg)
            Spacer()
            Button {
                NotificationStore.shared.clear()
            } label: {
                Text("Clear All")
                    .font(.system(size: UIMetrics.fontFootnote))
                    .foregroundStyle(MuxyTheme.fgMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, UIMetrics.spacing5)
        .padding(.vertical, UIMetrics.spacing4)
    }

    private func notificationList(_ currentItems: [NotificationPanelItem]) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(currentItems) { item in
                    NotificationRow(item: item, isHighlighted: false, onRemove: {
                        NotificationStore.shared.remove(item.id)
                    })
                    .contentShape(Rectangle())
                    .onTapGesture { selectItem(item) }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(notificationAccessibilityLabel(for: item))
                    .accessibilityAddTraits(.isButton)
                }
            }
            .padding(.vertical, UIMetrics.spacing2)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Notifications")
                    .font(.system(size: UIMetrics.fontBody, weight: .semibold))
                    .foregroundStyle(MuxyTheme.fg)
                Spacer()
            }
            .padding(.horizontal, UIMetrics.spacing5)
            .padding(.vertical, UIMetrics.spacing4)

            Divider().overlay(MuxyTheme.border)

            VStack(spacing: UIMetrics.spacing4) {
                Spacer()
                Image(systemName: "bell.slash")
                    .font(.system(size: UIMetrics.fontHero, weight: .light))
                    .foregroundStyle(MuxyTheme.fgMuted)
                Text("No notifications")
                    .font(.system(size: UIMetrics.fontBody, weight: .medium))
                    .foregroundStyle(MuxyTheme.fgMuted)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func notificationAccessibilityLabel(for item: NotificationPanelItem) -> String {
        var label = item.title
        if !item.body.isEmpty { label += ": \(item.body)" }
        if !item.isRead { label += ", unread" }
        return label
    }

    private func selectItem(_ item: NotificationPanelItem) {
        let store = NotificationStore.shared
        guard let notification = store.notifications.first(where: { $0.id == item.id }) else { return }
        NotificationNavigator.navigate(
            to: notification,
            appState: appState,
            notificationStore: store
        )
        onDismiss()
    }
}

private struct NotificationRow: View {
    let item: NotificationPanelItem
    let isHighlighted: Bool
    let onRemove: () -> Void
    @State private var hovered = false

    var body: some View {
        HStack(alignment: .top, spacing: UIMetrics.spacing4) {
            Circle()
                .fill(item.isRead ? Color.clear : MuxyTheme.accent)
                .frame(width: UIMetrics.scaled(6), height: UIMetrics.scaled(6))
                .padding(.top, UIMetrics.scaled(5))

            VStack(alignment: .leading, spacing: UIMetrics.spacing1) {
                HStack {
                    Image(systemName: "bell")
                        .font(.custom("JetBrainsMono Nerd Font", size: 10))
                        .foregroundStyle(MuxyTheme.fgMuted)
                    Text(item.title)
                        .font(.custom("JetBrainsMono Nerd Font", size: 12).weight(.semibold))
                        .foregroundStyle(MuxyTheme.fg)
                        .lineLimit(1)
                    Spacer()
                    EmptyView()
                        .font(.custom("JetBrainsMono Nerd Font", size: 10))
                    Image(systemName: item.sourceIcon)
                        .font(.system(size: UIMetrics.fontCaption))
                        .foregroundStyle(MuxyTheme.fgMuted)
                    Text(item.title)
                        .font(.system(size: UIMetrics.fontBody, weight: .semibold))
                        .foregroundStyle(MuxyTheme.fg)
                        .lineLimit(1)
                    Spacer()
                    Text(item.relativeTimestamp)
                        .font(.system(size: UIMetrics.fontCaption))
                        .foregroundStyle(MuxyTheme.fgMuted)
                    if hovered {
                        dismissButton
                    }
                }

                if !item.body.isEmpty {
                    Text(item.body)
                        .font(.system(size: UIMetrics.fontFootnote))
                        .foregroundStyle(MuxyTheme.fgMuted)
                        .lineLimit(2)
                }
            }
        }
        .padding(.horizontal, UIMetrics.spacing5)
        .padding(.vertical, UIMetrics.spacing3)
        .background(isHighlighted ? MuxyTheme.surface : (hovered ? MuxyTheme.hover : .clear))
        .onHover { hovered = $0 }
    }

    private var dismissButton: some View {
        Button {
            onRemove()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: UIMetrics.fontMicro, weight: .bold))
                .foregroundStyle(MuxyTheme.fgMuted)
                .frame(width: UIMetrics.iconMD, height: UIMetrics.iconMD)
                .background(MuxyTheme.surface, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dismiss Notification")
    }
}

struct NotificationPanelBlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
