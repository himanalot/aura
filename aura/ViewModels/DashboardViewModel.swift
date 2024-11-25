import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var fundingHistory: [FundingDataPoint] = []
    @Published var topIndustries: [IndustryMetric] = []
    @Published var industryDistribution: [IndustryDistribution] = []
    @Published var topMovers: [TopMover] = []
    @Published var selectedTimeRange: TimeRange = .month
    @Published var selectedRegions = Set<String>()
    @Published var selectedStages = Set<String>()
    @Published var minDealSize: Double = 0
    
    init() {
        loadData()
    }
    
    func loadData() {
        // Mock data for funding history
        fundingHistory = (0..<12).map { month in
            FundingDataPoint(
                date: Calendar.current.date(byAdding: .month,
                                          value: -month,
                                          to: Date()) ?? Date(),
                amount: Double.random(in: 8...15)
            )
        }.reversed()
        
        // Mock data for industry highlights
        topIndustries = [
            IndustryMetric(
                name: "Fintech",
                funding: 4.2,
                change: 12,
                timeRange: selectedTimeRange
            ),
            IndustryMetric(
                name: "AI/ML",
                funding: 3.8,
                change: 15,
                timeRange: selectedTimeRange
            ),
            IndustryMetric(
                name: "Healthcare",
                funding: 2.9,
                change: -5,
                timeRange: selectedTimeRange
            ),
            IndustryMetric(
                name: "E-commerce",
                funding: 2.1,
                change: 8,
                timeRange: selectedTimeRange
            ),
            IndustryMetric(
                name: "Enterprise",
                funding: 1.8,
                change: -2,
                timeRange: selectedTimeRange
            )
        ]
        
        // Mock data for industry distribution
        industryDistribution = [
            IndustryDistribution(
                name: "Fintech",
                percentage: 25,
                timeRange: selectedTimeRange
            ),
            IndustryDistribution(
                name: "AI/ML",
                percentage: 20,
                timeRange: selectedTimeRange
            ),
            IndustryDistribution(
                name: "Healthcare",
                percentage: 18,
                timeRange: selectedTimeRange
            ),
            IndustryDistribution(
                name: "E-commerce",
                percentage: 15,
                timeRange: selectedTimeRange
            ),
            IndustryDistribution(
                name: "Enterprise",
                percentage: 12,
                timeRange: selectedTimeRange
            ),
            IndustryDistribution(
                name: "Others",
                percentage: 10,
                timeRange: selectedTimeRange
            )
        ]
        
        // Mock data for top movers
        topMovers = [
            TopMover(
                name: "AI/ML",
                change: 28.5,
                previousValue: 2.8,
                currentValue: 3.6,
                timeRange: selectedTimeRange
            ),
            TopMover(
                name: "Cybersecurity",
                change: 15.2,
                previousValue: 1.5,
                currentValue: 1.73,
                timeRange: selectedTimeRange
            ),
            TopMover(
                name: "Healthcare",
                change: -12.4,
                previousValue: 3.2,
                currentValue: 2.8,
                timeRange: selectedTimeRange
            ),
            TopMover(
                name: "Enterprise",
                change: -8.6,
                previousValue: 2.1,
                currentValue: 1.92,
                timeRange: selectedTimeRange
            )
        ]
    }
    
    func applyFilters() {
        // In a real app, this would filter data based on selected regions, stages, and deal size
        loadData()
    }
    
    func updateTimeRange(_ newRange: TimeRange) {
        selectedTimeRange = newRange
        loadData()
    }
} 