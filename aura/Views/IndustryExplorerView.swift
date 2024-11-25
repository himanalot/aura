import SwiftUI

struct IndustryExplorerView: View {
    @State private var searchText = ""
    @State private var selectedTimeRange: TimeRange = .month
    @State private var showingFilters = false
    @State private var selectedCategories: Set<String> = []
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Time Range Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(TimeRange.allCases) { range in
                            TimeRangeButton(
                                range: range,
                                isSelected: range == selectedTimeRange,
                                action: { selectedTimeRange = range }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                List {
                    // Categories Section
                    Section(header: Text("Categories")) {
                        ForEach(getCategories(), id: \.self) { category in
                            Toggle(category, isOn: binding(for: category))
                        }
                    }
                    
                    // Industries Section
                    Section(header: Text("Industries")) {
                        ForEach(filteredIndustries) { industry in
                            NavigationLink(destination: IndustryDetailView(industry: industry)) {
                                IndustryListRow(industry: industry)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Industries")
            .searchable(text: $searchText, prompt: "Search industries")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(viewModel: viewModel)
            }
        }
    }
    
    private func getCategories() -> [String] {
        ["Enterprise", "Consumer", "Infrastructure", "Deep Tech", "Healthcare"]
    }
    
    private func binding(for category: String) -> Binding<Bool> {
        Binding(
            get: { selectedCategories.contains(category) },
            set: { isSelected in
                if isSelected {
                    selectedCategories.insert(category)
                } else {
                    selectedCategories.remove(category)
                }
            }
        )
    }
    
    private var filteredIndustries: [Industry] {
        var industries = Industry.mockData
        
        // Apply search filter
        if !searchText.isEmpty {
            industries = industries.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if !selectedCategories.isEmpty {
            industries = industries.filter { industry in
                // In a real app, you would have category information in your Industry model
                true // Placeholder for category filtering
            }
        }
        
        // Sort by funding amount
        return industries.sorted { $0.totalFunding > $1.totalFunding }
    }
}

struct IndustryListRow: View {
    let industry: Industry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(industry.name)
                .font(.headline)
            
            Text(industry.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Funding")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("$\(industry.totalFunding, specifier: "%.1f")B")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Growth")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    TrendBadge(change: industry.growthRate)
                }
            }
            
            // Key metrics preview
            HStack {
                ForEach(industry.keyMetrics.prefix(2)) { metric in
                    VStack(alignment: .leading) {
                        Text(metric.name)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(metric.value)
                            .font(.caption)
                    }
                    if metric.id != industry.keyMetrics[1].id {
                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

