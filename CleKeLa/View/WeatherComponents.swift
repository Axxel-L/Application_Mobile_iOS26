import SwiftUI

/// Composant réutilisable : icône + valeur
struct WeatherDetail: View {
    let icon: String
    let value: String

    var body: some View {
        VStack {
            Image(systemName: icon).font(.title2)
            Text(value).font(.headline)
        }
    }
}
