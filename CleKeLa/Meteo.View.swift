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

            InfosView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("Infos")
                }
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
        .environmentObject(weatherVM)
    }
}

// MARK: Météo
struct MeteoView: View {
    @EnvironmentObject var weatherVM: WeatherViewModel
    @State private var showApplePay = false
    @State private var isTemperatureUnlocked = false

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

                    // Température (floutée si verrouillée)
                    if isTemperatureUnlocked {
                        Text("\(Int(weatherVM.temperature.rounded()))°C")
                            .font(.system(size: 60, design: .rounded))
                            .fontWeight(.thin)
                            .foregroundColor(.white)
                    } else {
                        ZStack {
                            Text("\(Int(weatherVM.temperature.rounded()))°C")
                                .font(.system(size: 60, design: .rounded))
                                .fontWeight(.thin)
                                .foregroundColor(.white)
                                .blur(radius: 8)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            showApplePay = true
                        }
                    }

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
        .sheet(isPresented: $showApplePay) {
            ApplePaySheet(isPresented: $showApplePay, isTemperatureUnlocked: $isTemperatureUnlocked)
                .presentationDetents([.height(380)])
                .presentationDragIndicator(.visible)
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
                    ProgressView().tint(.white)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(weatherVM.dailyForecasts) { prev in
                                PrevisionCard(prevision: prev)
                                    .onTapGesture { selectedPrevision = prev }
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

// MARK: Card d'une prévision
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

// MARK: Détail d’une journée
struct PrevisionDetailView: View {
    let prevision: Prevision
    let cityName: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            VStack(spacing: 4) {
                HStack {
                    Button { dismiss() } label: {
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
                    .font(.title2).fontWeight(.semibold).foregroundColor(.white)
                Text(weatherConditionText(for: prevision.weathercode))
                    .font(.title3).foregroundColor(.white.opacity(0.8))
                HStack(spacing: 20) {
                    VStack {
                        Text("Min").font(.caption).foregroundColor(.white.opacity(0.7))
                        Text("\(prevision.tempMin)°").font(.title).foregroundColor(.white)
                    }
                    VStack {
                        Text("Max").font(.caption).foregroundColor(.white.opacity(0.7))
                        Text("\(prevision.tempMax)°").font(.title).foregroundColor(.white)
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
                    .font(.title2).fontWeight(.semibold).foregroundColor(.white)
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
                        }
                        TextField("Rechercher une ville...", text: $searchText)
                            .foregroundColor(.white)
                            .submitLabel(.search)
                            .onSubmit {
                                if !searchText.isEmpty {
                                    weatherVM.searchCity(searchText)
                                    searchText = ""
                                }
                            }
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)

                    if !searchText.isEmpty {
                        Button("Annuler") {
                            searchText = ""
                            hideKeyboard()
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)

                if weatherVM.isLoading {
                    ProgressView().tint(.white).padding(.top, 20)
                }
                Spacer()
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: Détail météo
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

// MARK: Sheet Apple Pay
struct ApplePaySheet: View {
    @Binding var isPresented: Bool
    @Binding var isTemperatureUnlocked: Bool
    @State private var showCheckmark = false
    @State private var paymentDone = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 24) {
                HStack {
                    Text("Apple Pay").font(.headline)
                    Spacer()
                    Button { isPresented = false } label: {
                        Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.secondary)
                    }
                }

                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.2)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 100)
                    .overlay(
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "creditcard.fill").font(.title).foregroundColor(.white)
                            Text("•••• 4242").font(.system(.title3, design: .monospaced)).foregroundColor(.white)
                            Text("Carte Bancaire").font(.caption).foregroundColor(.white.opacity(0.8))
                        }.padding()
                        , alignment: .topLeading
                    )

                VStack(spacing: 4) {
                    Text("Débloquer la température").font(.subheadline).foregroundColor(.secondary)
                    Text("9,99 €").font(.system(size: 36, weight: .bold, design: .rounded))
                }

                Button {
                    if !paymentDone {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            showCheckmark = true
                        }
                        paymentDone = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            isTemperatureUnlocked = true
                            isPresented = false
                        }
                    }
                } label: {
                    HStack {
                        if showCheckmark {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "applelogo")
                        }
                        Text(showCheckmark ? "Payé !" : "Payer avec Touch ID")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(showCheckmark ? Color.green : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .disabled(paymentDone)

                Text("Promis, vous n'allez pas payer 😄")
                    .font(.caption2).foregroundColor(.secondary)
            }
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground)).shadow(radius: 10))
            .padding(.horizontal, 20)
        }
    }
}

// MARK: Vue Infos
struct InfosView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Informations")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                        .padding(.bottom, 8)

                    InfoCard(title: "Application") {
                        InfoRow(label: "Version", value: "\(appVersion) (build \(buildNumber))")
                        InfoRow(label: "Nom du bundle", value: Bundle.main.bundleIdentifier ?? "N/A")
                    }

                    InfoCard(title: "API Météo") {
                        InfoRow(label: "Service", value: "Open-Meteo")
                        InfoRow(label: "Site web", value: "open-meteo.com")
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: Card d'info
struct InfoCard<Content: View>: View {
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

// MARK: Ligne des infos
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
        }
    }
}
