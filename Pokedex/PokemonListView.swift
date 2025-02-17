//
//  PokemonListView.swift
//  Pokedex
//
//  Created by Manon LEVET on 2/17/25.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject var viewModel = PokemonViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.pokemonList) { pokemon in
                HStack {
                    // Vérifie si imageUrl est valide (on n'a plus besoin d'un if let ici)
                    if let url = URL(string: pokemon.imageUrl), pokemon.imageUrl.isEmpty == false {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            case .failure:
                                // Affiche un symbole si l'image ne peut pas être chargée
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .frame(width: 50, height: 50)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    Spacer()
                    Text(pokemon.name.capitalized)
                        .font(.headline)
                }
                
            }
            .navigationTitle("Pokédex")
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}
