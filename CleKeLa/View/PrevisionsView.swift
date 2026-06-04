import SwiftUI

/// Onglet Prévisions
struct PrevisionsView: View {
    @EnvironmentObject var ctrl: WeatherController
    @State private var selected: Prevision?

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            if ctrl.isLoading {
                ProgressView().tint(.white)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(ctrl.dailyForecasts) { prev in
                            PrevisionRow(prev: prev)
                                .onTapGesture { selected = prev }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .sheet(item: $selected) { prev in
            PrevisionDetail(prev: prev, city: ctrl.cityName)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: Ligne d'une prévision
private struct PrevisionRow: View {
    let prev: Prevision

    var body: some View {
        HStack(spacing: 12) {
            Text(prev.jour.prefix(3))
                .font(.system(.headline, design: .rounded))
                .frame(width: 50, alignment: .leading)

            Image(systemName: prev.icone)
                .font(.system(size: 28))
                .foregroundColor(.yellow)
                .frame(width: 35)

            Spacer()

            Text("\(prev.tempMin)°").opacity(0.7).font(.subheadline)
            Text("–").opacity(0.7)
            Text("\(prev.tempMax)°").font(.headline)
        }
        .foregroundColor(.white)
        .padding(.vertical, 14).padding(.horizontal, 16)
        .background(Color.white.opacity(0.15))
        .overlay(
            RoundedRectangle(cornerRadius: 42)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(42)
    }
}

// MARK: Détail d'une journée
private struct PrevisionDetail: View {
    let prev: Prevision
    let city: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 26, weight: .semibold))
                            .padding(14)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                Image(systemName: prev.icone)
                    .font(.system(size: 70))
                Text("\(prev.jour) à \(city)")
                    .font(.title2).fontWeight(.semibold)
                Text(weatherText(prev.weathercode))
                    .font(.title3).opacity(0.8)

                HStack(spacing: 20) {
                    VStack {
                        Text("Min").font(.caption).opacity(0.7)
                        Text("\(prev.tempMin)°").font(.title)
                    }
                    VStack {
                        Text("Max").font(.caption).opacity(0.7)
                        Text("\(prev.tempMax)°").font(.title)
                    }
                }

                HStack(spacing: 40) {
                    WeatherDetail(icon: "wind",         value: prev.wind)
                    WeatherDetail(icon: "sun.max.fill", value: prev.uvIndex)
                }

                Spacer()
            }
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
        }
    }
}
