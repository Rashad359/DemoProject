//
//  ViewController.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/20/25.
//

import UIKit
import SnapKit
import ProgressHUD

final class MainViewController: BaseViewController {
    
    private var index: Int = 0
    
    private let viewModel: MainViewModel
    
    private var currentMenuView: UIView?
    
    private var pageCount: Int = 1
    
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
    
//    private var items: [CategoriesCollectionCell.Item] = [
//        .init(title: "Gender Types", type: .gender),
//        .init(title: "Classifications", type: .classification),
//        .init(title: "Status", type: .status)
//    ]
//    
//    private var profileItems: [ProfileCollectionCell.Item] = []
//    
//    private var filteredResult: [ProfileCollectionCell.Item] = []
    
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
        
        viewModel.deleteList()
        viewModel.printData(page: 1)
        viewModel.subscribe(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.profileItems = viewModel.getList()
        applySnapshot(categories: viewModel.items, profiles: viewModel.profileItems)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
    
    private func contextMenu(options: [String], superView: UIView) {
        
        if let menu = currentMenuView {
            menu.removeFromSuperview()
            currentMenuView = nil
            return
        }
        
        currentMenuView?.removeFromSuperview()
        
        let containerView = UIView()
        containerView.backgroundColor = .bookmarkTint
        containerView.layer.cornerRadius = 15
        
        let stackView = BaseVerticalStackView()
        stackView.spacing = 20
        
        let optionsStackView = BaseVerticalStackView()
        optionsStackView.spacing = 2
        
        for option in options {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.text = option
            label.textColor = UIColor.categoryText
            let underline = UIView()
            underline.translatesAutoresizingMaskIntoConstraints = false
            underline.heightAnchor.constraint(equalToConstant: 1).isActive = true
            underline.backgroundColor = UIColor.categoryText
            let tapGesture = TapGestureRecognizerWithInput(target: self, action: #selector(filterByCategory))
            tapGesture.input = option
            label.addGestureRecognizer(tapGesture)
            label.isUserInteractionEnabled = true
            
            [label, underline].forEach(optionsStackView.addArrangedSubview)
            
        }
        
        view.addSubview(containerView)
        
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(optionsStackView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(superView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(superView)
            make.height.greaterThanOrEqualTo(40)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.leading.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().offset(-13)
            make.trailing.equalToSuperview()
        }
        
        currentMenuView = containerView
    }
    
    private func applyCategoryFilter(title: String, keyPath: KeyPath<ProfileCollectionCell.Item, String>) {

        let filteredList = viewModel.profileItems.filter { $0[keyPath: keyPath] == title }
        
        viewModel.items[index].title = title
        viewModel.items[index].isTapped.toggle()
        
        self.applySnapshot(categories: viewModel.items, profiles: filteredList)
    }
    
    @objc
    private func filterByCategory(_ sender: TapGestureRecognizerWithInput) {
        guard let input = sender.input,
              let menu = currentMenuView else { return }
        
        menu.removeFromSuperview()
        currentMenuView = nil
        
        let currentCategory = viewModel.items[index]
        
        let filterConfig: KeyPath<ProfileCollectionCell.Item, String>
        
        switch currentCategory.type {
        case .gender:
            
            filterConfig = \.gender
            
        case .classification:
            
            filterConfig = \.profileSpecies
            
        case .status:
            filterConfig = \.status
        }
        
        applyCategoryFilter(title: input, keyPath: filterConfig)
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
                          !searchText.isEmpty else { self.applySnapshot(categories: self.viewModel.items, profiles: self.viewModel.profileItems); return }
                    
                    self.viewModel.filteredResult = self.viewModel.profileItems.filter { $0.profileName.localizedStandardContains(searchText.lowercased())}
            
                    if searchText.isEmpty {
                        self.viewModel.filteredResult = self.viewModel.profileItems
                    } else {
                        self.viewModel.filteredResult = self.viewModel.profileItems.filter { $0.profileName.localizedStandardContains(searchText.lowercased())}
                    }
            
                    self.applySnapshot(categories: self.viewModel.items, profiles: self.viewModel.filteredResult)
                }
                
                cell.beginSearch = { searchText in
                    guard let text = searchText,
                          !text.isEmpty else { self.applySnapshot(categories: self.viewModel.items, profiles: self.viewModel.profileItems); return }
                }
                
                return cell
                
            case .firstSection(let categoryData):
                
                let cell: CategoriesCollectionCell = collectionView.dequeueCell(for: indexPath)
                let currentIndex = indexPath.row
                cell.configure(item: categoryData)
                cell.menuAppears = {
                    
                    
                    self.index = currentIndex
                    let currentCategory = self.viewModel.items[currentIndex]
                    
                    if currentCategory.title != "Gender Types" &&
                        currentCategory.title != "Classifications" &&
                        currentCategory.title != "Status" {
                        
                        var updatedCategory = currentCategory
                        switch currentCategory.title {
                        case "Male", "Female", "Genderless", "Unknown":
                            updatedCategory.title = "Gender Types"
                        case "Human", "Alien":
                            updatedCategory.title = "Classifications"
                        case "Alive", "Dead":
                            updatedCategory.title = "Status"
                        default:
                            break
                        }
                        
                        updatedCategory.isTapped = false
                        
                        self.viewModel.items[currentIndex] = updatedCategory
                        
                        self.applySnapshot(categories: self.viewModel.items, profiles: self.viewModel.profileItems)
                        return
                    }
                    
                    switch categoryData.type {
                    case .gender:
                        
                        self.contextMenu(options: ["Male", "Female", "Genderless", "Unknown"], superView: cell.contentView)
                        
                    case .classification:
                        
                        self.contextMenu(options: ["Human", "Alien"], superView: cell.contentView)
                        
                    case .status:
                        
                        self.contextMenu(options: ["Alive", "Dead"], superView: cell.contentView)
                        
                    }
                    
                }
                
                return cell
                
            case .secondSection(let profileData):
                
                let cell: ProfileCollectionCell = collectionView.dequeueCell(for: indexPath)
                cell.configure(item: profileData)
                
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
        case .firstSection(_):
            
            return
            
        case .secondSection(let profileData):
            
            viewModel.goToDetails(
                with: DetailsData(
                    name: profileData.profileName,
                    imageUrl: profileData.imageUrl,
                    gender: profileData.gender,
                    status: profileData.status,
                    species: profileData.profileSpecies,
                    type: profileData.type,
                    origin: profileData.origin,
                    isBookmarked: profileData.isBookmarked
                )
            )
        default:
            return
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        guard contentHeight > frameHeight else { return }
        
        if offsetY > contentHeight - frameHeight {
            
            viewModel.appendData(with: pageCount + 1)
            pageCount += 1
            ProgressHUD.animate("Loading...", interaction: false)
        }
    }
}

extension MainViewController: MainViewDelegate {
    
    func didUpdateData(with data: [ProfileCollectionCell.Item]) {
        
        var currentList = viewModel.getList()
        
        let newItems = data.filter { !currentList.contains($0) }
        
        if !newItems.isEmpty {
            currentList.append(contentsOf: newItems)
            viewModel.saveList(list: currentList)
        } else {
            print("no new items")
            return
        }
        
        viewModel.profileItems = currentList
        applySnapshot(categories: viewModel.items, profiles: viewModel.profileItems)
        
        ProgressHUD.dismiss()
    }
    
    func bookmarked() {
        let updatedList = viewModel.getList()
        viewModel.profileItems = updatedList
        
        applySnapshot(categories: viewModel.items, profiles: viewModel.profileItems)
    }
    
    func didFetchData(with data: [ProfileCollectionCell.Item]) {
        
        viewModel.profileItems = data
        if viewModel.getList().isEmpty {
            viewModel.saveList(list: viewModel.profileItems)
        } else {
            print("List already exists")
            viewModel.profileItems = viewModel.getList()
        }
        applySnapshot(categories: viewModel.items, profiles: viewModel.profileItems)
    }
    
    func error(_ error: any Error) {
        
        self.showAlert(with: "Something went wrong", message: error.localizedDescription)
    }
    
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text,
              !searchText.isEmpty else {
            applySnapshot(categories: viewModel.items, profiles: viewModel.profileItems)
            return
        }
        
        viewModel.filteredResult = self.viewModel.profileItems.filter { $0.profileName.localizedStandardContains(searchText.lowercased())}
        
                if searchText.isEmpty {
                    viewModel.filteredResult = self.viewModel.profileItems
                } else {
                    viewModel.filteredResult = self.viewModel.profileItems.filter { $0.profileName.localizedStandardContains(searchText.lowercased())}
                }
        
        applySnapshot(categories: viewModel.items, profiles: viewModel.filteredResult)
    }
    
    
}
