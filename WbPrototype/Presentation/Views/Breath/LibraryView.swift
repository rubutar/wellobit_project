//
//  LibraryView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.


//import SwiftUI
//import WatchConnectivity
//
//struct LibraryView: View {
//    @StateObject var libraryViewModel: LibraryViewModel
//    @StateObject var sceneSettingsViewModel: SceneSettingsViewModel
//    @StateObject var playerViewModel: BreathingPlayerViewModel
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        ZStack {
//            Image(sceneSettingsViewModel.selectedScene.imageName)
//                .resizable()
//                .scaledToFill()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .clipped()
//                .ignoresSafeArea()
//
//            Color.black.opacity(0.25)
//                .ignoresSafeArea()
//
//            ZStack {
//                Image(sceneSettingsViewModel.selectedScene.imageName)
//                    .resizable()
//                    .scaledToFill()
//                    .ignoresSafeArea()
//
//                Color.black.opacity(0.25)
//                    .ignoresSafeArea()
//
//                VStack {
////                    header
//                    Spacer()
//
//                    BreathingPlayer(
//                        viewModel: playerViewModel,
//                        libraryViewModel: libraryViewModel,
//                        sceneSettingsViewModel: sceneSettingsViewModel
//                    )
//
//                    BreathingPhaseSelector(viewModel: libraryViewModel)
//                        .opacity(playerViewModel.isPlaying ? 0 : 1)
//                        .allowsHitTesting(!playerViewModel.isPlaying)
//
//                    Spacer()
//                }
//
//                HStack {
//                    Spacer()
//                    BreathingPlayerControls(
//                        viewModel: playerViewModel,
//                        sceneSettingsViewModel: sceneSettingsViewModel
//                    )
//                }
//                .padding(.top, 100)
//
//                BadgePopupView(viewModel: popupVM) {
//                    playerViewModel.showBadgePopup = false
//                    playerViewModel.badgePopupViewModel = nil
//                }
//                    .zIndex(10)
//                }
//            }
//            .simultaneousGesture(
//                TapGesture().onEnded {
//                    NotificationCenter.default.post(
//                        name: .showBreathingControls,
//                        object: nil
//                    )
//                }
//            )
//
//
////            if playerViewModel.showPreSessionModal {
////                MindfulnessOverlay(
////                    onConfirm: {
////                        playerViewModel.showPreSessionModal = false
////                        playerViewModel.play()
////                    },
////                    onClose: {
////                        playerViewModel.showPreSessionModal = false
////                    }
////                )
////            }
//
//        }
//        .toolbar(.hidden, for: .tabBar)
////        .navigationBarBackButtonHidden(true)
//        .onAppear {
//            playerViewModel.start()
//        }
//        .onDisappear {
//            playerViewModel.pauseIfNeeded()
//            playerViewModel.teardown()
//        }
//    }
////    private var header: some View {
////        HStack(spacing: 12) {
////            Button {
////                dismiss()
////            } label: {
////                Image(systemName: "chevron.left")
////                    .font(.title2)
////                    .foregroundColor(.white)
////                    .padding(10)
////                    .background(Color.black.opacity(0.4))
////                    .clipShape(Circle())
////            }
////
////            Text("Library")
////                .font(.headline)
////                .foregroundColor(.white)
////                .lineLimit(1)
////
////            Spacer()
////        }
////        .padding(.horizontal, 28)
////        .padding(.top, 72)
////    }
//
//}


//
//  LibraryView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.


import SwiftUI
import WatchConnectivity


struct LibraryView: View {
    @StateObject var libraryViewModel: LibraryViewModel
    @StateObject var sceneSettingsViewModel: SceneSettingsViewModel
    @StateObject var playerViewModel: BreathingPlayerViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject var badgeProgressViewModel = BadgeProgressViewModel(useMockData: true)

    
    
    
    var body: some View {
        ZStack {
            // MARK: - Main Content
            mainContent
                .zIndex(0)
                .fullScreenCover(isPresented: $badgeProgressViewModel.showBadgePopup) {
                    BadgePopupView(viewModel: badgeProgressViewModel) {
                        badgeProgressViewModel.closeBadgePopup()
                    }
                    .ignoresSafeArea()
                }
        }
        .toolbar(.hidden, for: .tabBar)
//        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("🧪 LibraryView onAppear — wiring onBadgeEarned")

            playerViewModel.onBadgeEarned = { badgeId in
                print("🧪 LibraryView RECEIVED badgeId =", badgeId)

                print("🧪 BadgeProgress IDs:",
                      badgeProgressViewModel.progresses.map { $0.id })

                if let progress = badgeProgressViewModel.progresses.first(
                    where: { $0.id == badgeId }
                ) {
                    print("🧪 MATCH FOUND → BadgeProgress id =", progress.id)
                    badgeProgressViewModel.selectBadge(progress)
                } else {
                    print("❌ NO MATCH for badgeId =", badgeId)
                }
            }

            playerViewModel.start()
        }
        .onDisappear {
            playerViewModel.onBadgeEarned = nil
            playerViewModel.pauseIfNeeded()
            playerViewModel.teardown()
        }

    }
    private var mainContent: some View {
        ZStack {

            Image(sceneSettingsViewModel.selectedScene.imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack {
//                header
                Spacer()

                BreathingPlayer(
                    viewModel: playerViewModel,
                    libraryViewModel: libraryViewModel,
                    sceneSettingsViewModel: sceneSettingsViewModel
                )

                BreathingPhaseSelector(viewModel: libraryViewModel)
                    .opacity(playerViewModel.isPlaying ? 0 : 1)
                    .allowsHitTesting(!playerViewModel.isPlaying)

                Spacer()
            }

            HStack {
                Spacer()
                BreathingPlayerControls(
                    viewModel: playerViewModel,
                    sceneSettingsViewModel: sceneSettingsViewModel
                )
            }
            .padding(.top, 100)
        }
        .simultaneousGesture(
            playerViewModel.showBadgePopup
            ? nil
            : TapGesture().onEnded {
                NotificationCenter.default.post(
                    name: .showBreathingControls,
                    object: nil
                )
                NotificationCenter.default.post(
                    name: .showCenterPauseButton,
                    object: nil
                )
            }
        )
    }
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }

            Spacer()
        }
        .padding(.leading, 16)
        .padding(.top, 50)
    }

}
    


import UIKit

final class NoBackSwipeGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
}
import SwiftUI

struct DisableBackSwipe: ViewModifier {

    private let delegate = NoBackSwipeGestureDelegate()

    func body(content: Content) -> some View {
        content
            .background(
                DisableBackSwipeController(delegate: delegate)
            )
    }
}


struct DisableBackSwipeController: UIViewControllerRepresentable {

    let delegate: UIGestureRecognizerDelegate

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            if let nav = uiViewController.navigationController {
                nav.interactivePopGestureRecognizer?.delegate = delegate
                nav.interactivePopGestureRecognizer?.isEnabled = true
            }
        }
    }
    
}

extension Notification.Name {
    static let showCenterPauseButton = Notification.Name("showCenterPauseButton")
}

