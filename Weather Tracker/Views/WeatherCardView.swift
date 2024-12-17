import SwiftUI

struct WeatherCardView: View {
    let cityName: String
    let temperature: Double
    let icon: String 
    let weather: WeatherResponse
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // City Name
                Text(cityName)
                    .font(.title)
                    .padding(.leading)
                    .foregroundColor(.black)
                
                // Temperature
                Text("\(Int(weather.current.temp_c))°")
                    .font(.largeTitle)
                    .padding(.horizontal)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Weather Icon
            if let url = URL(string: "https:\(icon)") {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                } placeholder: {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
            } else {
                Image(systemName: "cloud.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}
