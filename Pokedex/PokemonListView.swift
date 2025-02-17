import SwiftUI
struct PokemonListView: View {
    @StateObject var viewModel = PokemonViewModel()
    @EnvironmentObject var favoriteManager: FavoriteManager  // Récupère le gestionnaire de favoris
    @State private var selectedPokemon: Pokemon?  // Pokémon sélectionné pour afficher les détails
    @State private var showDetailSheet = false  // Afficher le sheet avec les détails
    
    var body: some View {
        NavigationView {
            List(viewModel.pokemonList) { pokemon in
                HStack {
                    // Affichage de l'image du Pokémon
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
                    
                    // Afficher l'icône de favori avec un bouton cliquable
                    Button(action: {
                        favoriteManager.toggleFavorite(pokemon: pokemon)  // Toggle des favoris
                    }) {
                        Image(systemName: favoriteManager.isFavorite(pokemon: pokemon) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                    .buttonStyle(PlainButtonStyle())  // Utilisation de PlainButtonStyle pour éviter les effets de bouton par défaut
                }
                .padding()
                // Ajouter un tap gesture pour ouvrir les détails du Pokémon
                .onTapGesture {
                    selectedPokemon = pokemon
                    showDetailSheet = true
                }
            }
            .navigationTitle("Pokédex")
            .onAppear {
                viewModel.loadData()
            }
            // Affichage du sheet avec les détails du Pokémon
            .sheet(isPresented: $showDetailSheet) {
                if let selectedPokemon = selectedPokemon {
                    PokemonDetailView(pokemon: selectedPokemon)
                        .onAppear {
                            print("Pokemon Details View appeared for: \(selectedPokemon.name)")
                        }
                }
            }
        }
    }
}
