import SwiftUI

/// Onglet Recherche
struct RechercheView: View {
    @EnvironmentObject var ctrl: WeatherController
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Rechercher une ville")
                    .font(.title2).fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 50)

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))

                    TextField("Ex: Lyon, Tokyo...", text: $text)
                        .foregroundColor(.white)
                        .focused($focused)
                        .submitLabel(.search)
                        .onSubmit { lancerRecherche() }

                    if !text.isEmpty {
                        Button { text = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .padding(.horizontal)

                Button("Chercher") { lancerRecherche() }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40).padding(.vertical, 10)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(10)
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)

                if ctrl.isLoading {
                    ProgressView().tint(.white).padding(.top, 10)
                }

                Spacer()
            }
        }
    }

    private func lancerRecherche() {
        let q = text.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return }
        focused = false
        ctrl.searchCity(q)
    }
}
