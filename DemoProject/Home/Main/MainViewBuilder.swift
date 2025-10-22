//
//  MainViewBuilder.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/21/25.
//

import UIKit

final class MainViewBuilder {
    
    private let coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func build() -> UIViewController {
        let viewModel = MainViewModel(coordinator: coordinator)
        let vc = MainViewController(viewModel: viewModel)
        return vc
    }
}
