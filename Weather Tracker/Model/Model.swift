import SwiftUI
import Combine


// MARK: - WeatherResponse Models
struct WeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
}

struct CurrentWeather: Codable {
    let temp_c: Double
    let temp_f: Double
    let condition: WeatherCondition
    let humidity: Int
    let feelslike_c: Double
    let feelslike_f: Double
    let uv: Double
    let gust_mph: Double
    let gust_kph: Double
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int
}
