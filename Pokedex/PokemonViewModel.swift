import SwiftUI
import Combine

class PokemonViewModel: ObservableObject {
    @Published var pokemonList: [Pokemon] = []
    @Published var filteredPokemonList: [Pokemon] = []
    @Published var searchText: String = ""
    
    var allPokemonTypes: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observation du texte de recherche pour filtrer automatiquement
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterPokemon(byType: nil)
            }
            .store(in: &cancellables)
    }
    
    func loadData() {
        if pokemonList.isEmpty {
            fetchPokemonList()
        } else {
            filteredPokemonList = pokemonList
            updateAllPokemonTypes()
        }
    }
    
    private func fetchPokemonList() {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: PokemonListResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .flatMap { [weak self] results in
                guard let self = self else { return Empty<Pokemon, Error>().eraseToAnyPublisher() }
                let publishers = results.map { self.fetchPokemonDetails(pokemon: $0) }
                return Publishers.MergeMany(publishers).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ Erreur de récupération : \(error)")
                }
            }, receiveValue: { [weak self] pokemon in
                self?.addPokemonIfNotExists(pokemon)
            })
            .store(in: &cancellables)
    }
    
    private func addPokemonIfNotExists(_ pokemon: Pokemon) {
        if !pokemonList.contains(where: { $0.id == pokemon.id }) {
            pokemonList.append(pokemon)
            filteredPokemonList = pokemonList
            updateAllPokemonTypes()
        }
    }
    
    private func fetchPokemonDetails(pokemon: PokemonResponse) -> AnyPublisher<Pokemon, Error> {
        let url = URL(string: pokemon.url)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: PokemonDetails.self, decoder: JSONDecoder())
            .map { details in
                Pokemon(
                    id: Int(pokemon.url.hash),
                    name: pokemon.name,
                    imageUrl: details.sprites.front_default,
                    types: details.types.map { $0.type.name },
                    stats: details.stats.map { stat in
                        Pokemon.Stat(statName: stat.stat.name, baseStat: stat.base_stat)
                    },
                    is_favorite: false
                )
            }
            .eraseToAnyPublisher()
    }
    
    // Fonction pour filtrer les Pokémon par type et texte de recherche
    func filterPokemon(byType type: String?) {
        filteredPokemonList = pokemonList.filter { pokemon in
            let matchesSearchText = searchText.isEmpty || pokemon.name.lowercased().contains(searchText.lowercased())
            let matchesType = (type == nil || type == "Tous") || pokemon.types.contains(type!)
            return matchesSearchText && matchesType
        }
    }
    
    // Met à jour la liste de tous les types disponibles à partir des Pokémon chargés
    private func updateAllPokemonTypes() {
        let types = pokemonList.flatMap { $0.types }
        allPokemonTypes = Array(Set(types)).sorted()
    }
}
