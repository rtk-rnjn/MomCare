//
//  MapPickerView.swift
//  MomCare+
//
//  Created by Aryan singh on 15/02/26.
//

import MapKit
import SwiftUI

struct MapPickerView: View {

    // MARK: Internal

    @Binding var selectedMapItem: MKMapItem?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // MARK: Map

                Map(position: $cameraPosition) {
                    if let selectedMapItem {
                        Marker(
                            selectedMapItem.name ?? "",
                            coordinate: selectedMapItem.placemark.coordinate
                        )
                    }
                }
                .ignoresSafeArea()

                // MARK: Search Bar

                searchBar
            }
            .safeAreaInset(edge: .bottom) {
                resultsView
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(selectedMapItem == nil)
                }
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
        .onChange(of: locationManager.userLocation) { _, location in
            if let location {
                withAnimation(.easeInOut(duration: 0.5)) {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05,
                                                   longitudeDelta: 0.05)
                        )
                    )
                }
            }
        }
    }

    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search for a place",
                      text: $searchText)
                .onChange(of: searchText) {
                    performSearch()
                }
            Button {
                if let location = locationManager.userLocation {
                    let coordinate = location.coordinate

                    let placemark = MKPlacemark(coordinate: coordinate)
                    selectedMapItem = MKMapItem(placemark: placemark)

                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                       longitudeDelta: 0.01)
                            )
                        )
                    }
                }
            } label: {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
            }

            if isSearching {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .shadow(radius: 5)
    }

    var resultsView: some View {
        Group {
            if !searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchResults, id: \.self) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name ?? "")
                                    .font(.headline)

                                Text(item.placemark.title ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity,
                                   alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                            )
                            .onTapGesture {
                                select(item)
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 300)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding()
            }
        }
    }

    func select(_ item: MKMapItem) {
        selectedMapItem = item

        withAnimation(.easeInOut(duration: 0.35)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: item.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01,
                                           longitudeDelta: 0.01)
                )
            )
        }
    }

    // MARK: Private

    @StateObject private var locationManager: LocationManager = .init()

    @Environment(\.dismiss) private var dismiss

    // MARK: State

    @State private var searchText: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching: Bool = false

    @State private var cameraPosition: MapCameraPosition =
        .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
                span: MKCoordinateSpan(latitudeDelta: 0.05,
                                       longitudeDelta: 0.05)
            )
        )

    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        isSearching = true

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.resultTypes = [.address, .pointOfInterest]

        // Important: give it a broad region
        request.region = MKCoordinateRegion(
            center: cameraCenterCoordinate(),
            span: MKCoordinateSpan(latitudeDelta: 0.5,
                                   longitudeDelta: 0.5)
        )

        let search = MKLocalSearch(request: request)

        search.start { response, _ in
            DispatchQueue.main.async {
                isSearching = false
                searchResults = response?.mapItems ?? []
            }
        }
    }

    private func cameraCenterCoordinate() -> CLLocationCoordinate2D {
        if let region = cameraPosition.region {
            return region.center
        }
        return CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090)
    }

}
