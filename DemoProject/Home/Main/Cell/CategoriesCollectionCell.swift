//
//  CategoriesCollectionCell.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/20/25.
//

import UIKit
import SnapKit

final class CategoriesCollectionCell: UICollectionViewCell {
    
    var menuAppears: (() -> ())? = nil
    
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
        image.contentMode = .scaleAspectFit
        
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = .white
        
        layer.cornerRadius = 15
        
        isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openMenu))
        addGestureRecognizer(tap)
        
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
    
    @objc
    private func openMenu() {
        menuAppears?()
    }
    
}

extension CategoriesCollectionCell {
    nonisolated struct Item: Hashable, Equatable {
        var title: String
        var isTapped: Bool = false
        let type: CategoryType
    }
    
    enum CategoryType {
        case gender
        case classification
        case status
    }
    
    func configure(item: Item) {
        titleLabel.text = item.title
        chevronImage.image = item.isTapped ? .close : UIImage.chevronDown
    }
}
