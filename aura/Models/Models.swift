import Foundation

// MARK: - Core Models
struct Industry: Identifiable {
    let id = UUID()
    let name: String
    let totalFunding: Double
    let growthRate: Double
    let description: String
    let keyMetrics: [IndustryMetricDetail]
    let fundingHistory: [FundingDataPoint]
    let topCompanies: [CompanyInfo]
    let trends: [String]
    let marketSize: Double
    let competitors: Int
    
    static let mockData = [
        Industry(
            name: "Fintech",
            totalFunding: 45.2,
            growthRate: 12.5,
            description: "Financial technology companies revolutionizing banking, payments, and investments",
            keyMetrics: [
                IndustryMetricDetail(name: "Average Deal Size", value: "$28M"),
                IndustryMetricDetail(name: "Active Startups", value: "2,450"),
                IndustryMetricDetail(name: "YoY Growth", value: "+12.5%"),
                IndustryMetricDetail(name: "Market Share", value: "18.2%")
            ],
            fundingHistory: generateFundingHistory(baseAmount: 45.2, volatility: 0.15),
            topCompanies: [
                CompanyInfo(name: "Stripe", funding: 2100.0, employeeCount: 4500),
                CompanyInfo(name: "Plaid", funding: 734.3, employeeCount: 1200),
                CompanyInfo(name: "Robinhood", funding: 5600.0, employeeCount: 2800)
            ],
            trends: [
                "Embedded Finance",
                "DeFi Integration",
                "Open Banking"
            ],
            marketSize: 180.5,
            competitors: 2450
        ),
        Industry(
            name: "AI/ML",
            totalFunding: 38.7,
            growthRate: 28.3,
            description: "Artificial Intelligence and Machine Learning solutions across industries",
            keyMetrics: [
                IndustryMetricDetail(name: "Average Deal Size", value: "$32M"),
                IndustryMetricDetail(name: "Active Startups", value: "1,850"),
                IndustryMetricDetail(name: "YoY Growth", value: "+28.3%"),
                IndustryMetricDetail(name: "Market Share", value: "15.5%")
            ],
            fundingHistory: generateFundingHistory(baseAmount: 38.7, volatility: 0.2),
            topCompanies: [
                CompanyInfo(name: "OpenAI", funding: 11300.0, employeeCount: 375),
                CompanyInfo(name: "Anthropic", funding: 4100.0, employeeCount: 280),
                CompanyInfo(name: "Cohere", funding: 445.0, employeeCount: 190)
            ],
            trends: [
                "Large Language Models",
                "Computer Vision",
                "AI Infrastructure"
            ],
            marketSize: 150.8,
            competitors: 1850
        ),
        // Add more industries with similar detailed data...
    ]
    
    static func generateFundingHistory(baseAmount: Double, volatility: Double) -> [FundingDataPoint] {
        let timeRanges: [(TimeRange, Int)] = [
            (.week, 7),    // Daily for a week
            (.month, 30),  // Daily for a month
            (.quarter, 90), // Daily for a quarter
            (.year, 12),   // Monthly for a year
            (.all, 24)     // Monthly for 2 years
        ]
        
        var allDataPoints: [FundingDataPoint] = []
        let calendar = Calendar.current
        let now = Date()
        
        for (_, days) in timeRanges {
            var amount = baseAmount
            for day in 0..<days {
                let date = calendar.date(byAdding: .day, value: -day, to: now) ?? now
                let change = Double.random(in: -volatility...volatility)
                amount += amount * change
                allDataPoints.append(FundingDataPoint(date: date, amount: amount))
            }
        }
        
        return allDataPoints.sorted { $0.date < $1.date }
    }
}

struct FundingDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct IndustryMetric: Identifiable {
    let id = UUID()
    let name: String
    let funding: Double
    let change: Double
    let timeRange: TimeRange
}

struct IndustryDistribution: Identifiable {
    let id = UUID()
    let name: String
    let percentage: Double
    let timeRange: TimeRange
}

struct TopMover: Identifiable {
    let id = UUID()
    let name: String
    let change: Double
    let previousValue: Double
    let currentValue: Double
    let timeRange: TimeRange
}

struct CompanyInfo: Identifiable {
    let id = UUID()
    let name: String
    let funding: Double
    let employeeCount: Int
    var fundingHistory: [FundingDataPoint]? = nil
    var growthRate: Double? = nil
}

struct IndustryMetricDetail: Identifiable {
    let id = UUID()
    let name: String
    let value: String
}

enum TimeRange: String, CaseIterable, Identifiable {
    case week = "1W"
    case month = "1M"
    case quarter = "3M"
    case year = "1Y"
    case all = "All"
    
    var id: String { rawValue }
    var title: String { rawValue }
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        case .year: return 365
        case .all: return 730 // 2 years
        }
    }
} 