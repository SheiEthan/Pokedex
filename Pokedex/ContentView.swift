//
//  ContentView.swift
//  Pokedex
//
//  Created by Ethan TILLIER on 2/17/25.
//

import SwiftUI
import CoreData
import SwiftUI

struct ContentView: View {
    @StateObject var favoriteManager = FavoriteManager()  // Gère les favoris globalement
    
    var body: some View {
        PokemonListView()
            .environmentObject(favoriteManager)  // Passe l'objet FavoriteManager à la vue enfant
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // Prévisualisation de la ContentView
    }
}

    
