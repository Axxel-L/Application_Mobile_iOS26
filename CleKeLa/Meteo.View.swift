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
                        WeatherDetail(icon: "sun.max.fill", value: "\(weatherVM.uvIndex)")
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
    @State private var selectedPrevision: Prevision? = nil

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            VStack {
                if weatherVM.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(weatherVM.dailyForecasts) { prev in
                                PrevisionCard(prevision: prev)
                                    .onTapGesture {
                                        selectedPrevision = prev
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .padding(.top, 20)
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .sheet(item: $selectedPrevision) { prev in
            PrevisionDetailView(prevision: prev, cityName: weatherVM.cityName)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: Carte de prévision
struct PrevisionCard: View {
    let prevision: Prevision

    var body: some View {
        HStack(spacing: 12) {
            Text(prevision.jour.prefix(3))
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 50, alignment: .leading)

            Image(systemName: prevision.icone)
                .font(.system(size: 28))
                .foregroundColor(.yellow)
                .frame(width: 35)

            Spacer()

            Text("\(prevision.tempMin)°")
                .foregroundColor(.white.opacity(0.7))
                .font(.subheadline)
            Text("–")
                .foregroundColor(.white.opacity(0.7))
            Text("\(prevision.tempMax)°")
                .foregroundColor(.white)
                .font(.headline)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.15))
        .overlay(
            RoundedRectangle(cornerRadius: 42)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(42)
    }
}

// MARK: Sheet détail d'une journée
struct PrevisionDetailView: View {
    let prevision: Prevision
    let cityName: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            VStack(spacing: 4) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 8)

                Spacer()

                Image(systemName: prevision.icone)
                    .font(.system(size: 70))
                    .foregroundColor(.white)

                Text("\(prevision.jour) à \(cityName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(weatherConditionText(for: prevision.weathercode))
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))

                HStack(spacing: 20) {
                    VStack {
                        Text("Min")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(prevision.tempMin)°")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    VStack {
                        Text("Max")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(prevision.tempMax)°")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }

                HStack(spacing: 40) {
                    WeatherDetail(icon: "wind", value: prevision.wind)
                    WeatherDetail(icon: "sun.max.fill", value: "\(prevision.uvIndex)")
                }
                .foregroundColor(.white)

                Spacer()
            }
            .multilineTextAlignment(.center)
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
    let weathercode: Int
    let wind: String
    let uvIndex: String
}
