//
//  MainViewModel.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/21/25.
//

import UIKit

protocol MainViewDelegate: AnyObject {
    func error(_ error: Error)
    func didFetchData(with data: [ProfileCollectionCell.Item])
    func didUpdateData(with data: [ProfileCollectionCell.Item])
    func bookmarked()
}

final class MainViewModel {
    
    var items: [CategoriesCollectionCell.Item] = [
        .init(title: "Gender Types", type: .gender),
        .init(title: "Classifications", type: .classification),
        .init(title: "Status", type: .status)
    ]
    
    var profileItems: [ProfileCollectionCell.Item] = []
    
    var filteredResult: [ProfileCollectionCell.Item] = []
    
    private let networkManager = DependencyContainer.shared.networkManager
    
    private let userdefaults = DependencyContainer.shared.userDefaultsManager
    
    private weak var delegate: MainViewDelegate? = nil
    
    private weak var coordinator: AppCoordinator?
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func subscribe(_ delegate: MainViewDelegate) {
        self.delegate = delegate
    }
    
    func goToDetails(with data: DetailsData) {
        coordinator?.navigateToDetails(with: data) { [weak self] in
            self?.delegate?.bookmarked()
        }
    }
    
    func saveList(list: [ProfileCollectionCell.Item]) {
        userdefaults.saveState(list: list)
    }
    
    func getList() -> [ProfileCollectionCell.Item] {
        return userdefaults.getState()
    }
    
    func deleteList() {
        userdefaults.deleteState()
    }
    
    func printData(page: Int) {
        networkManager.fetchData(pageNumber: page) { [weak self] result in
            switch result {
            case .success(let data):
                
                guard let cellData = self?.mapDataToProfile(data) else { return }
                
                self?.delegate?.didFetchData(with: cellData)
                
            case .failure(let error):
                
                self?.delegate?.error(error)
            }
        }
    }
    
    func appendData(with page: Int) {
        networkManager.fetchData(pageNumber: page) { [weak self] result in
            switch result {
            case .success(let data):
                
                guard let cellData = self?.mapDataToProfile(data) else { return }
                
                self?.delegate?.didUpdateData(with: cellData)
                
            case .failure(let error):
                
                self?.delegate?.error(error)
            }
        }
    }
    
    func mapDataToProfile(_ data: NetworkModel) -> [ProfileCollectionCell.Item] {

        return data.results.map { item in
            return ProfileCollectionCell.Item(
                profileName: item.name,
                profileSpecies: item.species,
                status: item.status,
                gender: item.gender,
                imageUrl: item.image,
                type: item.type,
                origin: item.origin.name,
                isBookmarked: false
            )
        }
    }
}
