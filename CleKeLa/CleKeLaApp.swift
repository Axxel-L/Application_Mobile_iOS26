import SwiftUI

@main
struct CleKeLaApp: App {
    @StateObject private var controller = WeatherController()

    var body: some Scene {
        WindowGroup {
            TabView {
                MeteoView()
                    .tabItem {
                        Image(systemName: "cloud.sun.fill")
                        Text("Météo")
                    }

                PrevisionsView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Prévisions")
                    }

                RechercheView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Recherche")
                    }
            }
            .environmentObject(controller)
            .preferredColorScheme(.dark)
        }
    }
}
