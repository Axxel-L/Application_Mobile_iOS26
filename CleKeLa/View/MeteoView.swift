import SwiftUI

/// Onglet Météo : météo actuelle avec température verrouillée (Apple Pay factice).
struct MeteoView: View {
    @EnvironmentObject var ctrl: WeatherController
    @State private var showApplePay = false
    @State private var unlocked = false

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

                    // Température (floutée si verrouillée)
                    if unlocked {
                        Text("\(Int(ctrl.temperature.rounded()))°C")
                            .font(.system(size: 60, design: .rounded)).fontWeight(.thin)
                    } else {
                        ZStack {
                            Text("\(Int(ctrl.temperature.rounded()))°C")
                                .font(.system(size: 60, design: .rounded)).fontWeight(.thin)
                                .blur(radius: 8)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 40, weight: .bold))
                        }
                        .onTapGesture { showApplePay = true }
                    }

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
        .sheet(isPresented: $showApplePay) {
            ApplePaySheet(isPresented: $showApplePay, unlocked: $unlocked)
                .presentationDetents([.height(380)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: Sheet Apple Pay
private struct ApplePaySheet: View {
    @Binding var isPresented: Bool
    @Binding var unlocked: Bool
    @State private var paid = false
    @State private var showCheck = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 24) {
                HStack {
                    Text("Apple Pay").font(.headline)
                    Spacer()
                    Button { isPresented = false } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2).foregroundColor(.secondary)
                    }
                }

                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.gray.opacity(0.4), .gray.opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 100)
                    .overlay(
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "creditcard.fill")
                                .font(.title).foregroundColor(.white)
                            Text("•••• 4242")
                                .font(.system(.title3, design: .monospaced))
                                .foregroundColor(.white)
                            Text("Carte Bancaire")
                                .font(.caption).foregroundColor(.white.opacity(0.8))
                        }.padding(),
                        alignment: .topLeading
                    )

                VStack(spacing: 4) {
                    Text("Débloquer la température")
                        .font(.subheadline).foregroundColor(.secondary)
                    Text("9,99 €")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                }

                Button {
                    guard !paid else { return }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        showCheck = true
                    }
                    paid = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        unlocked = true
                        isPresented = false
                    }
                } label: {
                    HStack {
                        if showCheck {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "applelogo")
                        }
                        Text(showCheck ? "Payé !" : "Payer avec Touch ID")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(showCheck ? Color.green : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .disabled(paid)

                Text("Promis, vous n'allez pas payer 😄")
                    .font(.caption2).foregroundColor(.secondary)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)
            )
            .padding(.horizontal, 20)
        }
    }
}
