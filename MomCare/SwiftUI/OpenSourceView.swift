import SwiftUI

private let textPrimary: Color = .init(red: 0.1, green: 0.1, blue: 0.1)

private let textSecondary: Color = .init(red: 0.4, green: 0.4, blue: 0.4)

private let brandPink: Color = .init(red: 146/255, green: 67/255, blue: 80/255)

struct OpenSourceView: View {

    var body: some View {

        ZStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 24) {

                    Text("MomCare+ is proudly built using open-source software. We are grateful to the developers and communities who create and maintain these essential tools.")

                        .font(.subheadline)

                        .foregroundColor(textSecondary)

                    VStack(alignment: .leading, spacing: 12) {

                        Text("Our License")

                            .font(.title2)

                            .fontWeight(.bold)

                            .foregroundColor(brandPink)

                        ForEach(LicenseData.appLicense) { license in

                            LicenseCardView(

                                name: license.name, license: license.license, urlString: license.urlString

                            )

                        }

                    }

                VStack(alignment: .leading, spacing: 12) {

                    Text("Project Report")

                        .font(.title2)

                        .fontWeight(.bold)

                        .foregroundColor(brandPink)

                    ForEach(LicenseData.projectReport) { report in

                        LicenseCardView(

                            name: report.name, license: report.license, urlString: report.urlString

                        )

                    }

                }

                VStack(alignment: .leading, spacing: 12) {

                    Text("Third-Party Libraries")

                        .font(.title2)

                        .fontWeight(.bold)

                        .foregroundColor(brandPink)

                    ForEach(LicenseData.thirdPartyLicenses) { license in

                        LicenseCardView(

                            name: license.name, license: license.license, urlString: license.urlString

                        )

                    }

                }

            }

            .padding(.horizontal, 30)

            .padding(.top, 30)

            }

        }

        .navigationBarTitleDisplayMode(.inline)

    }

}

struct LicenseCardView: View {

    let name: String

    let license: String

    let urlString: String

    var body: some View {

        if let url = URL(string: urlString) {

            Link(destination: url) {

                HStack {

                    VStack(alignment: .leading, spacing: 4) {

                        Text(name)

                            .font(.headline)

                            .fontWeight(.semibold)

                            .foregroundColor(textPrimary)

                        Text(license)

                            .font(.subheadline)

                            .foregroundColor(textSecondary)

                    }

                    Spacer()

                    Image(systemName: "arrow.up.right.square")

                        .font(.title3)

                        .foregroundColor(textSecondary.opacity(0.7))

                }

                .padding()

                .background(.white)

                .cornerRadius(16)

                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)

            }

        }

    }

}

struct OpenSourceView_Previews: PreviewProvider {

    static var previews: some View {

        NavigationView {

            OpenSourceView()

        }

    }

}
