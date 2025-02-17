import SwiftUI
struct PokemonListView: View {
    @StateObject var viewModel = PokemonViewModel()
    @State private var selectedPokemon: Pokemon? // Gère le Pokémon sélectionné
    @State private var showDetailSheet = false // Indicateur pour afficher ou non le sheet
    
    var body: some View {
        NavigationView {
            List(viewModel.pokemonList) { pokemon in
                Button(action: {
                    // Lorsque l'utilisateur appuie sur un Pokémon, on l'assigne à `selectedPokemon`
                    selectedPokemon = pokemon
                    showDetailSheet = true // On affiche le sheet
                }) {
                    HStack {
                        AsyncImage(url: URL(string: pokemon.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable().scaledToFit().frame(width: 50, height: 50)
                            case .failure:
                                Image(systemName: "exclamationmark.triangle.fill")
                            @unknown default:
                                EmptyView()
                            }
                        }
                        Spacer()
                        Text(pokemon.name.capitalized)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Pokédex")
            .onAppear {
                viewModel.loadData()
            }
            // Présentation du sheet lorsque showDetailSheet est true
            .sheet(isPresented: $showDetailSheet) {
                if let selectedPokemon = selectedPokemon {
                    PokemonDetailView(pokemon: selectedPokemon)
                }
            }
        }
    }
}
