import SwiftUI

@MainActor
struct CloneRepositorySheet: View {
    @Environment(AppState.self) var appState
    @Environment(ProjectStore.self) var projectStore
    @Environment(WorktreeStore.self) var worktreeStore

    @State private var repositoryURL = ""
    @State private var selectedAuthMethod: GitCloneService.AuthMethod = .https
    @State private var selectedPath: String?
    @State private var cloneState = GitCloneState.idle
    @State private var isPickingFolder = false

    private let gitCloneService = GitCloneService()

    var body: some View {
        VStack(spacing: 16) {
            Text("Clone Repository from GitHub")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Repository URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("https://github.com/user/repo.git", text: $repositoryURL)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Authentication Method")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker("Auth", selection: $selectedAuthMethod) {
                    Text("HTTPS").tag(GitCloneService.AuthMethod.https)
                    Text("SSH").tag(GitCloneService.AuthMethod.ssh)
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Target Directory")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack {
                    Text(selectedPath ?? "Choose folder...")
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button("Browse", action: selectTargetFolder)
                        .buttonStyle(.bordered)
                }
                .padding(8)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(6)
            }

            if case let .cloning(progress, message) = cloneState {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: progress)
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if case let .completed(path) = cloneState {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    Text("Clone completed!")
                        .font(.headline)
                    Text(path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
            } else if case let .failed(error) = cloneState {
                VStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    Text("Clone failed")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    appState.showCloneSheet = false
                    cloneState = .idle
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Clone") {
                    Task {
                        await performClone()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isFormValid || cloneState.isCloning)
            }
        }
        .padding(24)
        .frame(minWidth: 500, minHeight: 400)
        .fileImporter(
            isPresented: $isPickingFolder,
            allowedContentTypes: [],
            onCompletion: { result in
                if case let .success(url) = result {
                    selectedPath = url.path
                }
            }
        )
    }

    private var isFormValid: Bool {
        !repositoryURL.isEmpty && selectedPath != nil
    }

    private func selectTargetFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Select target directory for cloning"

        if panel.runModal() == .OK, let url = panel.url {
            selectedPath = url.path
        }
    }

    private func performClone() async {
        guard let targetPath = selectedPath else { return }

        cloneState = .cloning(progress: 0, message: "Starting clone...")

        do {
            let resultPath = try await gitCloneService.clone(
                repositoryURL: repositoryURL,
                targetPath: targetPath,
                authMethod: selectedAuthMethod
            ) { progress, message in
                Task { @MainActor in
                    cloneState = .cloning(progress: progress, message: message)
                }
            }

            let repoName = (repositoryURL as NSString).lastPathComponent
                .replacingOccurrences(of: ".git", with: "")

            let project = projectStore.createFromClone(
                name: repoName,
                path: resultPath,
                repositoryURL: repositoryURL,
                authMethod: selectedAuthMethod == .https ? "https" : "ssh"
            )

            worktreeStore.ensurePrimary(for: project)
            if let primaryWorktree = worktreeStore.primary(for: project.id) {
                await MainActor.run {
                    appState.selectProject(project, worktree: primaryWorktree)
                }
            }

            cloneState = .completed(path: resultPath)

            try await Task.sleep(nanoseconds: 1_000_000_000)
            appState.showCloneSheet = false
            cloneState = .idle
        } catch let error as GitCloneService.CloneError {
            cloneState = .failed(error: error.localizedDescription)
        } catch {
            cloneState = .failed(error: error.localizedDescription)
        }
    }
}
