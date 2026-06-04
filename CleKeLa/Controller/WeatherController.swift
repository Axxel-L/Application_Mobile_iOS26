import Combine
import CoreLocation
import SwiftUI

/// Récupère les données et les expose aux vues.
class WeatherController: ObservableObject {

    // MARK: Données
    @Published var cityName = "Chargement..."
    @Published var temperature: Double = 0
    @Published var conditionText = ""
    @Published var iconName = "cloud.sun.fill"
    @Published var wind = "--"
    @Published var humidity = "--"
    @Published var uvIndex = "--"
    @Published var dailyForecasts: [Prevision] = []
    @Published var isLoading = false

    // MARK: Services
    private let service = WeatherService.shared
    private let location = LocationService()

    // MARK: Initialisation
    init() {
        location.onLocation = { [weak self] loc in
            guard let self else { return }
            Task { @MainActor in
                if let loc {
                    let city = await self.cityFromLocation(loc)
                    await self.loadWeather(lat: loc.coordinate.latitude,
                                           lon: loc.coordinate.longitude,
                                           city: city)
                } else {
                    if let r = try? await self.service.geocode(city: "Paris") {
                        try? await self.loadWeather(lat: r.latitude,
                                                    lon: r.longitude,
                                                    city: r.name)
                    }
                }
            }
        }
        location.start()
    }

    // MARK: Recherche d'une ville
    func searchCity(_ name: String) {
        Task { @MainActor in
            isLoading = true
            if let r = try? await service.geocode(city: name) {
                try? await loadWeather(lat: r.latitude, lon: r.longitude, city: r.name)
            }
            isLoading = false
        }
    }

    // MARK: Charge les données météo
    @MainActor
    private func loadWeather(lat: Double, lon: Double, city: String) async {
        guard let resp = try? await service.fetchWeather(latitude: lat, longitude: lon)
        else { return }

        cityName = city
        let c = resp.current_weather
        temperature = c.temperature
        conditionText = weatherText(c.weathercode)
        iconName = weatherIcon(c.weathercode)
        wind = "\(Int(c.windspeed.rounded())) km/h"

        if let h = resp.hourly?.relative_humidity_2m, !h.isEmpty {
            humidity = "\(Int(h[0].rounded()))%"
        }
        if let uv = resp.daily.uv_index_max, !uv.isEmpty {
            uvIndex = String(format: "%.1f", uv[0])
        }

        dailyForecasts = makePrevisions(resp.daily)
    }

    @MainActor
    private func makePrevisions(_ daily: DailyData) -> [Prevision] {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let wf = DateFormatter()
        wf.dateFormat = "EEEE"
        wf.locale = Locale(identifier: "fr_FR")

        var forecasts: [Prevision] = []
        for (i, ds) in daily.time.prefix(5).enumerated() {
            guard let d = df.date(from: ds) else { continue }
            let code = daily.weathercode[i]
            let uvText: String
            if let uvValues = daily.uv_index_max, uvValues.indices.contains(i) {
                uvText = "\(Int(uvValues[i].rounded()))"
            } else {
                uvText = "--"
            }
            forecasts.append(
                Prevision(
                    jour: wf.string(from: d).capitalized,
                    icone: weatherIcon(code),
                    tempMin: Int(daily.temperature_2m_min[i].rounded()),
                    tempMax: Int(daily.temperature_2m_max[i].rounded()),
                    weathercode: code,
                    wind: "\(Int((daily.wind_speed_10m_max?[i] ?? 0).rounded())) km/h",
                    uvIndex: uvText
                )
            )
        }

        return forecasts
    }

    @MainActor
    private func cityFromLocation(_ loc: CLLocation) async -> String {
        if let place = try? await CLGeocoder().reverseGeocodeLocation(loc).first {
            return place.locality ?? place.name ?? "Ma position"
        }
        return "Ma position"
    }
}
