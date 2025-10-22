//
//  AppCoordinator.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/20/25.
//

import UIKit

protocol Coordinator {
    func start()
}

class AppCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        let tabbar = HomeTabBarController(coordinator: self)
        navigationController.setViewControllers([tabbar], animated: true)
    }
    
    func navigateToDetails(with data: DetailsData, completion: (() -> ())?) {
        let detailsVC = DetailsBuilder(detailsData: data).build(completion: completion)
        navigationController.pushViewController(detailsVC, animated: true)
    }
}
