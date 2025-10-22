//
//  ViewController.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/20/25.
//

import UIKit
import SnapKit

final class MainViewController: BaseViewController {
    
    private let viewModel: MainViewModel
    
    private var index: Int = 0
    private var staleIndex: Int = 0
    
    private var defaultTitle: String = ""
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor deinit {
        searchController.searchResultsUpdater = nil
        collectionView.dataSource = nil
        collectionView.delegate = nil
        print("Goodbye world")
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var items: [CategoriesCollectionCell.Item] = [
        .init(title: "Gender Types"),
        .init(title: "Classifications"),
        .init(title: "Status")
    ]
    
    private var profileItems: [ProfileCollectionCell.Item] = []
    
    private var filteredResult: [ProfileCollectionCell.Item] = []
    
    typealias DiffableDatasource = UICollectionViewDiffableDataSource<SectionType, MyItems>
    
    private var diffableDataSource: DiffableDatasource? = nil
    
    private lazy var searchController: UISearchController = {
        let searchBar = UISearchController()
        searchBar.searchResultsUpdater = self
        
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.register(TitleCell.self, forCellWithReuseIdentifier: TitleCell.identifier)
        collectionView.register(SearchBarCell.self, forCellWithReuseIdentifier: SearchBarCell.identifier)
        collectionView.register(CategoriesCollectionCell.self, forCellWithReuseIdentifier: CategoriesCollectionCell.identifier)
        collectionView.register(ProfileCollectionCell.self, forCellWithReuseIdentifier: ProfileCollectionCell.identifier)
        collectionView.dataSource = self.diffableDataSource
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.printData()
        viewModel.subscribe(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileItems = viewModel.getList()
        applySnapshot(categories: items, profiles: profileItems)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func setupUI() {
        super.setupUI()
        
        [collectionView].forEach(view.addSubview)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        createDiffableDataSource()
        
    }
    
    private func createDiffableDataSource() {
        
        diffableDataSource = DiffableDatasource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .titleSection:
                
                let cell: TitleCell = collectionView.dequeueCell(for: indexPath)
                
                return cell
                
            case .searchSection:
                
                let cell: SearchBarCell = collectionView.dequeueCell(for: indexPath)
                cell.searchComplete = { text in
                    
                    guard let searchText = text?.trimmingCharacters(in: .whitespaces),
                          !searchText.isEmpty else { self.applySnapshot(categories: self.items, profiles: self.profileItems); return }
                    
                    self.filteredResult = self.profileItems.filter { $0.profileName.localizedStandardContains(searchText.lowercased())}
            
                    if searchText.isEmpty {
                        self.filteredResult = self.profileItems
                    } else {
                        self.filteredResult = self.profileItems.filter { $0.profileName.localizedStandardContains(searchText.lowercased())}
                    }
            
                    self.applySnapshot(categories: self.items, profiles: self.filteredResult)
                }
                
                cell.beginSearch = { searchText in
                    guard let text = searchText,
                          !text.isEmpty else { self.applySnapshot(categories: self.items, profiles: self.profileItems); return }
                }
                
                return cell
                
            case .firstSection(let categoryData):
                
                let cell: CategoriesCollectionCell = collectionView.dequeueCell(for: indexPath)
                cell.configure(item: categoryData)
                
                return cell
                
            case .secondSection(let profileData):
                
                let cell: ProfileCollectionCell = collectionView.dequeueCell(for: indexPath)
                cell.configure(item: profileData)
                self.index = indexPath.row
                
                return cell
            }
        })
    }
    
    private func applySnapshot(categories: [CategoriesCollectionCell.Item], profiles: [ProfileCollectionCell.Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, MyItems>()
        snapshot.appendSections([.title, .search, .categories, .profiles])
        
        snapshot.appendItems([.titleSection], toSection: .title)
        snapshot.appendItems([.searchSection], toSection: .search)
        snapshot.appendItems(categories.map { .firstSection($0) }, toSection: .categories)
        snapshot.appendItems(profiles.map { .secondSection($0) }, toSection: .profiles)
        
        DispatchQueue.main.async { [weak self] in
            self?.diffableDataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            if sectionIndex == 0 {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(500), heightDimension: .estimated(130))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(self.collectionView.frame.width), heightDimension: .estimated(130))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 10, leading: 23, bottom: 10, trailing: 10)
                section.orthogonalScrollingBehavior = .none
                
                return section
                
            } else if sectionIndex == 1 {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(self.collectionView.frame.width - 20), heightDimension: .estimated(48))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(48))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 14, leading: 0, bottom: 15, trailing: 0)
                section.orthogonalScrollingBehavior = .none
                
                return section
                
            } else if sectionIndex == 2 {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(151), heightDimension: .absolute(28))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(151), heightDimension: .estimated(20))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 10, leading: 10, bottom: 0, trailing: 10)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 9
                
                return section
                
            } else {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute((self.collectionView.frame.width / 2) - 8), heightDimension: .absolute(200))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(self.collectionView.frame.width), heightDimension: .absolute(240))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 38, leading: 10, bottom: 0, trailing: 10)
                section.orthogonalScrollingBehavior = .none
                
                return section
                
            }
        }
    }
    
    private func showMenu(for category: CategoriesCollectionCell.Item, at indexPath: IndexPath) {
        
        let alert = UIAlertController(title: category.title, message: nil, preferredStyle: .actionSheet)
        
        switch category.title {
        case "Gender Types":
            
            let male = UIAlertAction(title: "Male", style: .default) { _ in
                var updatedCategory = category
                self.defaultTitle = updatedCategory.title
                updatedCategory.title = "Male"
                self.items[indexPath.row] = updatedCategory
                
                let updatedProfile = self.profileItems.filter { $0.gender == "Male" }
                
                self.applySnapshot(categories: self.items, profiles: updatedProfile)
            }
            
            let female = UIAlertAction(title: "Female", style: .default) { _ in
                var updatedCategory = category
                self.defaultTitle = updatedCategory.title
                updatedCategory.title = "Female"
                self.items[indexPath.row] = updatedCategory
                
                let updatedProfile = self.profileItems.filter { $0.gender == "Female" }
                
                self.applySnapshot(categories: self.items, profiles: updatedProfile)
            }
            
            let genderless = UIAlertAction(title: "Genderless", style: .default) { _ in
                var updatedCategory = category
                self.defaultTitle = updatedCategory.title
                updatedCategory.title = "Genderless"
                self.items[indexPath.row] = updatedCategory
                
                let updatedProfile = self.profileItems.filter { $0.gender == "Genderless" }
                
                self.applySnapshot(categories: self.items, profiles: updatedProfile)
            }
            
            let unknown = UIAlertAction(title: "Unknown", style: .default) { _ in
                var updatedCategory = category
                self.defaultTitle = updatedCategory.title
                updatedCategory.title = "Unknown"
                self.items[indexPath.row] = updatedCategory
                
                let updatedProfile = self.profileItems.filter { $0.gender == "Unknown" }
                
                self.applySnapshot(categories: self.items, profiles: updatedProfile)
            }
            
            [male, female, genderless, unknown].forEach(alert.addAction)
            
        case "Classifications":
            
            let human = UIAlertAction(title: "Human", style: .default) { _ in
                var updatedCategory = category
                self.defaultTitle = updatedCategory.title
                updatedCategory.title = "Human"
                self.items[indexPath.row] = updatedCategory
                
                let updatedProfile = self.profileItems.filter { $0.profileSpecies == "Human" }
                
                self.applySnapshot(categories: self.items, profiles: updatedProfile)
            }
            
            let alien = UIAlertAction(title: "Alien", style: .default) { _ in
                var updatedCategory = category
                self.defaultTitle = updatedCategory.title
                updatedCategory.title = "Alien"
                self.items[indexPath.row] = updatedCategory
                
                let updatedProfile = self.profileItems.filter { $0.profileSpecies == "Alien" }
                
                self.applySnapshot(categories: self.items, profiles: updatedProfile)
            }
            
            [human, alien].forEach(alert.addAction)
            
        case "Status":
            
            let alive = UIAlertAction(title: "Alive", style: .default) { _ in
                var updatedCategory = category
                self.defaultTitle = updatedCategory.title
                updatedCategory.title = "Alive"
                self.items[indexPath.row] = updatedCategory
                
                let updatedProfile = self.profileItems.filter { $0.status == "Alive" }
                
                self.applySnapshot(categories: self.items, profiles: updatedProfile)
            }
            
            let dead = UIAlertAction(title: "Dead", style: .default) { _ in
                var updatedCategory = category
                self.defaultTitle = updatedCategory.title
                updatedCategory.title = "Dead"
                self.items[indexPath.row] = updatedCategory
                
                let updatedProfile = self.profileItems.filter { $0.status == "Dead" }
                
                self.applySnapshot(categories: self.items, profiles: updatedProfile)
            }
            
            let unknown = UIAlertAction(title: "Unknown", style: .default) { _ in
                var updatedCategory = category
                self.defaultTitle = updatedCategory.title
                updatedCategory.title = "unknown"
                self.items[indexPath.row] = updatedCategory
                
                let updatedProfile = self.profileItems.filter { $0.status == "unknown" }
                
                self.applySnapshot(categories: self.items, profiles: updatedProfile)
            }
            
            [alive, dead, unknown].forEach(alert.addAction)
            
        default:
            
            let cancel = UIAlertAction(title: "Cancel", style: .default) { _ in
                var updatedCategory = category
                updatedCategory.title = self.defaultTitle
                self.items[indexPath.row] = updatedCategory
                
                self.applySnapshot(categories: self.items, profiles: self.profileItems)
            }
            
            [cancel].forEach(alert.addAction)
            
        }
        
        
        if let cell = collectionView.cellForItem(at: indexPath),
           let popover = alert.popoverPresentationController {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }
        
        present(alert, animated: true)
    }
    
    
    
}

nonisolated enum SectionType: Sendable, Hashable {
    case title
    case search
    case categories
    case profiles
}

nonisolated enum MyItems: Equatable, Hashable {
    case titleSection
    case searchSection
    case firstSection(CategoriesCollectionCell.Item)
    case secondSection(ProfileCollectionCell.Item)
}


extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .firstSection(let category):
            
            showMenu(for: category, at: indexPath)
            
        case .secondSection(let profileData):
            
            staleIndex = indexPath.row
            viewModel.goToDetails(
                with: DetailsData(
                    name: profileData.profileName,
                    imageUrl: profileData.imageUrl,
                    gender: profileData.gender,
                    status: profileData.status,
                    species: profileData.profileSpecies,
                    type: profileData.type,
                    origin: profileData.origin,
                    isBookmarked: profileData.isBookmarked,
                    index: indexPath.row
                )
            )
        default:
            return
        }
    }
}

extension MainViewController: MainViewDelegate {
    
    func bookmarked() {
        let updatedList = viewModel.getList()
        profileItems = updatedList
        
        applySnapshot(categories: items, profiles: profileItems)
    }
    
    func didFetchData(with data: [ProfileCollectionCell.Item]) {
        
        profileItems = data
        if viewModel.getList().isEmpty {
            viewModel.saveList(list: profileItems)
        } else {
            print("List already exists")
            profileItems = viewModel.getList()
        }
        applySnapshot(categories: items, profiles: profileItems)
    }
    
    func error(_ error: any Error) {
        
        self.showAlert(with: "Something went wrong", message: error.localizedDescription)
    }
    
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text,
              !searchText.isEmpty else {
            applySnapshot(categories: items, profiles: profileItems)
            return
        }
                filteredResult = self.profileItems.filter { $0.profileName.localizedStandardContains(searchText.lowercased())}
        
                if searchText.isEmpty {
                    filteredResult = self.profileItems
                } else {
                    filteredResult = self.profileItems.filter { $0.profileName.localizedStandardContains(searchText.lowercased())}
                }
        
                applySnapshot(categories: items, profiles: filteredResult)
    }
    
    
}
