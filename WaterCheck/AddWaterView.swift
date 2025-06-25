import SwiftUI

struct AddWaterView: View {
    @EnvironmentObject var hydrationManager: HydrationManager
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAmount: Double
    @State private var customAmount: String = ""
    
    private let predefinedAmounts: [Double] = [100, 150, 200, 250, 300, 350, 400, 500]
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedWaterBackground()
                VStack(spacing: 32) {
                    headerSection
                    quickSelectSection
                    customAmountSection
                    selectedAmountSection
                    Spacer()
                    addButton
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "drop.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
                .shadow(color: .cyan.opacity(0.18), radius: 8, x: 0, y: 4)
            Text("Add Water Intake")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text("Select or enter the amount of water you consumed")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }

    private struct QuickSelectButton: View {
        let amount: Double
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text("\(Int(amount)) ml")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                isSelected
                                    ? AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                                    : AnyShapeStyle(Color(.systemBackground).opacity(0.7))
                            )
                            .shadow(color: Color.cyan.opacity(0.10), radius: 4, x: 0, y: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var quickSelectGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 14) {
            ForEach(predefinedAmounts, id: \.self) { amount in
                QuickSelectButton(
                    amount: amount,
                    isSelected: selectedAmount == amount,
                    action: { selectedAmount = amount }
                )
            }
        }
    }

    private var quickSelectSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Quick Select")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            quickSelectGrid
        }
    }

    private var customAmountSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Custom Amount")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            HStack {
                TextField("Enter amount", text: $customAmount)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 44)
                    .onChange(of: customAmount) { newValue in
                        if let amount = Double(newValue) {
                            selectedAmount = amount
                        }
                    }
                Text("ml")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var selectedAmountSection: some View {
        VStack(spacing: 10) {
            Text("Selected Amount")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            Text("\(Int(selectedAmount)) ml")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.cyan.opacity(0.10), radius: 6, x: 0, y: 2)
        )
    }

    private var addButton: some View {
        Button(action: {
            hydrationManager.addWater(amount: selectedAmount)
            dismiss()
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Add \(Int(selectedAmount)) ml")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
            )
            .shadow(color: .blue.opacity(0.18), radius: 10, x: 0, y: 4)
            .opacity(selectedAmount <= 0 ? 0.6 : 1.0)
        }
        .disabled(selectedAmount <= 0)
    }
}

#Preview {
    AddWaterView(selectedAmount: .constant(250))
        .environmentObject(HydrationManager())
} 