//
//  DependencyContainer.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/21/25.
//

import UIKit

final class DependencyContainer {
    
    static let shared = DependencyContainer()
    
    lazy var networkManager: APISession = {
        return NetworkAdapter()
    }()
    
    lazy var userDefaultsManager = {
        return UserDefaultsManager()
    }()
}
