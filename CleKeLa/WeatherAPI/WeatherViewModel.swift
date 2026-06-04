import SwiftUI
import Combine
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var cityName = "NaN"
    @Published var temperature: Double = 0
    @Published var conditionText = ""
    @Published var iconName = "error"
    @Published var wind = ""
    @Published var humidity = "--"
    @Published var uvIndex = "--"
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
                Task { await self?.loadWeatherForLocation(location) }
            }
            .store(in: &cancellables)

        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if self.cityName == "Paris" && self.temperature == 0 {
                await self.loadDefaultCity()
            }
        }
    }

    private func loadWeatherForLocation(_ location: CLLocation) async {
        print("📍 Localisation reçue")
        isLoading = true
        let city = await reverseGeocode(location: location) ?? "Ma position"
        do {
            try await loadWeather(lat: location.coordinate.latitude,
                                  lon: location.coordinate.longitude,
                                  cityName: city)
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
            try await loadWeather(lat: result.latitude, lon: result.longitude, cityName: result.name)
        } catch {
            print("❌ Erreur météo locale : \(error.localizedDescription)")
            await loadDefaultCity()
        }
        isLoading = false
    }

    func searchCity(_ name: String) {
        Task {
            isLoading = true
            do {
                let result = try await service.geocode(city: name)
                try await loadWeather(lat: result.latitude, lon: result.longitude, cityName: result.name)
            } catch {
                print("❌ Erreur météo locale : \(error.localizedDescription)")
                await loadDefaultCity()
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

        if let hourly = response.hourly {
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:00"
            formatter.timeZone = TimeZone(identifier: "Europe/Paris")
            let nowString = formatter.string(from: now)

            if let index = hourly.time.firstIndex(where: { $0.hasPrefix(nowString) }),
               let humArray = hourly.relative_humidity_2m, index < humArray.count {
                humidity = "\(Int(humArray[index].rounded()))%"
            } else {
                humidity = "--"
            }
        }

        if let dailyUV = response.daily.uv_index_max, !dailyUV.isEmpty {
            uvIndex = String(format: "%.1f", dailyUV[0])
        }

        var previsions: [Prevision] = []
        let daily = response.daily
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE"
        dayOfWeekFormatter.locale = Locale(identifier: "fr_FR")

        for i in 0..<min(daily.time.count, 5) {
            let dateString = daily.time[i]
            if let date = dayFormatter.date(from: dateString) {
                let jour = dayOfWeekFormatter.string(from: date).capitalized
                let icone = weatherIcon(for: daily.weathercode[i])
                let min = Int(daily.temperature_2m_min[i].rounded())
                let max = Int(daily.temperature_2m_max[i].rounded())
                let code = daily.weathercode[i]
                let windVal = daily.wind_speed_10m_max?[i] ?? 0.0
                let windStr = "\(Int(windVal.rounded())) km/h"
                let uvVal = daily.uv_index_max?[i]
                let uvStr = uvVal != nil ? "\(Int(uvVal!.rounded()))" : "--"
                previsions.append(Prevision(jour: jour,
                                           icone: icone,
                                           tempMin: min,
                                           tempMax: max,
                                           weathercode: code,
                                           wind: windStr,
                                           uvIndex: uvStr))
            }
        }
        dailyForecasts = previsions
    }

    private func reverseGeocode(location: CLLocation) async -> String? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality ?? placemarks.first?.name
        } catch {
            print("⚠️ Reverse geocoding échoué")
            return nil
        }
    }
}
