//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Ethan TILLIER on 2/17/25.
//

import SwiftUI

@main
struct PokedexApp: App {
    let persistenceController = PersistenceController.shared
//    @StateObject private var favoriteManager = FavoriteManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environmentObject(favoriteManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
