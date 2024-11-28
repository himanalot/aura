import SwiftUI
import Charts

struct ProgressChartView: View {
    let analyses: [HairAnalysis]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress Overview")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AuraTheme.gradient)
            
            Chart {
                ForEach(analyses.prefix(10)) { analysis in
                    LineMark(
                        x: .value("Date", analysis.date),
                        y: .value("Score", analysis.overallScore)
                    )
                    .foregroundStyle(AuraTheme.gradient)
                    
                    PointMark(
                        x: .value("Date", analysis.date),
                        y: .value("Score", analysis.overallScore)
                    )
                    .foregroundStyle(AuraTheme.gradient)
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.formatted(.dateTime.month().day()))
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AuraTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
} 