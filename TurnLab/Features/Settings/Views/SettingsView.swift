import SwiftUI

/// Settings screen with premium purchase and preferences.
struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showPremiumSheet = false

    #if DEBUG
    private let contentManager: ContentManager?
    @State private var debugSelectedLevel: SkillLevel = .beginner
    #endif

    init(viewModel: SettingsViewModel, contentManager: ContentManager? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        #if DEBUG
        self.contentManager = contentManager
        #endif
    }

    var body: some View {
        List {
            // Premium section
            if !viewModel.isPremium {
                Section {
                    Button(action: { showPremiumSheet = true }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)

                            VStack(alignment: .leading) {
                                Text("Unlock Premium")
                                    .font(TurnLabTypography.headline)
                                    .foregroundStyle(TurnLabColors.textPrimary)

                                Text("Access all skill levels • \(viewModel.premiumPrice)")
                                    .font(TurnLabTypography.caption)
                                    .foregroundStyle(TurnLabColors.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(TurnLabColors.textTertiary)
                        }
                    }

                    Button(action: {
                        Task { await viewModel.restorePurchases() }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Restore Purchases")
                        }
                    }
                    .disabled(viewModel.isLoadingPurchase)
                } header: {
                    Text("Premium")
                }
            } else {
                Section {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                        Text("Premium Active")
                            .foregroundStyle(.green)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                } header: {
                    Text("Status")
                }
            }

            // Preferences section
            Section {
                Toggle(isOn: Binding(
                    get: { viewModel.notificationsEnabled },
                    set: { viewModel.updateNotificationPreference($0) }
                )) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(Color.accentColor)
                        Text("Practice Reminders")
                    }
                }
            } header: {
                Text("Notifications")
            }

            // About section
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundStyle(TurnLabColors.textSecondary)
                }

                Link(destination: URL(string: "https://chungty.github.io/turnlab-ios/privacy.html")!) {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(TurnLabColors.textTertiary)
                    }
                }

                Link(destination: URL(string: "https://chungty.github.io/turnlab-ios/terms.html")!) {
                    HStack {
                        Text("Terms of Service")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(TurnLabColors.textTertiary)
                    }
                }
            } header: {
                Text("About")
            }

            // Support section
            Section {
                Link(destination: URL(string: "mailto:support@turnlab.app")!) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(Color.accentColor)
                        Text("Contact Support")
                    }
                }

                // TODO: Uncomment after App Store approval and update with real App ID
                // Link(destination: URL(string: "https://apps.apple.com/app/idXXXXXXXXXX?action=write-review")!) {
                //     HStack {
                //         Image(systemName: "star.fill")
                //             .foregroundStyle(.yellow)
                //         Text("Rate Turn Lab")
                //     }
                // }
            } header: {
                Text("Support")
            }

            // MARK: - Debug Section (Development Only)
            #if DEBUG
            Section {
                // Premium toggle
                Toggle(isOn: Binding(
                    get: { viewModel.isPremium },
                    set: { _ in viewModel.debugTogglePremium() }
                )) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.purple)
                        Text("Simulate Premium")
                    }
                }

                // Current state info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Current Level:")
                            .foregroundStyle(TurnLabColors.textSecondary)
                        Text(viewModel.debugAppState.currentUserLevel.displayName)
                            .fontWeight(.medium)
                    }
                    HStack {
                        Text("Granted Skills:")
                            .foregroundStyle(TurnLabColors.textSecondary)
                        Text("\(viewModel.debugAppState.grantedFreeSkillIds.count)")
                            .fontWeight(.medium)
                    }
                }
                .font(.caption)

                // Level picker with grant skills
                VStack(alignment: .leading, spacing: 8) {
                    Text("Simulate Assessment Level")
                        .font(.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)

                    Picker("Level", selection: $debugSelectedLevel) {
                        ForEach(SkillLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)

                    Button("Apply Level & Grant Skills") {
                        let skills = contentManager?.skills ?? []
                        viewModel.debugSetAssessedLevel(debugSelectedLevel, availableSkills: skills)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                // Reset buttons
                Button(role: .destructive) {
                    viewModel.debugResetGrantedSkills()
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Reset Granted Free Skills")
                    }
                }

                Button(role: .destructive) {
                    viewModel.debugResetOnboarding()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Onboarding (Full Reset)")
                    }
                }
            } header: {
                HStack {
                    Image(systemName: "hammer.fill")
                    Text("Developer Tools")
                }
            } footer: {
                Text("These controls are only visible in debug builds. They allow testing premium states and the Fair Access Model.")
            }
            #endif
        }
        .navigationTitle("Settings")
        .task {
            await viewModel.loadData()
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumPurchaseView(viewModel: viewModel)
        }
        .alert("Restore Successful", isPresented: $viewModel.showRestoreSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your premium purchase has been restored.")
        }
        .alert("Error", isPresented: .constant(viewModel.purchaseError != nil)) {
            Button("OK", role: .cancel) {
                viewModel.purchaseError = nil
            }
        } message: {
            if let error = viewModel.purchaseError {
                Text(error)
            }
        }
    }
}

#Preview {
    let contentManager = ContentManager()
    return NavigationStack {
        SettingsView(
            viewModel: SettingsViewModel(
                premiumManager: PremiumManager(
                    userRepository: UserRepository(coreDataStack: .preview),
                    purchaseService: PurchaseService()
                ),
                userRepository: UserRepository(coreDataStack: .preview),
                appState: AppState()
            ),
            contentManager: contentManager
        )
    }
}
