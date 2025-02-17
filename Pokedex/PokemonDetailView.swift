import SwiftUI
struct PokemonDetailView: View {
    var pokemon: Pokemon
    var onClose: () -> Void

    var body: some View {
        VStack {
            HStack {
               
                Button(action: {
                    withAnimation(.spring()) {
                        onClose()
                    }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                        .padding()
                }
                Spacer()
            }

            AsyncImage(url: URL(string: pokemon.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFit().frame(width: 150, height: 150)
                case .failure:
                    Image(systemName: "exclamationmark.triangle.fill")
                @unknown default:
                    EmptyView()
                }
            }

            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 10)

            VStack(alignment: .leading, spacing: 10) {
                Text("Types:")
                    .font(.headline)
                HStack {
                    ForEach(pokemon.types, id: \.self) { type in
                        Text(type.capitalized)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                Text("Stats:")
                    .font(.headline)
                ForEach(pokemon.stats, id: \.statName) { stat in
                    HStack {
                        Text(stat.statName.capitalized)
                            .frame(width: 100, alignment: .leading)
                        ProgressView(value: Float(stat.baseStat), total: 150)
                            .frame(width: 150)
                    }
                }
            }
            .padding()

            Spacer()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow, lineWidth: 20) // 🟡 Bordure jaune
        )
    }
}
