import Foundation
import RxSwift
import RxCocoa

final class CatalogViewModel {
    let products: BehaviorRelay<[Product]> = .init(value: [])
    private let service: MockService
    private let currencyService: CurrencyService
    private let disposeBag = DisposeBag()
    weak var coordinator: CatalogCoordinator?

    init(service: MockService, currencyService: CurrencyService) {
        self.service = service
        self.currencyService = currencyService
    }

    func load() {
        service.loadProducts { [weak self] result in
            switch result {
            case .success(let products):
                self?.products.accept(products)
            case .failure(let err):
                print("Failed load:", err)
            }
        }
    }
}
