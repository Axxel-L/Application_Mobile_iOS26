import SwiftUI
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var cityName = "Paris"
    @Published var temperature: Double = 0
    @Published var conditionText = ""
    @Published var iconName = "cloud.sun.fill"
    @Published var wind = ""
    @Published var dailyForecasts: [Prevision] = []
    @Published var isLoading = false

    private let service = WeatherService.shared

    func searchCity(_ name: String) {
        Task {
            isLoading = true
            do {
                let result = try await service.geocode(city: name)
                try await loadWeather(
                    lat: result.latitude,
                    lon: result.longitude,
                    cityName: result.name
                )
            } catch {
                print("Erreur lors de la recherche : \(error)")
            }
            isLoading = false
        }
    }

    func loadWeather(lat: Double, lon: Double, cityName: String) async throws {
        let response = try await service.fetchWeather(latitude: lat, longitude: lon)

        self.cityName = cityName
        let current = response.current_weather
        temperature = current.temperature
        conditionText = weatherConditionText(for: current.weathercode)
        iconName = weatherIcon(for: current.weathercode)
        wind = "\(Int(current.windspeed.rounded())) km/h"

        // Prévisions de 5 jours
        var previsions: [Prevision] = []
        let daily = response.daily
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEE"   // Lun, Mar, ...
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

    init() {
        Task {
            await loadDefaultCity()
        }
    }

    private func loadDefaultCity() async {
        isLoading = true
        do {
            let result = try await service.geocode(city: "Paris")
            try await loadWeather(
                lat: result.latitude,
                lon: result.longitude,
                cityName: result.name
            )
        } catch {
            print("Erreur chargement défaut : \(error)")
        }
        isLoading = false
    }
}
