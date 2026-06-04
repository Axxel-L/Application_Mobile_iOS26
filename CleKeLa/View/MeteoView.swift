import SwiftUI

/// Onglet Météo : météo actuelle avec température verrouillée
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
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
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
        VStack(spacing: 20) {
            cardPreview
            VStack(spacing: 2) {
                Text("Débloquer la température")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("9,99 €")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
            }
            payButton
            Text("Promis, vous n'allez pas payer 😄")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .padding(.horizontal, 16)
    }

    // MARK: Carte
    private var cardPreview: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(white: 0.35), location: 0),
                            .init(color: Color(white: 0.55), location: 0.3),
                            .init(color: Color(white: 0.25), location: 0.7),
                            .init(color: Color(white: 0.45), location: 1),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.25), lineWidth: 0.5)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.title2)
                    Spacer()
                    Image(systemName: "wave.3.right")
                        .font(.title3)
                }
                .foregroundColor(.white.opacity(0.9))

                Spacer()

                Text("•••• 4242")
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(.white)
                Text("Carte Bancaire")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(14)
        }
        .frame(height: 100)
    }

    // MARK: Bouton
    private var payButton: some View {
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
            HStack(spacing: 8) {
                if showCheck {
                    Image(systemName: "checkmark.circle.fill")
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "applelogo")
                        .font(.title3)
                }
                Text(showCheck ? "Payé !" : "Payer avec Touch ID")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(showCheck ? Color.green : Color.black)
            )
            .foregroundColor(.white)
        }
        .disabled(paid)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCheck)
    }
}
