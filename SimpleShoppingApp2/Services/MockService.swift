import Foundation

final class MockService {

    struct ProductResponse: Codable {
        let products: [Product]
    }

    struct CurrencyResponse: Codable {
        let success: Bool
        let timestamp: Int
        let source: String
        let quotes: [String: Double]
    }

    func loadProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        loadJSON(named: "products", type: ProductResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.products))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadCurrencies(completion: @escaping (Result<[String: Double], Error>) -> Void) {
        loadJSON(named: "currencies", type: CurrencyResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.quotes))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func loadJSON<T: Decodable>(named name: String, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.global().async {
            guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "MockService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Missing \(name).json"])))
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}
