import Foundation

/// Service d'appel aux API Open-Meteo.
class WeatherService {
    static let shared = WeatherService()

    private let weatherURL = "https://api.open-meteo.com/v1/forecast"
    private let geoURL    = "https://geocoding-api.open-meteo.com/v1/search"

    // MARK: Météo
    func fetchWeather(latitude: Double, longitude: Double) async throws -> OpenMeteoWeatherResponse {
        var comps = URLComponents(string: weatherURL)!
        comps.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current_weather", value: "true"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,weathercode,wind_speed_10m_max,uv_index_max"),
            URLQueryItem(name: "hourly", value: "relative_humidity_2m"),
            URLQueryItem(name: "timezone", value: "Europe/Paris"),
            URLQueryItem(name: "forecast_days", value: "5")
        ]
        guard let url = comps.url else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(OpenMeteoWeatherResponse.self, from: data)
    }

    // MARK: Géocodage
    func geocode(city: String) async throws -> GeocodingResult {
        var comps = URLComponents(string: geoURL)!
        comps.queryItems = [
            URLQueryItem(name: "name", value: city),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "language", value: "fr"),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = comps.url else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        guard let first = response.results.first else { throw URLError(.cannotFindHost) }
        return first
    }
}
