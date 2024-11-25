import SwiftUI

struct IndustryDistributionCard: View {
    let distribution: [IndustryDistribution]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Industry Distribution")
                .font(.headline)
            
            ForEach(distribution) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text("\(Int(item.percentage))%")
                        .foregroundColor(.secondary)
                }
                ProgressView(value: item.percentage, total: 100)
                    .tint(Color.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 