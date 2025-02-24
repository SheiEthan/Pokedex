import SwiftUI

struct PokemonListView: View {
    @StateObject var viewModel = PokemonViewModel()
    @EnvironmentObject var favoriteManager: FavoriteManager

    @State private var selectedPokemon: Pokemon?
    @State private var showDetailView = false
    @State private var selectedType: String = "Tous"
    @State private var showFavoritesOnly = false
    @State private var sortOrder: SortOrder = .normal // Valeur par défaut

    @Namespace private var animationNamespace  // Namespace pour l’animation de zoom

    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    enum SortOrder {
        case normal, alphabetical, reverseAlphabetical
    }

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    HStack {
                       Spacer() // Pour pousser les éléments vers la droite
                       Text("Mode sombre")
                           .font(.subheadline)
                       Toggle(isOn: $isDarkMode) {
                           EmptyView() // Vide pour n'afficher que le toggle
                       }
                       .labelsHidden() // Cache le label du Toggle
                       .onChange(of: isDarkMode) { newValue in
                           UserDefaults.standard.set(newValue, forKey: "isDarkMode")
                       }
                   }
                    // Barre de recherche
                    SearchBar(text: $viewModel.searchText)

                    // Sélecteur de type
                    HStack {
                      
                        Text("Filtrer par type").font(.headline)
                        Picker("Type", selection: $selectedType) {
                            Text("Tous").tag("Tous")
                            ForEach(viewModel.allPokemonTypes, id: \.self) { type in
                                Text(type.capitalized).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedType) { _ in
                            viewModel.filterPokemon(byType: selectedType)
                        }
                    }
                    .padding(.horizontal)

                    // Toggle pour afficher seulement les favoris
                    Toggle(isOn: $showFavoritesOnly) {
                        Text("Afficher seulement les favoris").font(.subheadline)
                    }.padding(.horizontal)
                    // Tri des Pokémon
                    Picker("Trier", selection: $sortOrder) {
                        Text("Normal").tag(SortOrder.normal)
                        Text("Alphabétique").tag(SortOrder.alphabetical)
                        Text("Décroissant").tag(SortOrder.reverseAlphabetical)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Liste des Pokémon filtrée et triée
                    List(sortedPokemonList()) { pokemon in
                        HStack {
                            // Image du Pokémon
                            AsyncImage(url: URL(string: pokemon.imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .matchedGeometryEffect(id: "pokemonImage-\(pokemon.id)", in: animationNamespace)  // Effet de zoom lié
                                case .failure:
                                    Image(systemName: "exclamationmark.triangle.fill")
                                @unknown default:
                                    EmptyView()
                                }
                            }

                            Text(pokemon.name.capitalized)
                                .font(.headline)

                            Spacer()

                            // Zone cliquable entre le texte et l'étoile
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    selectedPokemon = pokemon
                                    showDetailView = true
                                }
                            }) {
                                Spacer() // Cet espace fait en sorte qu'on peut cliquer entre le texte et l'étoile
                            }

                            // Bouton favori tout à droite
                            Button(action: {
                                favoriteManager.toggleFavorite(pokemon: pokemon)
                            }) {
                                Image(systemName: favoriteManager.isFavorite(pokemon: pokemon) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }.padding(.horizontal)
                    }
                }
                .onAppear { viewModel.loadData() }
            }

            // Vue détail avec matchedGeometryEffect
            if showDetailView, let selectedPokemon = selectedPokemon {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showDetailView = false
                        }
                    }

                PokemonDetailView(
                    pokemon: selectedPokemon,
                    animationNamespace: animationNamespace,
                    onClose: {
                        withAnimation(.spring()) {
                            showDetailView = false
                        }
                    }
                )
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.7)
                .zIndex(1)
            }
        }
    }

    // Fonction pour trier et filtrer les Pokémon selon l'ordre choisi et le filtre des favoris
    private func sortedPokemonList() -> [Pokemon] {
        // Filtrage des favoris si nécessaire
        let filteredPokemon = showFavoritesOnly ?
            viewModel.filteredPokemonList.filter { favoriteManager.isFavorite(pokemon: $0) } :
            viewModel.filteredPokemonList

        // Tri des Pokémon après filtrage
        switch sortOrder {
        case .normal:
            return filteredPokemon
        case .alphabetical:
            return filteredPokemon.sorted { $0.name.lowercased() < $1.name.lowercased() }
        case .reverseAlphabetical:
            return filteredPokemon.sorted { $0.name.lowercased() > $1.name.lowercased() }
        }
    }
}
