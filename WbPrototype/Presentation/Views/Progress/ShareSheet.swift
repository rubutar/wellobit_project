//
//  ShareSheet.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 10/02/26.
//


//
//  ShareSheet.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 06/02/26.
//


import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {

    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}
