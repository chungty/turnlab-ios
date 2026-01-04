import SwiftUI

/// Settings screen with premium purchase and preferences.
struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showPremiumSheet = false

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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

                Link(destination: URL(string: "https://turnlab.app/privacy")!) {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(TurnLabColors.textTertiary)
                    }
                }

                Link(destination: URL(string: "https://turnlab.app/terms")!) {
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

                Link(destination: URL(string: "https://apps.apple.com/app/id123456789?action=write-review")!) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("Rate Turn Lab")
                    }
                }
            } header: {
                Text("Support")
            }
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
    NavigationStack {
        SettingsView(
            viewModel: SettingsViewModel(
                premiumManager: PremiumManager(
                    userRepository: UserRepository(coreDataStack: .preview),
                    purchaseService: PurchaseService()
                ),
                userRepository: UserRepository(coreDataStack: .preview),
                appState: AppState()
            )
        )
    }
}
