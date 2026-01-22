////
////  WellobitIOsWidgetLiveActivity.swift
////  WellobitIOsWidget
////
////  Created by Rudi Butarbutar on 22/01/26.
////
//
//import ActivityKit
//import WidgetKit
//import SwiftUI
//
//struct WellobitIOsWidgetAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        // Dynamic stateful properties about your activity go here!
//        var emoji: String
//    }
//
//    // Fixed non-changing properties about your activity go here!
//    var name: String
//}
//
//struct WellobitIOsWidgetLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: WellobitIOsWidgetAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded UI goes here.  Compose the expanded UI through
//                // various regions, like leading/trailing/center/bottom
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Leading")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Trailing")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
//            } compactLeading: {
//                Text("L")
//            } compactTrailing: {
//                Text("T \(context.state.emoji)")
//            } minimal: {
//                Text(context.state.emoji)
//            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(Color.red)
//        }
//    }
//}
//
//extension WellobitIOsWidgetAttributes {
//    fileprivate static var preview: WellobitIOsWidgetAttributes {
//        WellobitIOsWidgetAttributes(name: "World")
//    }
//}
//
//extension WellobitIOsWidgetAttributes.ContentState {
//    fileprivate static var smiley: WellobitIOsWidgetAttributes.ContentState {
//        WellobitIOsWidgetAttributes.ContentState(emoji: "😀")
//     }
//     
//     fileprivate static var starEyes: WellobitIOsWidgetAttributes.ContentState {
//         WellobitIOsWidgetAttributes.ContentState(emoji: "🤩")
//     }
//}
//
//#Preview("Notification", as: .content, using: WellobitIOsWidgetAttributes.preview) {
//   WellobitIOsWidgetLiveActivity()
//} contentStates: {
//    WellobitIOsWidgetAttributes.ContentState.smiley
//    WellobitIOsWidgetAttributes.ContentState.starEyes
//}
