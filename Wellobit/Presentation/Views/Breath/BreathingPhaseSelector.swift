//
//  BreathingPhaseSelector.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI

struct BreathingPhaseSelector: View {
    @ObservedObject var viewModel: LibraryViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 8) {
                // ---------------------------------
                // DROPDOWNS
                // ---------------------------------
                HStack(spacing: 8) {
                    // Preset selector
                    Menu {
                        Picker("Breathing Library", selection: $viewModel.selectedPreset) {
                            ForEach(BreathingPreset.allCases) { preset in
                                Text(preset.rawValue)
                                    .tag(preset)
                            }
                        }
                    } label: {
                        dropdownLabel(
                            title: "Library",
                            value: viewModel.selectedPreset.rawValue
                        )
                    }
                    
                    Spacer()
                }
                
                // -----------------------------
                // COLLAPSED ROW
                // -----------------------------
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
                
                // -----------------------------
                // CYCLE SLIDER
                // -----------------------------
                VStack(spacing: 4) {

                    Text(
                        "\(viewModel.cycleCount) Breathing Cycles"
                    )
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    
                    Text(
                        "\(viewModel.durationString(for: viewModel.cycleCount))"
                    )
                    .font(.caption)
                    .foregroundColor(.white)
                    
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.cycleCount) },
                            set: { viewModel.cycleCount = Int($0.rounded()) }
                        ),
                        in: 1...60,
                        step: 1
                    )
                    .tint(.white)
                }
                .padding(.top, 4)
            }
            
            // -----------------------------
            // FLOATING OVERLAY
            // -----------------------------
            if let selected = viewModel.selectedPhase {
                expandedBox(
                    phase: selected,
                    value: valueForPhase(selected)
                )
                .padding(.horizontal)
                .zIndex(10)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

private extension BreathingPhaseSelector {
    
    // MARK: Collapsed Box
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
    
    
    // MARK: Expanded Overlay
    func expandedBox(phase: BreathingPhase, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                Text(title(for: phase))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.1fs", value))
                    .foregroundColor(.white)
                
                Button {
                    viewModel.closeSelection()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Slider(
                value: Binding(
                    get: { value },
                    set: { viewModel.update(phase: phase, value: $0) }
                ),
                in: sliderRange(for: phase),
                step: 1
            )
            
            HStack {
                Button {
                    viewModel.update(phase: phase, value: value - 0.2)
                } label: {
                    controlButton(icon: "minus")
                }
                
                Spacer()
                
                Button {
                    viewModel.update(phase: phase, value: value + 0.2)
                } label: {
                    controlButton(icon: "plus")
                }
            }
        }
        .padding(20)
        .background(
            Color(.systemGray6)
                .opacity(0.95)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(radius: 12)
    }
    
    // MARK: Helpers
    
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
    
    func controlButton(icon: String) -> some View {
        Image(systemName: icon)
            .padding()
            .background(Color.black.opacity(0.3))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

private extension BreathingPhaseSelector {
    
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
}

