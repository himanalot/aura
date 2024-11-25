import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DashboardViewModel
    
    private let regions = ["North America", "Europe", "Asia", "Latin America"]
    private let stages = ["Seed", "Series A", "Series B", "Series C+", "Late Stage"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Regions") {
                    ForEach(regions, id: \.self) { region in
                        Toggle(region, isOn: binding(for: region, in: $viewModel.selectedRegions))
                    }
                }
                
                Section("Funding Stages") {
                    ForEach(stages, id: \.self) { stage in
                        Toggle(stage, isOn: binding(for: stage, in: $viewModel.selectedStages))
                    }
                }
                
                Section("Deal Size") {
                    Slider(
                        value: $viewModel.minDealSize,
                        in: 0...100,
                        step: 5
                    ) {
                        Text("Minimum Deal Size ($M)")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("100+")
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        viewModel.applyFilters()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func binding(for item: String, in set: Binding<Set<String>>) -> Binding<Bool> {
        Binding(
            get: { set.wrappedValue.contains(item) },
            set: { isSelected in
                if isSelected {
                    set.wrappedValue.insert(item)
                } else {
                    set.wrappedValue.remove(item)
                }
            }
        )
    }
} 