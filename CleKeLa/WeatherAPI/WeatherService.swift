import Foundation

class WeatherService {
    static let shared = WeatherService()
    private init() {}

    private let baseWeatherURL = "https://api.open-meteo.com/v1/forecast"
    private let baseGeoURL = "https://geocoding-api.open-meteo.com/v1/search"

    func fetchWeather(latitude: Double, longitude: Double) async throws -> OpenMeteoWeatherResponse {
        var components = URLComponents(string: baseWeatherURL)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current_weather", value: "true"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,weathercode,wind_speed_10m_max,uv_index_max"),
            URLQueryItem(name: "hourly", value: "relative_humidity_2m"),
            URLQueryItem(name: "timezone", value: "Europe/Paris"),
            URLQueryItem(name: "forecast_days", value: "5")
        ]

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let decoder = JSONDecoder()
        return try decoder.decode(OpenMeteoWeatherResponse.self, from: data)
    }

    func geocode(city: String) async throws -> GeocodingResult {
        var components = URLComponents(string: baseGeoURL)!
        components.queryItems = [
            URLQueryItem(name: "name", value: city),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "language", value: "fr"),
            URLQueryItem(name: "format", value: "json")
        ]
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let decoder = JSONDecoder()
        let response = try decoder.decode(GeocodingResponse.self, from: data)
        guard let first = response.results.first else {
            throw URLError(.cannotFindHost)
        }
        return first
    }
}
