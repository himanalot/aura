import Foundation
import SwiftUI

class IndustryDetailViewModel: ObservableObject {
    @Published var fundingHistory: [FundingDataPoint] = []
    @Published var topCompanies: [CompanyInfo] = []
    @Published var metrics: [IndustryMetricDetail] = []
    @Published var activeCompanies: Int = 0
    
    func loadData(for industry: Industry) {
        // Mock data - in a real app, this would fetch from an API
        fundingHistory = (0..<12).map { month in
            FundingDataPoint(
                date: Calendar.current.date(byAdding: .month,
                                          value: -month,
                                          to: Date()) ?? Date(),
                amount: Double.random(in: 2...8)
            )
        }.reversed()
        
        topCompanies = [
            CompanyInfo(name: "TechCorp", funding: 250.0, employeeCount: 1200),
            CompanyInfo(name: "InnovateLabs", funding: 180.0, employeeCount: 850),
            CompanyInfo(name: "FutureTech", funding: 120.0, employeeCount: 600)
        ]
        
        metrics = [
            IndustryMetricDetail(name: "Avg Deal Size", value: "$25M"),
            IndustryMetricDetail(name: "YoY Growth", value: "15.2%"),
            IndustryMetricDetail(name: "Market Share", value: "8.5%")
        ]
        
        activeCompanies = 234
    }
} 