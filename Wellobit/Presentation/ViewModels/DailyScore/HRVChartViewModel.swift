@MainActor
final class HRVChartViewModel: ObservableObject {

    @Published var hrvPoints: [HRVPoint] = []
    @Published var isEmpty = false

    private let fetchHRVUseCase: FetchTodayHRVUseCase

    init(fetchHRVUseCase: FetchTodayHRVUseCase) {
        self.fetchHRVUseCase = fetchHRVUseCase
    }

    func load() async {
        do {
            let points = try await fetchHRVUseCase.execute()
            self.hrvPoints = points
            self.isEmpty = points.isEmpty
        } catch {
            self.hrvPoints = []
            self.isEmpty = true
        }
    }
}
