import SwiftUI
import Charts

struct IndustryDetailView: View {
    let industry: Industry
    @StateObject private var viewModel = IndustryDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Stats
                headerStats
                
                // Funding History Chart
                ChartSection(title: "Funding History") {
                    Chart(viewModel.fundingHistory) { item in
                        LineMark(
                            x: .value("Month", item.date),
                            y: .value("Amount", item.amount)
                        )
                        .foregroundStyle(Color.blue)
                    }
                    .frame(height: 200)
                }
                
                // Top Companies
                topCompanies
                
                // Key Metrics
                keyMetrics
            }
            .padding(.vertical)
        }
        .navigationTitle(industry.name)
        .onAppear {
            viewModel.loadData(for: industry)
        }
    }
    
    private var headerStats: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatBox(
                title: "Total Funding",
                value: String(format: "$%.1fB", industry.totalFunding)
            )
            StatBox(
                title: "Growth Rate",
                value: String(format: "%+.1f%%", industry.growthRate),
                color: industry.growthRate >= 0 ? .green : .red
            )
            StatBox(
                title: "Active Companies",
                value: String(viewModel.activeCompanies)
            )
        }
        .padding(.horizontal)
    }
    
    private var topCompanies: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Companies")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(viewModel.topCompanies) { company in
                    CompanyRow(company: company)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var keyMetrics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Metrics")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(viewModel.metrics) { metric in
                    MetricRow(metric: metric)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// Supporting Views
struct StatBox: View {
    let title: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct CompanyRow: View {
    let company: CompanyInfo
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(company.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(String(format: "$%.1fM raised", company.funding))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(company.employeeCount))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct MetricRow: View {
    let metric: IndustryMetricDetail
    
    var body: some View {
        HStack {
            Text(metric.name)
                .font(.subheadline)
            
            Spacer()
            
            Text(metric.value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
} 