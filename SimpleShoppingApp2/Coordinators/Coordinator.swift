//
//  Coordinator.swift
//  SimpleShoppingApp2
//
//  Created by Olaf Bergmann on 06/10/2025.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}
