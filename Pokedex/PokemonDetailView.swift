//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Manon LEVET on 2/17/25.
//

import SwiftUI
struct PokemonDetailView: View {
    @EnvironmentObject var favoriteManager: FavoriteManager  // Récupère le gestionnaire de favoris
    var pokemon: Pokemon
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: pokemon.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFit().frame(width: 150, height: 150)
                case .failure:
                    Image(systemName: "exclamationmark.triangle.fill")
                @unknown default:
                    EmptyView()
                }
            }
            Text(pokemon.name.capitalized)
                .font(.title)
                .padding()
            
            Text("Types: \(pokemon.types.joined(separator: ", "))")
                .font(.subheadline)
            
            Text("Stats:")
                .font(.headline)
            ForEach(pokemon.stats, id: \.statName) { stat in
                Text("\(stat.statName): \(stat.baseStat)")
            }
            
            Button(action: {
                favoriteManager.toggleFavorite(pokemon: pokemon)  // Ajoute ou retire des favoris
            }) {
                Text(favoriteManager.isFavorite(pokemon: pokemon) ? "Remove from Favorites" : "Add to Favorites")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}
