import CoreData
import SwiftUI

class FavoriteManager: ObservableObject {
    @Published var favorites: [FavoritePokemonEntity] = [] // Utilisation de FavoritePokemonEntity
    private let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Pokedex")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Erreur de chargement CoreData: \(error)")
            }
        }
        fetchFavorites()  // Charge les favoris au lancement
    }

    // Lire les favoris
    func fetchFavorites() {
        let request: NSFetchRequest<FavoritePokemonEntity> = FavoritePokemonEntity.fetchRequest()
        do {
            favorites = try container.viewContext.fetch(request)
            print("Fetched favorites: \(favorites)")  // Impression des favoris récupérés
        } catch {
            print("Erreur lors du fetch des favoris: \(error)")
        }
    }

    // Ajouter un favori
    // Ajouter un favori
    func addFavorite(pokemon: Pokemon) {
        // Vérifier si le Pokémon est déjà dans les favoris
        guard !isFavorite(pokemon: pokemon) else {
            print("\(pokemon.name) is already in favorites!")
            return
        }

        // Création d'un nouvel objet FavoritePokemonEntity
        let newFavorite = FavoritePokemonEntity(context: container.viewContext)
        newFavorite.idPokemon = Int64(pokemon.id)  // Assigner l'ID du Pokémon
        newFavorite.is_favorite = true  // Définit isFavorite à true

        // Assurer que l'objet est inséré dans le contexte
        container.viewContext.insert(newFavorite)
        
        // Impression pour vérifier avant de sauvegarder
        print("Adding favorite: \(pokemon.name), ID: \(pokemon.id), isFavorite: \(newFavorite.is_favorite)")

        // Sauvegarder le contexte
        saveContext()  // Sauvegarde le contexte après ajout
        fetchFavorites()  // Recharge les favoris après ajout
        print("\(pokemon.name) added to favorites!")
    }


    // Supprimer un favori
    func removeFavorite(pokemon: Pokemon) {
        if let favorite = favorites.first(where: { $0.idPokemon == Int64(pokemon.id) }) {
            container.viewContext.delete(favorite)
            saveContext()
            fetchFavorites()
            print("\(pokemon.name) removed from favorites!")
        }
    }

    // Vérifier si c’est un favori
    func isFavorite(pokemon: Pokemon) -> Bool {
        favorites.contains(where: { $0.idPokemon == Int64(pokemon.id) })
    }

    // Sauvegarder le contexte
    // Sauvegarder le contexte
    private func saveContext() {
        do {
            if container.viewContext.hasChanges {
                try container.viewContext.save()
                print("Context saved successfully.")
            } else {
                print("No changes to save.")
            }
        } catch let error as NSError {
            print("Error saving context: \(error), \(error.userInfo)")
        }
    }


    // Basculer le statut de favori
    func toggleFavorite(pokemon: Pokemon) {
        if isFavorite(pokemon: pokemon) {
            removeFavorite(pokemon: pokemon)
        } else {
            addFavorite(pokemon: pokemon)
        }
    }
}
