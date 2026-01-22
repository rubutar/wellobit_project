//
//  EmptyInfoSheet.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 20/01/26.
//

import SwiftUI


struct EmptyInfoSheet: View {
    var body: some View {
        Color.clear
            .presentationDragIndicator(.visible)
            .presentationDetents(
                [.medium, .large],
                selection: .constant(.medium)
            )
    }
}
