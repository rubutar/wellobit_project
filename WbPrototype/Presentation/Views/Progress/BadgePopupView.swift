//
//  BadgePopupView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 02/02/26.
//

import SwiftUI
import UIKit

struct BadgePopupView: View {

    @ObservedObject var viewModel: BadgeProgressViewModel
    let onNiceTapped: () -> Void
    @State private var shareImage: UIImage?
//    @State private var showShareSheet = false

    

    var body: some View {
        ZStack {
            Image("bgBadge")
                .resizable()
                .ignoresSafeArea()
            
            if viewModel.isPopupLoading {
                ProgressView()
            } else if let badge = viewModel.selectedBadge {
                content(badge)
            }
        }
    }

    @ViewBuilder
    private func content(_ badge: Badge) -> some View {
        VStack(spacing: 24) {

            Spacer(minLength: 40)

            // Title
            VStack(spacing: 8) {
                Text("Achievement\nUnlocked 🎉")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("Added to your collection")
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(0.6))
            }

            Spacer(minLength: 20)

            // Card
            VStack(spacing: 16) {

                Image(badge.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .cornerRadius(16)

                Text(badge.title)
                    .font(.system(size: 22, weight: .bold))

                Text(badge.description)
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                if let date = badge.earnedAt {
                    HStack(spacing: 32) {

                        Image("icn_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 60)

                        
                        VStack {
                            Text("earned on")
                                .font(.system(size: 12))
                                .foregroundColor(.black.opacity(0.5))
                            
                            Text(date.formattedBadgeDate())
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black.opacity(0.8))
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(28)
            .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
            .padding(.horizontal, 20)

            Spacer()

            buttons
        }
    }

    private var buttons: some View {
        VStack(spacing: 12) {

            Button {
                    guard let badge = viewModel.selectedBadge else { return }

                    let storyView = BadgeStoryShareView(badge: badge)
                    let image = storyView.renderAsStoryImage()

                    print("Story image:", image.size) // should be 1080×1920

                    if image.size.width > 0 {
                        shareImage = image
                    }
            } label: {
                Text("Share this")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.tmBlue)
                    .cornerRadius(30)
            }


            Button {
                onNiceTapped()
            } label: {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("ThemeColor"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .sheet(item: $shareImage) { image in
            ShareSheet(items: [image])
        }

    }
//    private func shareItems(for badge: Badge) -> [Any] {
//        var items: [Any] = []
//
//        if let image = UIImage(named: badge.imageName) {
//            items.append(image)
//        }
//
//        let text = """
//        🎉 Achievement Unlocked!
//        \(badge.title)
//
//        \(badge.description)
//        """
//
//        items.append(text)
//
//        return items
//    }

}

extension UIImage: Identifiable {
    public var id: UUID { UUID() }
}


extension Date {
    func formattedBadgeDate() -> String {
        formatted(.dateTime.day().month(.abbreviated).year(.twoDigits))
    }
}

struct BadgeStoryShareView: View {

    let badge: Badge

    var body: some View {
        ZStack {

            // 🌈 Background image
            Image("bgBadge")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // 🎴 Centered badge card (original proportions)
            BadgeShareCardView(badge: badge)
                .frame(maxWidth: 600) // 👈 prevents stretching
                .padding(.horizontal, 80)
        }
        .frame(width: 1080, height: 1920) // 👈 9:16
    }
}


struct BadgeShareCardView: View {

    let badge: Badge

    var body: some View {
        VStack(spacing: 20) {

            // Badge image — BIGGER
            Image(badge.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 260)

            // Title — BIGGER
            Text(badge.title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            // Description — BIGGER & flexible
            Text(badge.description)
                .font(.system(size: 18))
                .foregroundColor(.black.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            // Date row (logo + date)
            if let date = badge.earnedAt {
                HStack(spacing: 32) {
                    
                    Image("icn_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 60)
                    
                    VStack {
                        Text("earned on")
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.5))
                        
                        Text(date.formattedBadgeDate())
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(40)                // 👈 bigger padding
        .background(Color.white)
        .cornerRadius(32)           // 👈 slightly rounder
        .shadow(radius: 24)
    }
}






extension View {

    func renderAsStoryImage() -> UIImage {

        let size = CGSize(width: 1080, height: 1920)

        let controller = UIHostingController(rootView: self)
        let view = controller.view!

        view.bounds = CGRect(origin: .zero, size: size)
        view.backgroundColor = .clear
        view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}




final class PreviewBadgeRepository: BadgeRepository {
    func getBadge(for sequence: Int) async -> Badge? {
        Badge(
            id: "calm_breather",
            title: "Calm Breather",
            description: "Completed your first breathing session.",
            imageName: "1imBadge",
            imageBadge: "11imBadge",
            earnedAt: Date()
        )
    }
}

#Preview("Badge Popup") {
    let vm = BadgeProgressViewModel(useMockData: false)

    vm.selectedBadge = Badge(
        id: "preview_badge",
        title: "Calm Breather",
        description: """
        Stability begins with breath.
        You showed up, stayed present,
        and earned this moment.
        """,
        imageName: "1imBadge",
        imageBadge: "11imBadge",
        earnedAt: Date()
    )

    vm.isPopupLoading = false
    vm.showBadgePopup = true

    return BadgePopupView(
        viewModel: vm,
        onNiceTapped: {}
    )
}

//#Preview("Badge Popup") {
//    let vm = BadgeProgressViewModel(useMockData: false)
//
//    // Simulate earned badge
//    vm.selectedBadge = Badge(
//        id: "preview_badge",
//        title: "Calm Breather",
//        description: """
//        Stability begins with breath.
//        You showed up, stayed present,
//        and earned this moment.
//        """,
//        imageName: "1imBadge",
//        earnedAt: Date()
//    )
//
//    vm.isPopupLoading = false
//
//    return BadgePopupView(
//        viewModel: vm,
//        onNiceTapped: {}
//    )
//}

