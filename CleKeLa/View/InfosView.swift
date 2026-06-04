import SwiftUI

/// Onglet Infos : version, build et état de l'API.
struct InfosView: View {
    @EnvironmentObject var ctrl: WeatherController

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Informations")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40).padding(.bottom, 8)

                    InfoCard(title: "Application") {
                        InfoRow(label: "Version", value: "\(version) (build \(build))")
                        InfoRow(label: "Bundle",  value: Bundle.main.bundleIdentifier ?? "N/A")
                    }

                    InfoCard(title: "API Météo") {
                        InfoRow(label: "Service",  value: "Open-Meteo")
                        InfoRow(label: "Site web", value: "open-meteo.com")
                        InfoRow(label: "Statut",   value: ctrl.apiStatus)
                    }
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(ctrl.apiOk ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                            .padding(12)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear { ctrl.checkAPI() }
    }
}

// MARK: Composants
private struct InfoCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
        }
    }
}
