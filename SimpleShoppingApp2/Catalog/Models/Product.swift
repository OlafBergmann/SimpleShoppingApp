import Foundation

struct Product: Codable, Equatable {
    let id: String
    let name: String
    let priceUSD: Double
    let imageName: String
    let unit: String

    enum CodingKeys: String, CodingKey {
        case id, name, unit
        case imageName = "image_name"
        case priceUSD = "price_usd"
    }
}
