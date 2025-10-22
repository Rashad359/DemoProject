//
//  FavoritesViewModel.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/22/25.
//

import UIKit

protocol FavoritesViewDelegate: AnyObject {
    func bookmarked()
}

final class FavoritesViewModel {
    
    private let userDefaults = DependencyContainer.shared.userDefaultsManager
    
    private weak var delegate: FavoritesViewDelegate? = nil
    
    private let coordinator: AppCoordinator?
    
    func subscribe(_ delegate: FavoritesViewDelegate) {
        self.delegate = delegate
    }
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func getList() -> [ProfileCollectionCell.Item] {
        return userDefaults.getState()
    }
    
    func goToDetails(with data: DetailsData) {
        coordinator?.navigateToDetails(with: data) { [weak self] in
            self?.delegate?.bookmarked()
        }
    }
}
