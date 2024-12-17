import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(searchQuery: $searchQuery, onSearch: {
                    viewModel.errorMessage = nil
                    viewModel.fetchWeather(for: searchQuery)
                })
                .padding()
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let weather = viewModel.cityWeather {
                    NavigationLink(
                        destination: WeatherDetailView(weather: weather)
                    ) {
                        WeatherCardView(
                            cityName: weather.location.name,
                            temperature: weather.current.temp_c,
                            icon: weather.current.condition.icon,
                            weather: weather
                        )
                        .padding()
                    }
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    // Placeholder for initial state
                    VStack {
                        Text("No City Is Selected")
                            .font(.title)
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        
                        Text("Please search for a City")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .onAppear {
                viewModel.loadSavedCity()
            }
            .navigationTitle("Weather Tracker")
        }
    }
}

struct SearchBar: View {
    @Binding var searchQuery: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search Location", text: $searchQuery)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
            }
            .disabled(searchQuery.isEmpty)
        }
        .padding(.horizontal)
    }
}
