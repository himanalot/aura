import SwiftUI

struct TopMoversCard: View {
    let movers: [TopMover]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Movers")
                .font(.headline)
            
            ForEach(movers) { mover in
                HStack {
                    Text(mover.name)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(String(format: "$%.1fB", mover.currentValue))
                            .font(.subheadline)
                        TrendBadge(change: mover.change)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TrendBadge: View {
    let change: Double
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
            Text("\(abs(change), specifier: "%.1f")%")
        }
        .font(.caption)
        .foregroundColor(change >= 0 ? .green : .red)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(change >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        )
    }
} 