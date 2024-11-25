import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(TimeRange.allCases) { range in
                                TimeRangeButton(
                                    range: range,
                                    isSelected: range == viewModel.selectedTimeRange,
                                    action: { viewModel.updateTimeRange(range) }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Summary Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        let totalFunding = viewModel.topIndustries.reduce(0) { $0 + $1.funding }
                        let topChange = viewModel.topIndustries.first?.change ?? 0
                        
                        MetricCard(
                            title: "Total Funding",
                            value: String(format: "$%.1fB", totalFunding),
                            trend: String(format: "%+.1f%%", topChange),
                            isPositive: topChange >= 0,
                            systemImage: "dollarsign.circle.fill"
                        )
                        
                        MetricCard(
                            title: "Active Deals",
                            value: "234",
                            trend: "+12.4%",
                            isPositive: true,
                            systemImage: "chart.line.uptrend.xyaxis"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Funding History Chart
                    if !viewModel.fundingHistory.isEmpty {
                        FundingHistoryChart(data: viewModel.fundingHistory)
                            .frame(height: 200)
                            .padding()
                    }
                    
                    // Industry Distribution
                    if !viewModel.industryDistribution.isEmpty {
                        IndustryDistributionCard(distribution: viewModel.industryDistribution)
                            .padding(.horizontal)
                    }
                    
                    // Top Movers
                    if !viewModel.topMovers.isEmpty {
                        TopMoversCard(movers: viewModel.topMovers)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .refreshable {
                viewModel.loadData()
            }
        }
    }
}

#Preview {
    DashboardView()
} 
