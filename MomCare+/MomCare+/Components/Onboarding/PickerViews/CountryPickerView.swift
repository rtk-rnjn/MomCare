

import SwiftUI

struct CountryPickerView: View {

    // MARK: Internal

    @Binding var selectedCountry: String?

    var body: some View {
        NavigationView {
            List(filteredCountries, id: \.self) { country in
                Button {
                    selectedCountry = country
                    dismiss()
                } label: {
                    Text(country)
                        .foregroundStyle(.primary)
                }
            }
            .tint(.primary)
            .safeAreaInset(edge: .top) {
                Color.clear
                    .frame(height: 8)
            }
            .searchable(text: $searchText)
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private let countries = CountryData.countryCodes.values.sorted()

    private var filteredCountries: [String] {
        searchText.isEmpty
            ? countries
            : countries.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
    }
}
