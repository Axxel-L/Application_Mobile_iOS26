import SwiftUI
import Combine
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var cityName = "Paris"
    @Published var temperature: Double = 0
    @Published var conditionText = ""
    @Published var iconName = "cloud.sun.fill"
    @Published var wind = ""
    @Published var humidity = "--"
    @Published var visibility = "--"
    @Published var dailyForecasts: [Prevision] = []
    @Published var isLoading = false

    private let service = WeatherService.shared
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        locationManager.$currentLocation
            .compactMap { $0 }
            .first()
            .sink { [weak self] location in
                Task {
                    await self?.loadWeatherForLocation(location)
                }
            }
            .store(in: &cancellables)

        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if self.cityName == "Paris" && self.temperature == 0 {
                await self.loadDefaultCity()
            }
        }
    }

    // MARK: Météo locale automatique
    private func loadWeatherForLocation(_ location: CLLocation) async {
        print("📍 Localisation reçue : \(location.coordinate.latitude), \(location.coordinate.longitude)")
        isLoading = true
        do {
            try await loadWeather(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude,
                cityName: "Ma position"
            )
            print("✅ Météo locale chargée : \(cityName), \(temperature)°C")
        } catch {
            print("❌ Erreur météo locale : \(error)")
            await loadDefaultCity()
        }
        isLoading = false
    }

    private func loadDefaultCity() async {
        isLoading = true
        do {
            let result = try await service.geocode(city: "Paris")
            print("🏙️ Ville par défaut : \(result.name)")
            try await loadWeather(lat: result.latitude, lon: result.longitude, cityName: result.name)
        } catch {
            print("❌ Erreur chargement défaut : \(error)")
        }
        isLoading = false
    }

    // MARK: Recherche manuelle
    func searchCity(_ name: String) {
        Task {
            isLoading = true
            do {
                let result = try await service.geocode(city: name)
                print("🔍 Ville trouvée : \(result.name) (\(result.latitude), \(result.longitude))")
                try await loadWeather(
                    lat: result.latitude,
                    lon: result.longitude,
                    cityName: result.name
                )
            } catch {
                print("❌ Erreur lors de la recherche : \(error)")
            }
            isLoading = false
        }
    }

    // MARK: Chargement des données météo
    func loadWeather(lat: Double, lon: Double, cityName: String) async throws {
        let response = try await service.fetchWeather(latitude: lat, longitude: lon)

        self.cityName = cityName
        let current = response.current_weather
        temperature = current.temperature
        conditionText = weatherConditionText(for: current.weathercode)
        iconName = weatherIcon(for: current.weathercode)
        wind = "\(Int(current.windspeed.rounded())) km/h"

        if let hum = response.current?.relative_humidity_2m {
            humidity = "\(Int(hum.rounded()))%"
        } else {
            humidity = "--"
        }

        if let vis = response.current?.visibility {
            visibility = "\(Int(vis.rounded() / 1000)) km"
        } else {
            visibility = "--"
        }

        // Prévisions
        var previsions: [Prevision] = []
        let daily = response.daily
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEE"
        dayOfWeekFormatter.locale = Locale(identifier: "fr_FR")

        for i in 0..<min(daily.time.count, 5) {
            let dateString = daily.time[i]
            if let date = dayFormatter.date(from: dateString) {
                let jour = dayOfWeekFormatter.string(from: date)
                let icone = weatherIcon(for: daily.weathercode[i])
                let min = Int(daily.temperature_2m_min[i].rounded())
                let max = Int(daily.temperature_2m_max[i].rounded())
                previsions.append(Prevision(jour: jour, icone: icone, tempMin: min, tempMax: max))
            }
        }
        dailyForecasts = previsions
    }
}
