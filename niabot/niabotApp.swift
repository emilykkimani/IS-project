//
//  niabotApp.swift
//  niabot
//
//  Created by Emily on 20/08/2025.
//

import SwiftUI

@main
struct niabotApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
