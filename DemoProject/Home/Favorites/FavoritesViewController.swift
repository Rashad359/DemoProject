//
//  FavoriteViewController.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/22/25.
//

import UIKit
import SnapKit

final class FavoritesViewController: BaseViewController {
    
    private let viewModel: FavoritesViewModel
    
    private lazy var profileItems: [ProfileCollectionCell.Item] = viewModel.getList().filter { item in
        return item.isBookmarked == true
    }
    
    private var filteredResult: [ProfileCollectionCell.Item] = []
    
    typealias DiffableDatasource = UICollectionViewDiffableDataSource<SectionType, MyItems>
    
    private var diffableDataSource: DiffableDatasource? = nil
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.register(TitleCell.self, forCellWithReuseIdentifier: TitleCell.identifier)
        collectionView.register(SearchBarCell.self, forCellWithReuseIdentifier: SearchBarCell.identifier)
        collectionView.register(ProfileCollectionCell.self, forCellWithReuseIdentifier: ProfileCollectionCell.identifier)
        collectionView.dataSource = self.diffableDataSource
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.subscribe(self)
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        createDiffableDataSource()
        applySnapshot(profiles: profileItems)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        profileItems = viewModel.getList().filter({ item in
            return item.isBookmarked == true
        })
        
        applySnapshot(profiles: profileItems)
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
    
    private func applySnapshot(profiles: [ProfileCollectionCell.Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, MyItems>()
        snapshot.appendSections([.title, .search, .profiles])
        
        snapshot.appendItems([.titleSection], toSection: .title)
        snapshot.appendItems([.searchSection], toSection: .search)
        snapshot.appendItems(profiles.map { .secondSection($0) }, toSection: .profiles)
        
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
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
                    
                    guard let searchText = text,
                          !searchText.isEmpty else { self.applySnapshot(profiles: self.profileItems); return }
                    
                    self.filteredResult = self.profileItems.filter { $0.profileName.localizedStandardContains(searchText.lowercased())}
            
                    if searchText.isEmpty {
                        self.filteredResult = self.profileItems
                    } else {
                        self.filteredResult = self.profileItems.filter { $0.profileName.localizedStandardContains(searchText.lowercased())}
                    }
            
                    self.applySnapshot(profiles: self.filteredResult)
                }
                
                return cell
                
            case .secondSection(let profileData):
                
                let cell: ProfileCollectionCell = collectionView.dequeueCell(for: indexPath)
                cell.configure(item: profileData)
                
                return cell
                
            default:
                print("No cell")
                
                return UICollectionViewCell()
            }
        })
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .firstSection(_):
            print("Category typed")
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
                    isBookmarked: profileData.isBookmarked,
                    index: indexPath.row
                )
            )
        default:
            print("Cell tapped")
        }
    }
    
}

extension FavoritesViewController: FavoritesViewDelegate {
    func bookmarked() {
        let updatedList = viewModel.getList().filter { item in
            return item.isBookmarked == true
        }
        profileItems = updatedList
        
        applySnapshot(profiles: profileItems)
    }
}
