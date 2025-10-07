//
//  SceneDelegate.swift
//  SimpleShoppingApp2
//
//  Created by Olaf Bergmann on 03/10/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var catalogCoordinator: CatalogCoordinator?
    var basketCoordinator: BasketCoordinator?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let mockService = MockService()
        let currencyService = CurrencyService()
        
        // Navigation controllers
        let catalogNav = UINavigationController()
        let basketNav = UINavigationController()
        
        let basketVM = BasketViewModel(currencyService: currencyService)
        // Coordinators
        let catalogCoordinator = CatalogCoordinator(
            navigationController: catalogNav,
            mockService: mockService,
            basketVM: basketVM
        )
        let basketCoordinator = BasketCoordinator(
            navigationController: basketNav,
            basketVM: basketVM
        )
        
        self.catalogCoordinator = catalogCoordinator
        self.basketCoordinator = basketCoordinator
        
        catalogCoordinator.start()
        basketCoordinator.start()
        
        catalogNav.tabBarItem = UITabBarItem(title: "Catalog",
                                             image: UIImage(systemName: "list.bullet"), tag: 0)
        basketNav.tabBarItem = UITabBarItem(title: "Basket",
                                            image: UIImage(systemName: "cart"), tag: 1)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [catalogNav, basketNav]
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
}

