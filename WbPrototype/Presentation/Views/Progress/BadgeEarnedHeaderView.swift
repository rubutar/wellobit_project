//
//  BadgeEarnedHeaderView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 05/02/26.
//

import SwiftUI

private struct BadgeCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]



    
    static func reduce(
        value: inout [String: CGFloat],
        nextValue: () -> [String: CGFloat]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}


struct BadgeEarnedHeaderView: View {
//    @ObservedObject var viewModel: BadgeProgressViewModel
    @EnvironmentObject var viewModel: BadgeProgressViewModel
    @State private var badgeCenters: [String: CGFloat] = [:]
    @State private var scrollDebounceTask: DispatchWorkItem?


    @State private var centeredId: String?
    @State private var didCenterOnce = false

    private let badgeSize: CGFloat = 140
    private let sideSpacing: CGFloat = 24

    var body: some View {
        VStack(spacing: 16) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: sideSpacing) {
                        Spacer()
                            .frame(width: badgeSize)
//                        ForEach(viewModel.progresses) { progress in
//                            BadgeItemView(
//                                progress: progress,
//                                isCentered: progress.id == centeredId
//                            )
//                            .id(progress.id)
//                            .onTapGesture {
//                                centeredId = progress.id
//                                withAnimation(.easeInOut) {
//                                    proxy.scrollTo(progress.id, anchor: .center)
//                                }
//                            }
//                        }
                        
                        ForEach(viewModel.progresses) { progress in
                            BadgeItemView(
                                progress: progress,
                                isCentered: progress.id == centeredId
                            )
                            .id(progress.id)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: BadgeCenterPreferenceKey.self,
                                            value: [
                                                progress.id: geo.frame(in: .global).midX
                                            ]
                                        )
                                }
                            )
                            .onTapGesture {
                                centeredId = progress.id
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(progress.id, anchor: .center)
                                }
                            }
                        }


                        // Trailing spacer
                        Spacer()
                            .frame(width: badgeSize)
                    }
                    .padding(.horizontal)
                }
                .onPreferenceChange(BadgeCenterPreferenceKey.self) { value in
                    badgeCenters = value

                    scrollDebounceTask?.cancel()
                    let task = DispatchWorkItem {
                        snapToNearestBadge(proxy: proxy)
                    }
                    scrollDebounceTask = task

                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 0.15,
                        execute: task
                    )
                }

                


                .onChange(of: viewModel.progresses) { _ in
                    print("🧪 Header progresses CHANGED")
                    print("🧪 Header statuses =",
                          viewModel.progresses.map { "\($0.id):\($0.status)" })

                    resetAndSelectInitialBadge()
                    centerBestBadge(proxy: proxy)
                }
                .onAppear {
                    print("🧪 Header APPEAR")
                    print("🧪 Header VM id =", ObjectIdentifier(viewModel))
                    print("🧪 Header statuses =",
                          viewModel.progresses.map { "\($0.id):\($0.status)" })

                    resetAndSelectInitialBadge()
                    centerBestBadge(proxy: proxy)
                }
                

            }

            if let centered = centered {
                VStack(spacing: 6) {
                    Text(centered.badge.title)
                        .font(.title3)
                        .fontWeight(.semibold)

                    statusText(for: centered)
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    private func snapToNearestBadge(proxy: ScrollViewProxy) {
        let screenCenterX = UIScreen.main.bounds.midX

        guard
            let nearestId = badgeCenters.min(
                by: {
                    abs($0.value - screenCenterX) <
                    abs($1.value - screenCenterX)
                }
            )?.key
        else { return }

        centeredId = nearestId

        withAnimation(.easeInOut) {
            proxy.scrollTo(nearestId, anchor: .center)
        }
    }

    
    private func resetAndSelectInitialBadge() {
        didCenterOnce = false
        centeredId =
            viewModel.progresses.first(where: { $0.status == .active })?.id ??
            viewModel.progresses.last(where: { $0.status == .earned })?.id ??
            viewModel.progresses.first?.id
    }

    private var centered: BadgeProgress? {
        viewModel.progresses.first { $0.id == centeredId }
    }

//    private func centerActiveBadge(proxy: ScrollViewProxy) {
//        guard !didCenterOnce else { return }
//        guard let activeId = viewModel.progresses.first(where: { $0.status == .active })?.id else { return }
//
//        didCenterOnce = true
//        centeredId = activeId
//
//        DispatchQueue.main.async {
//            withAnimation(.easeInOut) {
//                proxy.scrollTo(activeId, anchor: .center)
//            }
//        }
//    }
    
    private func centerBestBadge(proxy: ScrollViewProxy) {
        guard !didCenterOnce else { return }

        let targetId =
            viewModel.progresses.first(where: { $0.status == .active })?.id ??
            viewModel.progresses.last(where: { $0.status == .earned })?.id ??
            viewModel.progresses.first?.id

        guard let id = targetId else { return }

        didCenterOnce = true
        centeredId = id

        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                proxy.scrollTo(id, anchor: .center)
            }
        }
    }

//    private func selectInitialBadgeIfNeeded() {
//        if centeredId == nil {
//            centeredId =
//                viewModel.progresses.first(where: { $0.status == .active })?.id ??
//                viewModel.progresses.last(where: { $0.status == .earned })?.id ??
//                viewModel.progresses.first?.id
//        }
//    }

}


// MARK: - Badge item
struct BadgeItemView: View {
    let progress: BadgeProgress
    let isCentered: Bool

    private var imageName: String {
        switch progress.status {
        case .locked:
            return "badge_locked"
        case .active, .earned:
            return progress.badge.imageBadge
        }
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(
                width: isCentered ? 140 : 80,
                height: isCentered ? 140 : 80
            )
            .modifier(ActiveGrayscaleModifier(status: progress.status))
            .opacity(progress.status == .locked ? 0.35 : 1)
            .animation(.easeInOut(duration: 0.25), value: isCentered)
    }
}

struct ActiveGrayscaleModifier: ViewModifier {
    let status: BadgeStatus

    func body(content: Content) -> some View {
        switch status {
        case .active:
            content.grayscale(1.0)
        default:
            content
        }
    }
}


// MARK: - Status text
@ViewBuilder
private func statusText(for progress: BadgeProgress) -> some View {
    switch progress.status {
        
    case .earned:
        if let date = progress.badge.earnedAt {
            Text("Earned on \(date.formatted(date: .abbreviated, time: .omitted))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        
    case .active:
        if let remaining = progress.remainingSessions {
            Text("\(remaining) sessions to go")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        
    case .locked:
        Text("Locked")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}


// MARK: - Preview
#if DEBUG
struct BadgeEarnedHeaderView_Previews: PreviewProvider {

    static var previewViewModel: BadgeProgressViewModel {
        let vm = BadgeProgressViewModel()

        vm.progresses = [
            BadgeProgress(
                id: "calm",
                badge: Badge(
                    id: "b1",
                    title: "Calm Starter",
                    description: "Complete breathing sessions to stay calm",
                    imageName: "badge_sample_1",
                    imageBadge: "badge_sample_1",
                    earnedAt: nil
                ),
                status: .active,
                remainingSessions: 3
            ),
            BadgeProgress(
                id: "focus",
                badge: Badge(
                    id: "b2",
                    title: "Focus Master",
                    description: "Build deep focus with breathing",
                    imageName: "badge_sample_2",
                    imageBadge: "badge_sample_2",
                    earnedAt: Date()
                ),
                status: .earned,
                remainingSessions: nil
            ),
            BadgeProgress(
                id: "zen",
                badge: Badge(
                    id: "b3",
                    title: "Zen Legend",
                    description: "Achieve ultimate calm",
                    imageName: "badge_sample_3",
                    imageBadge: "badge_sample_3",
                    earnedAt: nil
                ),
                status: .locked,
                remainingSessions: nil
            )
        ]

        return vm
    }

    static var previews: some View {
        BadgeEarnedHeaderView()
            .environmentObject(previewViewModel)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Badge Earned Header")
    }
}
#endif
