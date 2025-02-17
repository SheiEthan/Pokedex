import SwiftUI

struct PokemonListView: View {
    @StateObject var viewModel = PokemonViewModel()
    @State private var selectedPokemon: Pokemon? = nil // Pokémon sélectionné
    @State private var isSheetPresented = false // Gère l'affichage du sheet
    
    var body: some View {
            List(viewModel.pokemonList) { pokemon in
                HStack {
                    if let url = URL(string: pokemon.imageUrl), !pokemon.imageUrl.isEmpty {
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
                .onTapGesture {
                    selectedPokemon = pokemon
                    isSheetPresented.toggle() // Afficher le sheet
                }
            }
            .navigationTitle("Pokédex")
            .onAppear {
                viewModel.loadData()
            }
            .sheet(isPresented: $isSheetPresented) {
                // Affiche le Sheet avec les détails du Pokémon sélectionné
                if let selectedPokemon = selectedPokemon {
                    PokemonDetailView(pokemon: selectedPokemon)
                }
            }
        }
    }

