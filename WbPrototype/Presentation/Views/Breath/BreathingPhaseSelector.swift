//
//  BreathingPhaseSelector.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.

import SwiftUI

struct BreathingPhaseSelector: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State private var isEditingCycles = false
    @State private var selectorHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
//            VStack(spacing: 8) {
//                Button {
//                    withAnimation(.easeInOut) {
//                        isEditingCycles.toggle()
//                    }
//                } label: {
//                    HStack(spacing: 6) {
//                        Text(viewModel.durationString(for: viewModel.cycleCount))
//                            .font(.title.bold())
//                        Image(systemName: isEditingCycles ? "chevron.up" : "chevron.down")
//                            .font(.caption.bold())
//                    }
//                    .foregroundColor(.white)
//                }
//                .buttonStyle(.plain)
            VStack(spacing: 4) {
                Button {
                    withAnimation(.easeInOut) {
                        isEditingCycles.toggle()
                    }
                } label: {
                    VStack(spacing: 2) {
                        HStack(spacing: 6) {
                            Text(viewModel.durationString(for: viewModel.cycleCount))
                                .font(.title.bold())
                        }

                        // ugly but requested
                        Text("Change Time")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 100)
                
                ZStack {
                    VStack(spacing: 8) {
//                        HStack(spacing: 8) {
//                            Menu {
//                                Picker("Breathing Library", selection: $viewModel.selectedPreset) {
//                                    ForEach(BreathingPreset.allCases) { preset in
//                                        Text(preset.rawValue)
//                                            .tag(preset)
//                                    }
//                                }
//                            } label: {
//                                dropdownLabel(
//                                    title: "Library",
//                                    value: viewModel.selectedPreset.rawValue
//                                )
//                            }
//
//                            Spacer()
//                        }

                        HStack(spacing: 12) {
                            collapsedBox(title: "Inhale", value: viewModel.settings.inhale)
                                .onTapGesture { viewModel.select(.inhale) }

                            collapsedBox(title: "Hold in", value: viewModel.settings.holdIn)
                                .onTapGesture { viewModel.select(.holdIn) }

                            collapsedBox(title: "Exhale", value: viewModel.settings.exhale)
                                .onTapGesture { viewModel.select(.exhale) }

                            collapsedBox(title: "Hold out", value: viewModel.settings.holdOut)
                                .onTapGesture { viewModel.select(.holdOut) }
                        }
                    }
                    .opacity(isEditingCycles ? 0 : 1)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: HeightKey.self, value: geo.size.height)
                        }
                    )

                    VStack(spacing: 4) {
                        Slider(
                            value: Binding(
                                get: { Double(viewModel.cycleCount) },
                                set: { viewModel.cycleCount = Int($0.rounded()) }
                            ),
                            in: 1...60,
                            step: 1,
                            onEditingChanged: { editing in
                                if !editing {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        withAnimation(.easeInOut) {
                                            isEditingCycles = false
                                        }
                                    }
                                }
                            }
                        )
                        .tint(.white)

                        Text("\(viewModel.cycleCount) Breathing Cycles")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    .opacity(isEditingCycles ? 1 : 0)
                }
                .frame(height: selectorHeight)
                .onPreferenceChange(HeightKey.self) { h in
                    if selectorHeight == 0 {
                        selectorHeight = h
                    }
                }
            }
            .animation(.easeInOut, value: isEditingCycles)

            if let selected = viewModel.selectedPhase {
                expandedBox(
                    phase: selected,
                    value: valueForPhase(selected)
                )
                .padding(.horizontal)
                .offset(y: 50)
                .zIndex(10)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

private extension BreathingPhaseSelector {
    func collapsedBox(title: String, value: Double) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .foregroundColor(.white)
                .font(.caption)

            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 58, height: 58)

                Text(String(format: "%.1f", value))
                    .foregroundColor(.white)
                    .font(.title3.bold())
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.black.opacity(0.35))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    func expandedBox(phase: BreathingPhase, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack {
                Text(title(for: phase))
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(String(format: "%.1fs", value))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)

                Button {
                    viewModel.closeSelection()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.primary.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }


            Slider(
                value: Binding(
                    get: { value },
                    set: { viewModel.update(phase: phase, value: $0) }
                ),
                in: sliderRange(for: phase),
                step: 1
            )

        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.15),
            radius: 16,
            y: 6
        )

    }

    func dropdownLabel(title: String, value: String) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))

                Text(value)
                    .font(.callout.bold())
                    .foregroundColor(.white)
            }

            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.black.opacity(0.35))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    func controlButton(icon: String) -> some View {
        Image(systemName: icon)
            .padding()
            .background(Color.black.opacity(0.3))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

// MARK: - Helpers
private extension BreathingPhaseSelector {

    func sliderRange(for phase: BreathingPhase) -> ClosedRange<Double> {
        switch phase {
        case .inhale, .exhale:
            return 1...10
        case .holdIn, .holdOut:
            return 0...10
        }
    }

    func valueForPhase(_ phase: BreathingPhase) -> Double {
        switch phase {
        case .inhale: return viewModel.settings.inhale
        case .holdIn: return viewModel.settings.holdIn
        case .exhale: return viewModel.settings.exhale
        case .holdOut: return viewModel.settings.holdOut
        }
    }

    func title(for phase: BreathingPhase) -> String {
        switch phase {
        case .inhale: return "Inhale"
        case .holdIn: return "Hold In"
        case .exhale: return "Exhale"
        case .holdOut: return "Hold Out"
        }
    }

    struct HeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

#Preview {
    let repo = LocalBreathingRepository()
    let initialSettings = repo.load()
    let libraryVM = LibraryViewModel(
        repository: repo,
        initial: initialSettings
    )
    LibraryView(viewModel: libraryVM)
}

