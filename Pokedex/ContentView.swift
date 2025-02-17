//
//  ContentView.swift
//  Pokedex
//
//  Created by Ethan TILLIER on 2/17/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()

        var body: some View {
            NavigationView {
                List(viewModel.pokemonList) { pokemon in
                    HStack {
                        if let imageUrl = pokemon.imageUrl, let url = URL(string: imageUrl) {
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

        private func extractPokemonID(from url: String) -> String {
            return url
                .split(separator: "/")
                .last.map(String.init) ?? "?"
        }
    }

    // Modèles à l'intérieur du même fichier
    struct PokemonListResponse: Codable {
        let results: [PokemonListItem]
    }

    struct PokemonListItem: Codable, Identifiable {
        let id = UUID() // Identifiant unique pour List
        let name: String
        let url: String
        var imageUrl: String?
    }

class PokemonViewModel: ObservableObject {
    @Published var pokemonList: [PokemonListItem] = []
    
    func loadData() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=15") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let decodedData = try JSONDecoder().decode(PokemonListResponse.self, from: data)
                
                // Récupérer les détails pour chaque Pokémon
                let group = DispatchGroup()
                var updatedPokemonList: [PokemonListItem] = []
                
                for pokemon in decodedData.results {
                    group.enter()
                    self.fetchPokemonDetails(for: pokemon) { detailedPokemon in
                        updatedPokemonList.append(detailedPokemon)  // Ajout du Pokémon avec l'image mise à jour
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.pokemonList = updatedPokemonList  // Une fois toutes les images récupérées, mettre à jour la liste
                }
                
            } catch {
                print("Erreur de décodage : \(error)")
            }
        }.resume()
    }
    
    private func fetchPokemonDetails(for pokemon: PokemonListItem, completion: @escaping (PokemonListItem) -> Void) {
        let pokemonDetailURL = pokemon.url
        guard let url = URL(string: pokemonDetailURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let pokemonDetail = try JSONDecoder().decode(PokemonDetail.self, from: data)
                var updatedPokemon = pokemon
                // Vérification si l'image existe, sinon utiliser une image par défaut pour ce Pokémon
                updatedPokemon.imageUrl = pokemonDetail.sprites.frontDefault ?? "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png" // Image par défaut du Pokémon #1 (Bulbizarre)
                
                DispatchQueue.main.async {
                    completion(updatedPokemon)  // Retourner le Pokémon mis à jour avec l'image
                }
            } catch {
                print("Erreur lors de la récupération des détails : \(error)")
            }
        }.resume()
    }
}

// Structure des détails du Pokémon pour récupérer l'image
struct PokemonDetail: Codable {
    let sprites: PokemonSprites
}

struct PokemonSprites: Codable {
    let frontDefault: String?
}
    

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
