import SwiftUI

/// Sheet for inputting skill assessments.
struct AssessmentInputView: View {
    @StateObject private var viewModel: AssessmentViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AssessmentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TurnLabSpacing.lg) {
                    // Skill header
                    if let skill = viewModel.skill {
                        VStack(spacing: TurnLabSpacing.xs) {
                            Text(skill.name)
                                .font(TurnLabTypography.title2)
                                .foregroundStyle(TurnLabColors.textPrimary)

                            LevelBadge(level: skill.level)
                        }
                        .padding(.top)
                    }

                    // Terrain context picker
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                        Text("Terrain Context")
                            .font(TurnLabTypography.headline)

                        TerrainContextPicker(
                            selectedContext: $viewModel.selectedContext,
                            availableContexts: viewModel.availableContexts
                        )
                        .onChange(of: viewModel.selectedContext) { _, newContext in
                            viewModel.selectContext(newContext)
                        }
                    }
                    .padding(.horizontal)

                    // Existing rating indicator
                    if let existing = viewModel.existingRating, existing != .notAssessed {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Previous: \(existing.displayName)")
                        }
                        .font(TurnLabTypography.caption)
                        .foregroundStyle(existing.color)
                        .padding(.horizontal)
                    }

                    // Rating picker
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                        Text("Your Rating")
                            .font(TurnLabTypography.headline)
                            .padding(.horizontal)

                        if let milestones = viewModel.milestones {
                            AssessmentPicker(
                                selectedRating: $viewModel.selectedRating,
                                milestones: milestones
                            )
                            .padding(.horizontal)
                        }
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                        Text("Notes (Optional)")
                            .font(TurnLabTypography.headline)

                        TextEditor(text: $viewModel.notes)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.horizontal)

                    // Improvement indicator
                    if viewModel.isImproved {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundStyle(.green)
                            Text("Great progress! You've improved!")
                                .foregroundStyle(.green)
                        }
                        .font(TurnLabTypography.callout)
                    }

                    Spacer(minLength: TurnLabSpacing.xl)

                    // Save button
                    PrimaryButton(
                        title: "Save Assessment",
                        icon: "checkmark.circle",
                        isLoading: viewModel.isSaving,
                        isDisabled: !viewModel.canSave
                    ) {
                        Task {
                            if await viewModel.saveAssessment() {
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                await viewModel.loadData()
            }
            .overlay {
                if viewModel.showSuccess {
                    SuccessOverlay()
                }
            }
        }
    }
}

struct SuccessOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: TurnLabSpacing.md) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)

                Text("Saved!")
                    .font(TurnLabTypography.title2)
                    .foregroundStyle(.white)
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    let container = DIContainer.preview
    return AssessmentInputView(viewModel: container.makeAssessmentViewModel(skillId: "basic-athletic-stance"))
}
