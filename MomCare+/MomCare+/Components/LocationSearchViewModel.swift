import Combine
import MapKit

class LocationSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {

    // MARK: Lifecycle

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    // MARK: Internal

    @Published var searchText = ""
    @Published var results: [MKLocalSearchCompletion] = []
    @Published var selectedMapItem: MKMapItem?
    @Published var showMap = false

    func updateSearch(query: String) {
        completer.queryFragment = query
    }

    func select(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        search.start { response, _ in
            DispatchQueue.main.async {
                self.selectedMapItem = response?.mapItems.first
                self.showMap = true
                self.results = []
            }
        }
    }

    // MARK: Private

    private var completer: MKLocalSearchCompleter = .init()

}
