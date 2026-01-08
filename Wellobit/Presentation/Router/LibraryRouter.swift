//
//  Navi.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 08/01/26.
//

import SwiftUI

enum LibraryDestination: Hashable {
    case scenes
}


final class LibraryRouter {
    
    @ViewBuilder
    func makeDestination(_ destination: LibraryDestination) -> some View {
        switch destination {
        case .scenes:
            SceneListView()
        }
    }
}
