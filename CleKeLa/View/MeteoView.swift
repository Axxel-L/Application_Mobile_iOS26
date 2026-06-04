import SwiftUI

/// Onglet Météo
struct MeteoView: View {
    @EnvironmentObject var ctrl: WeatherController

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            if ctrl.isLoading {
                ProgressView().tint(.white)
            } else {
                VStack(spacing: 20) {
                    Spacer()

                    Image(systemName: ctrl.iconName)
                        .font(.system(size: 80))

                    Text(ctrl.cityName)
                        .font(.largeTitle).fontWeight(.bold)

                    Text("\(Int(ctrl.temperature.rounded()))°C")
                        .font(.system(size: 60, design: .rounded)).fontWeight(.thin)

                    Text(ctrl.conditionText)
                        .font(.title2).opacity(0.8)

                    Spacer()

                    HStack(spacing: 40) {
                        WeatherDetail(icon: "humidity.fill", value: ctrl.humidity)
                        WeatherDetail(icon: "wind",           value: ctrl.wind)
                        WeatherDetail(icon: "sun.max.fill",   value: ctrl.uvIndex)
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)

                    Spacer()
                }
                .foregroundColor(.white)
            }
        }
    }
}
