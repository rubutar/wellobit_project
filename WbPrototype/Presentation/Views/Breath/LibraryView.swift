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
    
    var body: some View {
        ZStack {
//            Image(sceneSettingsViewModel.selectedScene.imageName)
//                .resizable()
//                .scaledToFill()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .clipped()
//                .ignoresSafeArea()

            if !playerViewModel.showBadgePopup {
                    // Player background ONLY when popup is NOT shown
                    Image(sceneSettingsViewModel.selectedScene.imageName)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }

                // Player content always here

                if playerViewModel.showBadgePopup {
                    BadgePopupView {
                        playerViewModel.showBadgePopup = false
                    }
                    .zIndex(100)
                }
            
            Color.black.opacity(0.25)
                .ignoresSafeArea()
            VStack {
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

                Spacer()
            }
            .zIndex(20)
            ZStack {
                Image(sceneSettingsViewModel.selectedScene.imageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
//                    if playerViewModel.isResting {
//                        Text("isResting : TRUE")
//                    } else {
//                        Text("isResting : FALSE")
//                    }
                    
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
                
//                if playerViewModel.showBadgePopup {
//                    BadgePopupView {
//                        playerViewModel.showBadgePopup = false
//                    }
//                    .zIndex(100)
//                }
            }
//            .simultaneousGesture(
//                TapGesture().onEnded {
//                    NotificationCenter.default.post(
//                        name: .showBreathingControls,
//                        object: nil
//                    )
//                }
//            )
            .simultaneousGesture(
                TapGesture().onEnded {
                    // UI intent ONLY
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


            
            
//            if playerViewModel.showPreSessionModal {
//                MindfulnessOverlay(
//                    onConfirm: {
//                        playerViewModel.showPreSessionModal = false
//                        playerViewModel.play()
//                    },
//                    onClose: {
//                        playerViewModel.showPreSessionModal = false
//                    }
//                )
//            }
            
        }
//        .navigationTitle("Library")
//        .background(DisableInteractivePopGesture())
//        .modifier(DisableBackSwipe())
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
//            UIApplication.shared.disableInteractivePopGesture()
            playerViewModel.start()
        }
        .onDisappear {
//            UIApplication.shared.disableInteractivePopGesture()
            playerViewModel.pauseIfNeeded()
            playerViewModel.teardown()
        }
    }
}


//struct DisableInteractivePopGesture: UIViewControllerRepresentable {
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        let controller = UIViewController()
//        DispatchQueue.main.async {
//            controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//        }
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//}

//import UIKit
//
//extension UIApplication {
//    func disableInteractivePopGesture() {
//        guard
//            let windowScene = connectedScenes.first as? UIWindowScene,
//            let root = windowScene.windows.first?.rootViewController
//        else { return }
//
//        let nav = findNavigationController(from: root)
//        nav?.interactivePopGestureRecognizer?.isEnabled = false
//    }
//
//    func enableInteractivePopGesture() {
//        guard
//            let windowScene = connectedScenes.first as? UIWindowScene,
//            let root = windowScene.windows.first?.rootViewController
//        else { return }
//
//        let nav = findNavigationController(from: root)
//        nav?.interactivePopGestureRecognizer?.isEnabled = true
//    }
//
//    private func findNavigationController(from vc: UIViewController) -> UINavigationController? {
//        if let nav = vc as? UINavigationController {
//            return nav
//        }
//        for child in vc.children {
//            if let nav = findNavigationController(from: child) {
//                return nav
//            }
//        }
//        return nil
//    }
//}

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

import SwiftUI

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
