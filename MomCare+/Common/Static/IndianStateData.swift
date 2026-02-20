enum IndianState: String, Codable, CaseIterable, Identifiable, Hashable {
    case andaman
    case andhraPradesh = "andhra pradesh"
    case arunachalPradesh = "arunachal pradesh"
    case assam
    case bihar
    case chandigarh
    case chhattisgarh
    case dadraAndNagarHaveli = "dadra and nagar haveli"
    case damanAndDiu = "daman and diu"
    case delhi
    case goa
    case gujarat
    case haryana
    case himachalPradesh = "himachal pradesh"
    case jammuAndKashmir = "jammu and kashmir"
    case jharkhand
    case karnataka
    case kerala
    case ladakh
    case lakshadweep
    case madhyaPradesh = "madhya pradesh"
    case maharashtra
    case manipur
    case meghalaya
    case mizoram
    case nagaland
    case odisha
    case puducherry
    case punjab
    case rajasthan
    case sikkim
    case tamilNadu = "tamil nadu"
    case telangana
    case tripura
    case uttarPradesh = "uttar pradesh"
    case uttarakhand
    case westBengal = "west bengal"

    // MARK: Internal

    var id: String {
        rawValue
    }

}
