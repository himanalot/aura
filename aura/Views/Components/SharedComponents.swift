import SwiftUI
import Charts

struct ChartSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            content
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}



struct IndustryHighlights: View {
    let industries: [IndustryMetric]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Industry Highlights")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(industries) { industry in
                    HStack {
                        Text(industry.name)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(String(format: "$%.1fB", industry.funding))
                            .font(.subheadline)
                        
                        Text(String(format: "%+.1f%%", industry.change))
                            .font(.footnote)
                            .foregroundColor(industry.change >= 0 ? .green : .red)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
} 
