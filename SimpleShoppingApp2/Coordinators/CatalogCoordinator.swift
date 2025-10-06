//
//  CatalogCoordinator.swift
//  SimpleShoppingApp2
//
//  Created by Olaf Bergmann on 06/10/2025.
//

import UIKit

final class CatalogCoordinator: Coordinator {
    var navigationController: UINavigationController
    private let currencyService: CurrencyService
    private let mockService: MockService
    private let basketVM: BasketViewModel?

    init(navigationController: UINavigationController,
         mockService: MockService,
         currencyService: CurrencyService,
         basketVM: BasketViewModel) {
        self.navigationController = navigationController
        self.mockService = mockService
        self.currencyService = currencyService
        self.basketVM = basketVM
    }

    func start() {
        let catalogVM = CatalogViewModel(service: mockService, currencyService: currencyService)
        guard let basketVM else { return }
        let catalogVC = CatalogViewController(viewModel: catalogVM, basketVM: basketVM)
        catalogVM.coordinator = self
        catalogVC.title = "Catalog"
        navigationController.setViewControllers([catalogVC], animated: false)
    }
}
