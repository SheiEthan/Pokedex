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
    var body: some View {
        // On emballe la vue principale dans une NavigationView
        NavigationView {
            PokemonListView() // La vue qui affiche la liste des Pokémon
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // Prévisualisation de la ContentView
    }
}

    
