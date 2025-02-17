import Foundation

struct Pokemon: Identifiable, Codable {
    var id: Int
    var name: String
    var imageUrl: String
}

struct PokemonListResponse: Codable {
    let results: [PokemonResponse]
}

struct PokemonResponse: Codable {
    let name: String
    let url: String
}

struct PokemonDetails: Codable {
    let sprites: Sprites
}

struct Sprites: Codable {
    let front_default: String
}
