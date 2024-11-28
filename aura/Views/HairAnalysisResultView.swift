import SwiftUI

struct HairAnalysisResultView: View {
    let analysis: HairAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                ResultSection(title: "Hair Thickness", value: analysis.thickness)
                ResultSection(title: "Hair Health", value: analysis.health)
            }
            
            Text("Recommendations")
                .font(.headline)
            
            ForEach(analysis.recommendations, id: \.self) { recommendation in
                HStack(alignment: .top) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .padding(.top, 6)
                    Text(recommendation)
                }
                .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

private struct ResultSection: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    HairAnalysisResultView(analysis: HairAnalysis(
        thickness: "Medium",
        health: "Good",
        recommendations: [
            "Include more protein-rich foods in your diet",
            "Use a silk pillowcase to reduce friction",
            "Deep condition your hair weekly"
        ],
        date: Date()
    ))
    .padding()
} 