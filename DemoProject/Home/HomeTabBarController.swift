//
//  HomeTabBar.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/22/25.
//

import UIKit

final class HomeTabBarController: BaseTabBarController {
    
    private let coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func setupTabs() {
        super.setupTabs()
        
        
        let mainNav = self.createNav(with: "Home", and: UIImage(systemName: "house"), vc: MainViewBuilder(coordinator: coordinator).build())
        
        let favoritesNav = self.createNav(with: "Favorites", and: UIImage(systemName: "bookmark"), vc: FavoritesBuilder(coordinator: coordinator).build())
        
        self.setViewControllers([mainNav, favoritesNav], animated: true)
        
//        let main = MainViewBuilder(coordinator: coordinator).build()
//        main.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

//        let favorites = FavoritesBuilder(coordinator: coordinator).build()
//        favorites.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "bookmark"), tag: 1)
        
//        self.setViewControllers([main, favorites], animated: true)
    }
}
