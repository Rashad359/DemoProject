//
//  TitleCell.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/22/25.
//

import UIKit
import SnapKit

final class TitleCell: BaseCollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rick & Morty"
        label.font = UIFont(name: Fonts.irishGrover.fontName, size: 44)
        label.textColor = .white
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "fandom"
        label.font = UIFont(name: Fonts.irishGrover.fontName, size: 24)
        label.textColor = .white
        
        return label
    }()
    
    private let titleStackView: BaseVerticalStackView = {
        let stackView = BaseVerticalStackView()
        stackView.spacing = 0
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupCell() {
        super.setupCell()
        
        contentView.addSubview(titleStackView)
        
        [titleLabel, subtitleLabel].forEach(titleStackView.addArrangedSubview)
        
        titleStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
}
