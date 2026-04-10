import Combine
import MapKit
import SwiftUI

struct MapPickerView: View {
    // MARK: Internal

    @Binding var selectedMapItem: MKMapItem?

    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $cameraPosition, interactionModes: .all) {
                    if let item = selectedMapItem {
                        if #available(iOS 26.0, *) {
                            Marker(item.name ?? "", coordinate: item.location.coordinate)
                        } else {
                            Marker(item.name ?? "", coordinate: .init(
                                latitude: item.placemark.coordinate.latitude,
                                longitude: item.placemark.coordinate.longitude)
                            )
                        }
                    }
                }
                .ignoresSafeArea()
                .accessibilityLabel("Map. Tap to select a location")
                .accessibilityHint("Double tap to place a marker at the tapped location")
                .onTapGesture { screenPoint in
                    if let coordinate = proxy.convert(screenPoint, from: .local) {
                        let location = CLLocation(
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude
                        )

                        if #available(iOS 26.0, *) {
                            selectedMapItem = MKMapItem(location: location, address: nil)
                        } else {
                            selectedMapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                        }

                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: coordinate,
                                    span: MKCoordinateSpan(
                                        latitudeDelta: 0.01,
                                        longitudeDelta: 0.01
                                    )
                                )
                            )
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .searchable(text: $searchService.searchText, placement: .automatic)
            .searchSuggestions {
                ForEach(searchService.results, id: \.self) { item in
                    Button {
                        isSearchFieldFocused = false
                        selectedMapItem = item
                        if #available(iOS 26, *) {
                            cameraPosition = .region(MKCoordinateRegion(center: item.location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
                        } else {
                            cameraPosition = .region(MKCoordinateRegion(center: item.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unknown Place")
                                .font(.headline)
                            if #available(iOS 26.0, *) {
                                if let address = item.address?.fullAddress {
                                    Text(address)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            } else {
                                if let address = item.placemark.title {
                                    Text(address)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton {
                        selectedMapItem = nil
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    MCDoneButton {
                        dismiss()
                    }
                    .disabled(selectedMapItem == nil)
                }
            }
            .onAppear {
                locationManager.requestPermission()

                if let userLocation = locationManager.userLocation {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: userLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    )
                }
            }
        }
    }

    // MARK: Private

    @FocusState private var isSearchFieldFocused: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @StateObject private var searchService: MapSearchService = .init()
    @StateObject private var locationManager: LocationManager = .init()

    @State private var cameraPosition: MapCameraPosition =
        .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
}

@MainActor
final class MapSearchService: NSObject, ObservableObject {
    // MARK: Lifecycle

    override init() {
        super.init()

        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]

        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { text in
                self.performSearch(text)
            }
            .store(in: &cancellables)
    }

    // MARK: Internal

    @Published var searchText: String = ""
    @Published var results: [MKMapItem] = []

    // MARK: Private

    private let completer: MKLocalSearchCompleter = .init()
    private var cancellables: Set<AnyCancellable> = []

    private func performSearch(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        completer.queryFragment = text
    }
}

extension MapSearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task {
            var items = [MKMapItem]()

            for suggestion in completer.results {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = suggestion.title

                let search = MKLocalSearch(request: request)

                if let response = try? await search.start() {
                    items.append(contentsOf: response.mapItems)
                }
            }

            await MainActor.run {
                self.results = items
            }
        }
    }
}
