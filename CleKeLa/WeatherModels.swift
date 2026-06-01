//
//  WeatherViewModel.swift
//  CleKeLa
//
//  Created by Axel Lalaut on 01/06/2026.
//

import Foundation

// MARK: Géocodage
struct GeocodingResult: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
}

struct GeocodingResponse: Codable {
    let results: [GeocodingResult]
}

// MARK: Open‑Meteo
struct OpenMeteoWeatherResponse: Codable {
    let current_weather: CurrentWeatherData
    let daily: DailyData
}

struct CurrentWeatherData: Codable {
    let temperature: Double
    let windspeed: Double
    let weathercode: Int
}

struct DailyData: Codable {
    let time: [String]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
    let weathercode: [Int]
}

// MARK: Helpers (icônes SF Symbols et texte)
func weatherIcon(for code: Int) -> String {
    switch code {
    case 0: return "sun.max.fill"
    case 1, 2: return "cloud.sun.fill"
    case 3: return "cloud.fill"
    case 45, 48: return "cloud.fog.fill"
    case 51, 53, 55: return "cloud.drizzle.fill"
    case 61, 63, 65: return "cloud.rain.fill"
    case 71, 73, 75, 77: return "cloud.snow.fill"
    case 80, 81, 82: return "cloud.heavyrain.fill"
    case 95, 96, 99: return "cloud.bolt.fill"
    default: return "questionmark"
    }
}

func weatherConditionText(for code: Int) -> String {
    switch code {
    case 0: return "Ensoleillé"
    case 1: return "Peu nuageux"
    case 2: return "Partiellement nuageux"
    case 3: return "Nuageux"
    case 45, 48: return "Brouillard"
    case 51, 53, 55: return "Bruine"
    case 61, 63, 65: return "Pluie"
    case 71, 73, 75, 77: return "Neige"
    case 80, 81, 82: return "Forte pluie"
    case 95, 96, 99: return "Orage"
    default: return "Inconnu"
    }
}
