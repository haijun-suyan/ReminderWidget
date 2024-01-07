//
//  ReminderWidgetApp.swift
//  ReminderWidget
//
//  Created by haijunyan on 2023/12/20.
//

import SwiftUI

@main
struct ReminderWidgetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    print("\(url)")
                }
        }.commands {
            CommandGroup(replacing: .newItem, addition: { })
         }
        .handlesExternalEvents(matching: Set(arrayLiteral: "{same path of URL?}"))
    }
}
