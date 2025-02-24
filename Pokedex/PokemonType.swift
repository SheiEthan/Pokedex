enum PokemonType: String, CaseIterable {
    case normal = "normal"
    case fire = "fire"
    case water = "water"
    case electric = "electric"
    case grass = "grass"
    case ice = "ice"
    case fighting = "fighting"
    case poison = "poison"
    case ground = "ground"
    case flying = "flying"
    case psychic = "psychic"
    case bug = "bug"
    case rock = "rock"
    case ghost = "ghost"
    case dragon = "dragon"
    case dark = "dark"
    case steel = "steel"
    case fairy = "fairy"
    
    static var allTypes: [String] {
        return PokemonType.allCases.map { $0.rawValue }
    }
}
