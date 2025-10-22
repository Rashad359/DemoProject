//
//  ProfileCollectionCell.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/20/25.
//

import UIKit
import SnapKit
import Kingfisher

final class ProfileCollectionCell: UICollectionViewCell {
    
    enum Gender {
        case male
        case female
    }
    
    private let profileImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "profile")
        image.layer.cornerRadius = 20
        image.clipsToBounds = true
        
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rick Sanches"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Human"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return label
    }()
    
    private let mainStackView: BaseVerticalStackView = {
        let stackView = BaseVerticalStackView()
        stackView.spacing = 5
        stackView.alignment = .center
        
        return stackView
    }()
    
    private let bookmark: UIImageView = {
        let image = UIImageView()
        image.image = .bookmarkFill.withRenderingMode(.alwaysTemplate)
        image.tintColor = .greenMid
        
        return image
    }()
    
    private lazy var statusView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        return view
    }()
    
    private let imageStackView: BaseHorizontalStackView = {
        let stackView = BaseHorizontalStackView()
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private let statusSymbol: UIImageView = {
        let image = UIImageView()
        image.image = .checkmark
        
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        contentView.addSubview(mainStackView)
        
        [profileImage, titleLabel, subtitleLabel].forEach(mainStackView.addArrangedSubview)
        
        [bookmark, statusView].forEach(profileImage.addSubview)
        
        statusView.addSubview(statusSymbol)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        statusView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-8)
            make.size.equalTo(30)
        }
        
        bookmark.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17)
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(21)
            make.height.equalTo(25)
        }
        
        statusSymbol.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        profileImage.snp.makeConstraints { make in
            make.width.equalTo(160)
            make.height.equalTo(154)
        }
    }
    
    private func makeGradient(start startColor: CGColor, mid midColor: CGColor, end endColor: CGColor, to view: UIView) {
        
        view.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        
        let gradient = CAGradientLayer()
        
        gradient.colors = [startColor, midColor, endColor]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        view.layer.insertSublayer(gradient, at: 0)
    }
}

extension ProfileCollectionCell {
    nonisolated struct Item: Hashable, Equatable, Codable {
        var id = UUID()
        let profileName: String
        let profileSpecies: String
        let status: String
        let gender: String
        let imageUrl: String
        let type: String
        let origin: String
        var isBookmarked: Bool
    }
    
    func configure(item: Item) {
        titleLabel.text = item.profileName
        subtitleLabel.text = item.profileSpecies
        bookmark.isHidden = !item.isBookmarked
        profileImage.kf.setImage(with: URL(string: item.imageUrl))
        
        switch item.status {
        case "Alive":
            
            DispatchQueue.main.async {
                self.makeGradient(start: UIColor.greenTop.cgColor, mid: UIColor.greenMid.cgColor, end: UIColor.greenBot.cgColor, to: self.statusView)
            }
            
            if item.gender == "Male" {
                statusSymbol.image = .maleIcon
            } else {
                statusSymbol.image = .femaleIcon
            }
            
        case "Dead":
            
            DispatchQueue.main.async {
                self.makeGradient(start: UIColor.redTop.cgColor, mid: UIColor.redMid.cgColor, end: UIColor.redBot.cgColor, to: self.statusView)
            }
            
            statusSymbol.image = .circle
            
        case "unknown":
            
            DispatchQueue.main.async {
                self.makeGradient(start: UIColor.grayTop.cgColor, mid: UIColor.grayMid.cgColor, end: UIColor.grayBot.cgColor, to: self.statusView)
            }
            
            statusSymbol.image = .questionmark
            
        default:
            
            print("Something is wrong")
            
        }
        
        
    }
}
