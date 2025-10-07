import Foundation
import RxSwift
import RxCocoa

final class BasketViewModel {
    let addProduct = PublishRelay<Product>()
    let removeProduct = PublishRelay<Product>()
    
    let selectedCurrency = BehaviorRelay<String>(value: "USD")
    let items: BehaviorRelay<[BasketItem]> = .init(value: [])
    
    let totalUSD: Observable<Double>
    let totalInSelectedCurrency: Observable<String>
    
    weak var coordinator: BasketCoordinator?
    
    private let disposeBag = DisposeBag()
    let currencyService: CurrencyService
    
    init(currencyService: CurrencyService) {
        self.currencyService = currencyService
        
        totalUSD = items
            .map { $0.reduce(0.0) { $0 + $1.totalUSD } }
            .asObservable()
        
        totalInSelectedCurrency = Observable.combineLatest(totalUSD, selectedCurrency)
            .map { [weak currencyService] total, currency in
                guard let service = currencyService else { return "-" }
                let converted = service.convert(amountUSD: total, to: currency)
                return String(format: "%.2f %@", converted, currency)
            }
        
        addProduct.subscribe(onNext: { [weak self] product in
            guard let self = self else { return }
            var current = self.items.value
            if let idx = current.firstIndex(where: { $0.product == product }) {
                current[idx].quantity += 1
            } else {
                current.append(BasketItem(product: product, quantity: 1))
            }
            self.items.accept(current)
        }).disposed(by: disposeBag)
        
        removeProduct.subscribe(onNext: { [weak self] product in
            guard let self = self else { return }
            var current = self.items.value
            if let idx = current.firstIndex(where: { $0.product == product }) {
                current[idx].quantity -= 1
                if current[idx].quantity <= 0 { current.remove(at: idx) }
                self.items.accept(current)
            }
        }).disposed(by: disposeBag)
    }
    
    func clear() {
        items.accept([])
    }
}
