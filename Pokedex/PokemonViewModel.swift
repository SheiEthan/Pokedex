import SwiftUI
import Combine

class PokemonViewModel: ObservableObject {
    @Published var pokemonList: [Pokemon] = []  // Liste complète des Pokémon
    @Published var filteredPokemonList: [Pokemon] = []  // Liste filtrée par le texte de recherche
    @Published var searchText: String = ""  // Texte de recherche
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observation du texte de recherche
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterPokemon()
            }
            .store(in: &cancellables)
    }
    
    func loadData() {
        // Si la liste est déjà remplie, on ne refait pas l'appel API
        if pokemonList.isEmpty {
            fetchPokemonList()
        } else {
            filteredPokemonList = pokemonList  // Si déjà rempli, on affiche tout
        }
    }
    
    private func fetchPokemonList() {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: PokemonListResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .flatMap { [weak self] results in
                guard let self = self else {
                    return Empty<Pokemon, Error>().eraseToAnyPublisher() // Flux vide si self est nil
                }
                let pokemonPublishers = results.map { pokemon in
                    self.fetchPokemonDetails(pokemon: pokemon)
                }
                return Publishers.MergeMany(pokemonPublishers)
                    .eraseToAnyPublisher() // Nous retournons un AnyPublisher
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching Pokémon data: \(error)")
                }
            }, receiveValue: { [weak self] pokemon in
                self?.addPokemonIfNotExists(pokemon)  // Ajouter Pokémon seulement s'il n'existe pas déjà
            })
            .store(in: &cancellables)
    }
    
    private func addPokemonIfNotExists(_ pokemon: Pokemon) {
        // Vérifie si le Pokémon existe déjà dans la liste (en fonction de l'id ou du nom)
        if !pokemonList.contains(where: { $0.id == pokemon.id }) {
            pokemonList.append(pokemon)
            filteredPokemonList = pokemonList  // On met à jour la liste filtrée avec tous les Pokémon
        }
    }
    
    private func fetchPokemonDetails(pokemon: PokemonResponse) -> AnyPublisher<Pokemon, Error> {
        let url = URL(string: pokemon.url)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: PokemonDetails.self, decoder: JSONDecoder())
            .map { details in
                // Créer un Pokémon complet avec son image et ses types/statistiques
                return Pokemon(
                    id: Int(pokemon.url.hash),  // Utilisation du hash de l'URL pour l'id unique
                    name: pokemon.name,
                    imageUrl: details.sprites.front_default,
                    types: details.types.map { $0.type.name },  // Récupère les noms des types
                    stats: details.stats.map { stat in
                        Pokemon.Stat(statName: stat.stat.name, baseStat: stat.base_stat)  // Mappe les statistiques
                    },
                    isFavorite: false
                )
            }
            .eraseToAnyPublisher()
    }
    
    // Filtrage des Pokémon en fonction du texte de recherche
    func filterPokemon() {
        if searchText.isEmpty {
            filteredPokemonList = pokemonList  // Si rien n'est tapé, on affiche tous les Pokémon
        } else {
            filteredPokemonList = pokemonList.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}
