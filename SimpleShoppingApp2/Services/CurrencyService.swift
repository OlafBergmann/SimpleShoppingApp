import RxSwift
import RxCocoa

final class CurrencyService {
    private var exchangeRates: [String: Double] = [:]
    private let mockService = MockService()

    let ratesLoaded = BehaviorRelay<Bool>(value: false)

    init() {
        loadRates()
    }

    private func loadRates() {
        mockService.loadCurrencies { [weak self] result in
            switch result {
            case .success(let rates):
                self?.exchangeRates = rates
                self?.exchangeRates["USDUSD"] = 1.0
                self?.ratesLoaded.accept(true)
            case .failure(let error):
                print("Failed to load mock rates:", error)
                self?.ratesLoaded.accept(false)
            }
        }
    }

    func convert(amountUSD: Double, to currency: String) -> Double {
        let key = "USD\(currency)"
        return amountUSD * (exchangeRates[key] ?? 1.0)
    }

//    var availableCurrencies: [String] {
//        return exchangeRates.keys.map { $0.replacingOccurrences(of: "USD", with: "") }.sorted()
//    }
    var availableCurrencies: [String] {
        // Start with USD
        var currencies = ["USD"]
        
        // Add all other currencies from the exchangeRates keys
        let otherCurrencies = exchangeRates.keys.compactMap { key -> String? in
            if key == "USDUSD" { return nil } // skip the USD we already added
            if key.hasPrefix("USD") {
                return String(key.dropFirst(3)) // remove USD prefix
            }
            return nil
        }
        
        currencies.append(contentsOf: otherCurrencies.sorted())
        return currencies
    }

}
