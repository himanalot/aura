import SwiftUI
import Charts

struct FundingHistoryChart: View {
    let data: [FundingDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Funding History")
                .font(.headline)
            
            Chart(data) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Amount", point.amount)
                )
                .foregroundStyle(Color.blue)
                
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Amount", point.amount)
                )
                .foregroundStyle(Color.blue.opacity(0.1))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 