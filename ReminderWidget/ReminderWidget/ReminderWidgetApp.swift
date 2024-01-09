//
//  ReminderWidgetApp.swift
//  ReminderWidget
//
//  Created by haijunyan on 2023/12/20.
//  .onOpenURL 回调状态
//  openURL 动作
//  SwiftUI框架(UI渲染) .onOpenURL

import SwiftUI

@main
struct ReminderWidgetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL(perform: { url in
                    print("Inside onOpenURL..\(url)")
                 })
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard userActivity.webpageURL != nil else { return }
                     print("Inside onContinueUserActivity....")
                 }

        }.commands {
            CommandGroup(replacing: .newItem, addition: { })
         }
        .handlesExternalEvents(matching: Set(arrayLiteral: "{same path of URL?}"))
    }
}
