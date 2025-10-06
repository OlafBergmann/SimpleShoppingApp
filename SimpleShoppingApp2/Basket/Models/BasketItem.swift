import Foundation

struct BasketItem: Equatable {
    let product: Product
    var quantity: Int

    var totalUSD: Double {
        return Double(quantity) * product.priceUSD
    }
}
