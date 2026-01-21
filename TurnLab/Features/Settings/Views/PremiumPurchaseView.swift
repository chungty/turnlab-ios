import SwiftUI

/// Premium purchase sheet.
struct PremiumPurchaseView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TurnLabSpacing.xl) {
                    // Header
                    VStack(spacing: TurnLabSpacing.md) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.yellow)

                        Text("Unlock Premium")
                            .font(TurnLabTypography.largeTitle)
                            .foregroundStyle(TurnLabColors.textPrimary)

                        Text("One-time purchase • No subscription")
                            .font(TurnLabTypography.callout)
                            .foregroundStyle(TurnLabColors.textSecondary)
                    }
                    .padding(.top, TurnLabSpacing.xl)

                    // Features
                    VStack(alignment: .leading, spacing: TurnLabSpacing.md) {
                        FeatureRow(
                            icon: "1.circle.fill",
                            title: "Novice Skills",
                            description: "Build confidence with intermediate techniques"
                        )

                        FeatureRow(
                            icon: "2.circle.fill",
                            title: "Intermediate Skills",
                            description: "Master parallel turns and carving basics"
                        )

                        FeatureRow(
                            icon: "3.circle.fill",
                            title: "Expert Skills",
                            description: "Conquer moguls, steeps, and powder"
                        )

                        FeatureRow(
                            icon: "rectangle.on.rectangle.angled",
                            title: "Home Screen Widget",
                            description: "Quick access to your focus skill"
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusLarge))
                    .padding(.horizontal)

                    Spacer(minLength: TurnLabSpacing.xl)

                    // Purchase button
                    VStack(spacing: TurnLabSpacing.sm) {
                        PrimaryButton(
                            title: "Unlock All Levels • \(viewModel.premiumPrice)",
                            icon: "lock.open.fill",
                            isLoading: viewModel.isLoadingPurchase
                        ) {
                            Task {
                                await viewModel.purchasePremium()
                                if viewModel.isPremium {
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal)

                        Button("Restore Purchases") {
                            Task {
                                await viewModel.restorePurchases()
                                if viewModel.isPremium {
                                    dismiss()
                                }
                            }
                        }
                        .font(TurnLabTypography.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)
                    }

                    // Fine print
                    Text("Payment will be charged to your Apple ID account. Purchases are non-refundable.")
                        .font(.caption2)
                        .foregroundStyle(TurnLabColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Purchase Error", isPresented: .constant(viewModel.purchaseError != nil)) {
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
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: TurnLabSpacing.sm) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TurnLabTypography.headline)
                    .foregroundStyle(TurnLabColors.textPrimary)

                Text(description)
                    .font(TurnLabTypography.caption)
                    .foregroundStyle(TurnLabColors.textSecondary)
            }

            Spacer()
        }
    }
}

#Preview {
    PremiumPurchaseView(
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
