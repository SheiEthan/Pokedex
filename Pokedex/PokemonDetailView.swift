import SwiftUI

struct PokemonDetailView: View {
    var pokemon: Pokemon
    var animationNamespace: Namespace.ID  // 🔑 Récupère le namespace pour le zoom
    var onClose: () -> Void

    @State private var animateImage = false
    @State private var animateStats = false
    @State private var floatImage = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
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

            // 📸 Image avec matchedGeometryEffect + animations existantes
            AsyncImage(url: URL(string: pokemon.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .matchedGeometryEffect(id: "pokemonImage-\(pokemon.id)", in: animationNamespace)  // 🔑 Zoom lié à la liste
                        .offset(y: floatImage ? -10 : 10)  // 🌊 Effet de flottement
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: floatImage)
                        .scaleEffect(animateStats ? 1 : 0.8)  // Rebond à l’apparition
                        .animation(.spring(response: 0.5, dampingFraction: 0.4), value: animateStats)
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
                .opacity(animateImage ? 1 : 0)
                .offset(y: animateImage ? 0 : -20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: animateImage)

            VStack(alignment: .leading, spacing: 15) {
                Text("Types:").font(.headline)
                HStack {
                    ForEach(pokemon.types, id: \.self) { type in
                        Text(type.capitalized)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .scaleEffect(animateImage ? 1 : 0.8)
                            .opacity(animateImage ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: animateImage)
                    }
                }

                Text("Stats:").font(.headline)
                ForEach(pokemon.stats, id: \.statName) { stat in
                    HStack {
                        Text(stat.statName.capitalized)
                            .frame(width: 100, alignment: .leading)

                        ProgressView(value: animateStats ? Float(stat.baseStat) : 0, total: 150)
                            .frame(width: 150)
                            .animation(.easeOut(duration: 1.0).delay(0.2), value: animateStats)
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
                .stroke(Color.yellow, lineWidth: 20)
        )
        .onAppear {
            animateImage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateStats = true
            }
            floatImage = true
        }
        .onDisappear {
            animateImage = false
            animateStats = false
            floatImage = false
        }
    }
}
