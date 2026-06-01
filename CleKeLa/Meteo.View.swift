import SwiftUI

// MARK: Navbar
struct Accueil: View {
    @StateObject private var weatherVM = WeatherViewModel()

    var body: some View {
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
        .accentColor(.white)
        .preferredColorScheme(.dark)
        .environmentObject(weatherVM)
    }
}

// MARK: Météo actuelle
struct MeteoView: View {
    @EnvironmentObject var weatherVM: WeatherViewModel

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            if weatherVM.isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                VStack(spacing: 20) {
                    Spacer()

                    Image(systemName: weatherVM.iconName)
                        .font(.system(size: 80))
                        .foregroundColor(.white)

                    Text(weatherVM.cityName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("\(Int(weatherVM.temperature.rounded()))°C")
                        .font(.system(size: 60, design: .rounded))
                        .fontWeight(.thin)
                        .foregroundColor(.white)

                    Text(weatherVM.conditionText)
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))

                    Spacer()

                    HStack(spacing: 40) {
                        WeatherDetail(icon: "humidity.fill", value: weatherVM.humidity)
                        WeatherDetail(icon: "wind", value: weatherVM.wind)
                        WeatherDetail(icon: "eye", value: weatherVM.visibility)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.horizontal)

                    Spacer()
                }
            }
        }
    }
}

// MARK: Prévisions
struct PrevisionsView: View {
    @EnvironmentObject var weatherVM: WeatherViewModel

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            VStack {
                Text("Prévisions 5 jours")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                if weatherVM.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    List(weatherVM.dailyForecasts) { prev in
                        HStack {
                            Text(prev.jour)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 50, alignment: .leading)

                            Image(systemName: prev.icone)
                                .foregroundColor(.yellow)

                            Spacer()

                            Text("\(prev.tempMin)°")
                                .foregroundColor(.white.opacity(0.7))
                            Text("–")
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(prev.tempMax)°")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
        }
    }
}

// MARK: Recherche
struct RechercheView: View {
    @EnvironmentObject var weatherVM: WeatherViewModel
    @State private var searchText = ""

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Rechercher une ville")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 50)

                HStack {
                    HStack(spacing: 8) {
                        Button {
                            if !searchText.isEmpty {
                                weatherVM.searchCity(searchText)
                                searchText = ""
                                hideKeyboard()
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 17))
                        }

                        TextField("Rechercher une ville...", text: $searchText)
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .submitLabel(.search)
                            .onSubmit {
                                if !searchText.isEmpty {
                                    weatherVM.searchCity(searchText)
                                    searchText = ""
                                }
                            }

                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 17))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .glassEffect()
                    .cornerRadius(12)

                    if !searchText.isEmpty {
                        Button("Annuler") {
                            searchText = ""
                            hideKeyboard()
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
                .padding(.horizontal)

                if weatherVM.isLoading {
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 20)
                }

                Spacer()
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: Composant météo
struct WeatherDetail: View {
    let icon: String
    let value: String

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
            Text(value)
                .font(.headline)
        }
    }
}

// MARK: Modèle prévision
struct Prevision: Identifiable {
    let id = UUID()
    let jour: String
    let icone: String
    let tempMin: Int
    let tempMax: Int
}
