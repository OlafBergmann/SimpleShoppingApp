//
//  BasketCoordinator.swift
//  SimpleShoppingApp2
//
//  Created by Olaf Bergmann on 06/10/2025.
//

import UIKit

final class BasketCoordinator: Coordinator {
    var navigationController: UINavigationController

    private let basketVM: BasketViewModel?

    init(navigationController: UINavigationController,
         basketVM: BasketViewModel) {
        self.navigationController = navigationController
        self.basketVM = basketVM
    }

    func start() {
        guard let basketVM else { return }
        let basketVC = BasketViewController(viewModel: basketVM)
        basketVM.coordinator = self
        basketVC.title = "Basket"
        navigationController.setViewControllers([basketVC], animated: false)
    }
    
    func showPaymentConfrimation() {
        let confirmationVC = PaymentConfirmationViewController()
        confirmationVC.basketVM = basketVM
        confirmationVC.modalPresentationStyle = .pageSheet   // modal style
        if let sheet = confirmationVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        self.navigationController.present(confirmationVC, animated: true)
    }
}
