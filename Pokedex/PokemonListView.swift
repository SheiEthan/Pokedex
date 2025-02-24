import SwiftUI

struct PokemonListView: View {
    @StateObject var viewModel = PokemonViewModel()  // Initialisation du ViewModel
    @EnvironmentObject var favoriteManager: FavoriteManager
    @State private var selectedPokemon: Pokemon?
    @State private var showDetailView = false
    @State private var selectedType: String = "Tous"  // Type sélectionné (avec "Tous" comme valeur par défaut)
    @State private var showFavoritesOnly = false  // État du toggle pour les favoris uniquement
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    // 🔎 Barre de recherche
                    SearchBar(text: $viewModel.searchText)
                    
                    // 📝 Sélecteur de type avec un Picker
                    HStack {
                        Text("Filtrer par type")
                            .font(.headline)
                        
                        Picker("Sélectionnez un type", selection: $selectedType) {
                            Text("Tous").tag("Tous")  // Option pour afficher tous les Pokémon
                            ForEach(viewModel.allPokemonTypes, id: \.self) { type in
                                Text(type.capitalized).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)
                        .onChange(of: selectedType) { _ in
                            viewModel.filterPokemon(byType: selectedType)
                        }
                    }
                    .padding(.vertical)
                    
                    // ✅ Toggle pour activer/désactiver les favoris uniquement
                    Toggle(isOn: $showFavoritesOnly) {
                        Text("Afficher seulement les favoris")
                            .font(.subheadline)
                    }
                    .padding()

                    // 📄 Liste des Pokémon filtrée en fonction du toggle
                    List(viewModel.filteredPokemonList.filter { pokemon in
                        // Si le toggle est activé, ne montrer que les favoris
                        !showFavoritesOnly || favoriteManager.isFavorite(pokemon: pokemon)
                    }) { pokemon in
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
                           
                            Text(pokemon.name.capitalized)
                                .font(.headline)
                            Spacer()
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
                }
                .onAppear {
                    viewModel.loadData()
                }
            }
            
            // 📝 Vue des détails du Pokémon
            if showDetailView, let selectedPokemon = selectedPokemon {
                Color.black.opacity(0.4)
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
                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.height * 0.8)
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
