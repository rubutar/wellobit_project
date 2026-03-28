import SwiftUI

struct InsightsView: View {
    
    @StateObject private var viewModel = InsightsViewModel(
        getInsightsUseCase: GetInsightsUseCase(
            repository: HealthKitInsightsRepository()
            //            repository: DummyInsightsRepository()
        )
    )
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.bgGreen2, Color.bgGreen],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                titleHeader
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        periodToggle
                        mainContent
                            .padding(.horizontal, 28)
                    }
                }
            }
        }
    }
    
    // MARK: - Sub-views
    
    private var titleHeader: some View {
        HStack {
            Text("Insights")
                .font(.figtree(size: 30, weight: .regular))
                .foregroundColor(Color.tmFontBlack22)
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
    
    private var periodToggle: some View {
        InsightsPeriodToggle(selectedPeriod: $viewModel.selectedPeriod)
            .padding(.horizontal, 28)
            .padding(.bottom, 20)
    }
    
    private var mainContent: some View {
        VStack(spacing: 16) {
            // Bar chart card (week navigator + bars)
            barChartCard
            
            
            // Summary cards row
            if let summary = viewModel.summary {
                InsightsSummaryCards(summary: summary)
            }
        }
    }
    
    private var barChartCard: some View {
        VStack(spacing: 0) {
            InsightsWeekNavigator(
                dateRange: viewModel.summary?.weekRangeFormatted ?? "",
                onPrevious: viewModel.previousWeek,
                onNext: viewModel.nextWeek,
                canGoNext: viewModel.canGoToNextWeek
            )
            .padding(18)
            
            InsightsBarChart(
                entries: viewModel.entries,
                selectedId: viewModel.selectedEntryId,
                onSelect: viewModel.selectEntry
            )
            .padding(.horizontal, 12)
            
            if let insight = viewModel.selectedDayInsight {
                InsightsDayDetailCard(
                    insight: insight
                )
                .padding(.bottom, 12)
            }
        }
        .background(Color.tmWhite)
        .clipShape(RoundedRectangle(cornerRadius: 36))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
}

// MARK: - Preview

#Preview {
    InsightsView()
}
