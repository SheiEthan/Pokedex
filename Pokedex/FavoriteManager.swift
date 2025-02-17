import SwiftUI
import Combine

class FavoriteManager: ObservableObject {
    @Published var favoritePokemons: [Pokemon] = []  // Liste des Pokémon favoris
    
    // Méthode pour ajouter ou retirer un Pokémon des favoris
    func toggleFavorite(pokemon: Pokemon) {
        if let index = favoritePokemons.firstIndex(where: { $0.id == pokemon.id }) {
            // Si le Pokémon est déjà favori, on le retire
            favoritePokemons.remove(at: index)
        } else {
            // Sinon, on l'ajoute
            favoritePokemons.append(pokemon)
        }
    }
    
    // Vérifie si un Pokémon est dans les favoris
    func isFavorite(pokemon: Pokemon) -> Bool {
        favoritePokemons.contains(where: { $0.id == pokemon.id })
    }
}
