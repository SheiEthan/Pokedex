import SwiftUI
struct PokemonListView: View {
    @StateObject var viewModel = PokemonViewModel()
    @EnvironmentObject var favoriteManager: FavoriteManager
    @State private var selectedPokemon: Pokemon?
    @State private var showDetailView = false
    
    var body: some View {
        ZStack {
            NavigationView {
                List(viewModel.pokemonList) { pokemon in
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
                        
                        Button(action: {
                            favoriteManager.toggleFavorite(pokemon: pokemon)
                        }) {
                            Image(systemName: favoriteManager.isFavorite(pokemon: pokemon) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedPokemon = pokemon
                            showDetailView = true
                        }
                    }
                }
                .navigationTitle("Pokédex")
                .onAppear {
                    viewModel.loadData()
                }
            }
            
            // Custom Sheet with animation
            if showDetailView, let selectedPokemon = selectedPokemon {
                Color.black.opacity(0.4) // Flou d'arrière-plan
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showDetailView = false
                        }
                    }
                
                PokemonDetailView(pokemon: selectedPokemon, onClose: {
                    withAnimation(.spring()) {
                        showDetailView = false
                    }
                })
                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.height * 0.8) // 🔥 AUGMENTE LA TAILLE ICI
                  .background(Color.white)
                  .clipShape(RoundedRectangle(cornerRadius: 20))
                  .shadow(radius: 10)
                  .padding()
                  .transition(.opacity)
                  .zIndex(1)
            }
        }
    }
}

