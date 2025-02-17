//
//  Pokemon.swift
//  Pokedex
//
//  Created by Ethan TILLIER on 2/17/25.
//

import SwiftUI

struct Pokemon: Decodable {
    var name: String
    var image: String
    var types: [String]
    var stats: [String]
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
