//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Manon LEVET on 2/17/25.
//

import SwiftUI

struct PokemonDetailView: View {
    var pokemon: Pokemon
    
    var body: some View {
        VStack {
            // Affiche l'image du Pokémon
            if let url = URL(string: pokemon.imageUrl), !pokemon.imageUrl.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 150, height: 150)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                    case .failure:
                        Image(systemName: "exclamationmark.triangle.fill")
                            .frame(width: 150, height: 150)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .padding()
            
            // Affiche les types du Pokémon
            Text("Types: \(pokemon.types.joined(separator: ", "))")
                .font(.title2)
                .padding(.top)
            
            // Affiche les statistiques (exemple : attaques, défense, etc.)
            VStack(alignment: .leading, spacing: 10) {
                Text("Stats:")
                    .font(.headline)
                ForEach(pokemon.stats, id: \.statName) { stat in
                    Text("\(stat.statName.capitalized): \(stat.baseStat)")
                        .font(.subheadline)
                }
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
}
