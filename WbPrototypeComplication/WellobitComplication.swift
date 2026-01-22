//
//  WellobitComplication.swift
//  WellobitComplication
//
//  Created by Rudi Butarbutar on 04/12/25.
//

import WidgetKit
import SwiftUI

struct HRVProvider: TimelineProvider {

    func placeholder(in context: Context) -> HRVEntry {
        HRVEntry(date: Date(), hrv: 75)
    }

    func getSnapshot(in context: Context, completion: @escaping (HRVEntry) -> ()) {
        let entry = HRVEntry(date: Date(), hrv: 72)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HRVEntry>) -> ()) {

        let currentHRV = Int.random(in: 50...100) // dummy for now
        let entry = HRVEntry(date: Date(), hrv: currentHRV)

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!

        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }

struct HRVEntry: TimelineEntry {
    let date: Date
    let hrv: Int
}

struct HRVStarterComplicationEntryView : View {
    var entry: HRVProvider.Entry

    var body: some View {
        Text("\(entry.hrv)")
            .font(.system(.title2, design: .rounded))
            .bold()
    }
}

//@main
struct HRVStarterComplication: Widget {
    let kind: String = "HRVStarterComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HRVProvider()) { entry in
            HRVStarterComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("HRV")
        .description("Shows your latest HRV number.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ])
    }
}

//#Preview(as: .accessoryRectangular) {
//    WellobitComplication()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}
