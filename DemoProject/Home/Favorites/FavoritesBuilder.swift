//
//  FavoritesBuilder.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/22/25.
//

import UIKit

final class FavoritesBuilder {
    
    private let coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func build() -> UIViewController {
        let viewModel = FavoritesViewModel(coordinator: coordinator)
        let favoritesVC = FavoritesViewController(viewModel: viewModel)
        return favoritesVC
    }
}
