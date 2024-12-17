import SwiftUI
import Combine

// MARK: - ViewModel Protocol
protocol WeatherViewModelProtocol: ObservableObject {
    var cityWeather: WeatherResponse? { get }
    var errorMessage: String? { get }
    var isLoading: Bool { get }
    func fetchWeather(for city: String)
    func loadSavedCity()
}

// MARK: - Weather Model Protocol
protocol WeatherModelProtocol {
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, Error>
}

// MARK: - WeatherModel
final class WeatherModel: WeatherModelProtocol {
    private let apiKey = "8d29638a17a24528b12230542241412" 

    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, Error> {
        guard let url = URL(string: "https://api.weatherapi.com/v1/current.json?q=\(city)&key=\(apiKey)") else {
            return Fail(error: WeatherError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    if let responseBody = String(data: output.data, encoding: .utf8) {
                        print("Error Response Body: \(responseBody)")
                    }
                    throw WeatherError.invalidResponse
                }
                return output.data
            }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return WeatherError.decodingError(decodingError)
                }
                return error
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Weather ViewModel
final class WeatherViewModel: WeatherViewModelProtocol {
    @Published var cityWeather: WeatherResponse?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()
    private let weatherModel: WeatherModelProtocol
    private let savedCityKey = "SavedCity"
    
    init(weatherModel: WeatherModelProtocol = WeatherModel()) {
        self.weatherModel = weatherModel
    }

    func fetchWeather(for city: String) {
        isLoading = true
        weatherModel.fetchWeather(for: city)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] response in
                self?.cityWeather = response
                self?.saveCity(city, weather: response)
            })
            .store(in: &cancellables)
    }

    func loadSavedCity() {
        guard let savedCity = UserDefaults.standard.string(forKey: savedCityKey) else { return }
        if let savedWeatherData = loadSavedWeather(for: savedCity) {
            cityWeather = savedWeatherData
            fetchWeather(for: savedCity)
        }
    }

    private func saveCity(_ city: String, weather: WeatherResponse) {
        UserDefaults.standard.set(city, forKey: savedCityKey)
        if let encodedWeather = try? JSONEncoder().encode(weather) {
            UserDefaults.standard.set(encodedWeather, forKey: "\(city)_Weather")
        }
    }

    private func loadSavedWeather(for city: String) -> WeatherResponse? {
        guard let savedData = UserDefaults.standard.data(forKey: "\(city)_Weather"),
              let decodedWeather = try? JSONDecoder().decode(WeatherResponse.self, from: savedData) else {
            return nil
        }
        return decodedWeather
    }

    private func handleError(_ error: Error) {
        if let weatherError = error as? WeatherError {
            self.errorMessage = weatherError.localizedDescription
        } else {
            self.errorMessage = "An unknown error occurred."
        }
    }
}

// MARK: - WeatherError Enum
enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(DecodingError)
    case apiError(APIError)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid. Please check the API endpoint."
        case .invalidResponse:
            return "The server returned an invalid response. Please try again later."
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .apiError(let apiError):
            return apiError.message
        }
    }
}

// MARK: - APIError Struct
struct APIError: Codable, LocalizedError {
    let code: Int
    let message: String

    var errorDescription: String? {
        return "Error \(code): \(message)"
    }
}
