//
//  DetailsVeiwModel.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/21/25.
//

import UIKit

final class DetailsViewModel {
    
    private let userdefaults = DependencyContainer.shared.userDefaultsManager
    
    func saveState(list: [ProfileCollectionCell.Item]) {
        userdefaults.saveState(list: list)
    }
    
    func getState() -> [ProfileCollectionCell.Item] {
        return userdefaults.getState()
    }
}
