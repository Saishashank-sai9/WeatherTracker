import SwiftUI

struct WeatherDetailView: View {
    let weather: WeatherResponse
    
    var body: some View {
        VStack {
            // Weather Icon and City Name
            VStack {
                // Assuming weather.current.condition.icon contains a relative URL
                if let url = URL(string: "https:\(weather.current.condition.icon)") {
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
                HStack {
                    Text(weather.location.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Image(systemName: "location.fill")
                        .foregroundColor(.black)
                }
                .padding(.top)
                
                Text("\(Int(weather.current.temp_c))°")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
            }
            
            // Weather Details (Humidity, Feels Like, UV Index)
            HStack {
                Text("Humidity\n\(Int(weather.current.humidity))%")
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .font(.headline)
                    .foregroundColor(.black)

                
                Text("FeelsLike\n\(Int(weather.current.feelslike_c))°")
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text("UV\n\(Int(round(weather.current.uv)))")
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .font(.headline)
                    .foregroundColor(.black)
                
            }
         
            .padding()
            .background(Color.gray.opacity(0.2))
          
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding(.horizontal)
            
        }
        Spacer()
        .padding()
    }
}
