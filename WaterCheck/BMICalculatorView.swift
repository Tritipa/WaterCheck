import SwiftUI

struct BMICalculatorView: View {
    @EnvironmentObject var hydrationManager: HydrationManager
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var bmi: Double? = nil
    @State private var waterNorm: Double? = nil
    @State private var category: String = ""
    @State private var showingSetGoal = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedWaterBackground()
                LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.18), Color.blue.opacity(0.12), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(spacing: 28) {
                    Text("BMI & Water Intake")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 16)
                    HStack(spacing: 18) {
                        VStack(alignment: .leading) {
                            Text("Weight (kg)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            TextField("70", text: $weight)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                        }
                        VStack(alignment: .leading) {
                            Text("Height (cm)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            TextField("175", text: $height)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                        }
                    }
                    Button(action: calculate) {
                        Text("Calculate")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                            )
                    }
                    .padding(.top, 8)
                    if let bmi = bmi, let waterNorm = waterNorm {
                        VStack(spacing: 16) {
                            Text("Your BMI: \(String(format: "%.1f", bmi))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text(category)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Recommended water intake: \(Int(waterNorm)) ml/day")
                                .font(.title3)
                                .foregroundColor(.blue)
                            Button(action: {
                                hydrationManager.updateDailyGoal(waterNorm)
                                showingSetGoal = true
                            }) {
                                Text("Set as daily goal")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                                    )
                            }
                            .alert("Goal updated!", isPresented: $showingSetGoal) {
                                Button("OK", role: .cancel) {}
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.systemBackground).opacity(0.7))
                                .shadow(color: Color.cyan.opacity(0.08), radius: 8, x: 0, y: 2)
                        )
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func calculate() {
        guard let w = Double(weight), let h = Double(height), h > 0 else { return }
        let hMeters = h / 100.0
        let bmiValue = w / (hMeters * hMeters)
        bmi = bmiValue
        switch bmiValue {
        case ..<18.5: category = "Underweight"
        case 18.5..<25: category = "Normal weight"
        case 25..<30: category = "Overweight"
        default: category = "Obesity"
        }
        // Recommendation: 35 ml per 1 kg of weight
        waterNorm = w * 35
    }
}

#Preview {
    BMICalculatorView().environmentObject(HydrationManager())
} 