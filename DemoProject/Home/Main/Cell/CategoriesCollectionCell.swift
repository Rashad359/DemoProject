//
//  CategoriesCollectionCell.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/20/25.
//

import UIKit
import SnapKit

final class CategoriesCollectionCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Test Category"
        label.textColor = UIColor.categoryText
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return label
    }()
    
    private let chevronImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.chevronDown
        image.tintColor = .categoryText
        
        return image
    }()
    
    private let mainStackView: BaseHorizontalStackView = {
        let stackView = BaseHorizontalStackView()
        stackView.spacing = 2
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupContextMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = .white
        
        layer.cornerRadius = 15
        
        contentView.addSubview(mainStackView)
        
        [titleLabel, chevronImage].forEach(mainStackView.addArrangedSubview)
        
        mainStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.leading.equalToSuperview().offset(13)
            make.trailing.equalToSuperview().offset(-2)
        }
        
        chevronImage.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
    
    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
    }
    
}

extension CategoriesCollectionCell {
    nonisolated struct Item: Hashable, Equatable {
        let id = UUID()
        var title: String
    }
    
    func configure(item: Item) {
        titleLabel.text = item.title
    }
}

extension CategoriesCollectionCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let favorite = UIAction(title: "favorites", image: UIImage(systemName: "heart")) { _ in
                print("Favorite tapped")
            }
            
            let share = UIAction(title: "share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                print("share Tapped")
            }
            
            return UIMenu(title: "", children: [favorite, share])
        }
    }
}
