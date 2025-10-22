//
//  DetailsViewController.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/21/25.
//

import UIKit
import SnapKit
import Kingfisher

final class DetailsViewController: BaseViewController {
    
    private let viewModel: DetailsViewModel
    
    private let detailsData: DetailsData
    
    var didBookmark: (() -> ())? = nil
    
    private lazy var list = viewModel.getState()
    
    init(viewModel: DetailsViewModel, detailsData: DetailsData) {
        self.viewModel = viewModel
        self.detailsData = detailsData
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rick Sanchez"
        label.font = UIFont(name: Fonts.irishGroverRegular.fontName, size: 44)
        label.textColor = .white
        label.numberOfLines = .zero
        label.textAlignment = .center
        
        return label
    }()
    
    private let profileImage: UIImageView = {
        let image = UIImageView()
        image.image = .rick
        image.layer.cornerRadius = 20
        image.layer.masksToBounds = true
        
        return image
    }()
    
    private let genderPrompt: UILabel = {
        let label = UILabel()
        label.text = "Gender: "
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        
        return label
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "Male"
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private let genderStackView: BaseHorizontalStackView = {
        let stackView = BaseHorizontalStackView()
        
        return stackView
    }()
    
    private let statusPrompt: UILabel = {
        let label = UILabel()
        label.text = "Status: "
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Alive"
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private let statusStackView: BaseHorizontalStackView = {
        let stackView = BaseHorizontalStackView()
        
        return stackView
    }()
    
    private let speciesPrompt: UILabel = {
        let label = UILabel()
        label.text = "Species: "
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        
        return label
    }()
    
    private let speciesLabel: UILabel = {
        let label = UILabel()
        label.text = "Human"
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private let speciesStackView: BaseHorizontalStackView = {
        let stackView = BaseHorizontalStackView()
        
        return stackView
    }()
    
    private let typePrompt: UILabel = {
        let label = UILabel()
        label.text = "Type: "
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Person-person"
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private let typeStackView: BaseHorizontalStackView = {
        let stackView = BaseHorizontalStackView()
        
        return stackView
    }()
    
    private let originPrompt: UILabel = {
        let label = UILabel()
        label.text = "Origin: "
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        
        return label
    }()
    
    private let originLabel: UILabel = {
        let label = UILabel()
        label.text = "C-137"
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.numberOfLines = .zero
        
        return label
    }()
    
    private let originStackView: BaseHorizontalStackView = {
        let stackView = BaseHorizontalStackView()
        
        return stackView
    }()
    
    private let textStackView: BaseVerticalStackView = {
        let stackView = BaseVerticalStackView()
        stackView.spacing = 14
        stackView.alignment = .leading
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func setupUI() {
        super.setupUI()
        
        [titleLabel, profileImage, textStackView].forEach(view.addSubview)
        
        [genderStackView, statusStackView, speciesStackView, typeStackView, originStackView].forEach(textStackView.addArrangedSubview)
        
        [genderPrompt, genderLabel].forEach(genderStackView.addArrangedSubview)
        [statusPrompt, statusLabel].forEach(statusStackView.addArrangedSubview)
        [speciesPrompt, speciesLabel].forEach(speciesStackView.addArrangedSubview)
        [typePrompt, typeLabel].forEach(typeStackView.addArrangedSubview)
        [originPrompt, originLabel].forEach(originStackView.addArrangedSubview)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.horizontalEdges.equalToSuperview().inset(60)
        }
        
        profileImage.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(23)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(329)
            make.width.equalTo(361)
        }
        
        textStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(51)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-39)
        }
        
    }
    
    private func updateData() {
        titleLabel.text = detailsData.name
        profileImage.kf.setImage(with: URL(string: detailsData.imageUrl))
        genderLabel.text = detailsData.gender
        statusLabel.text = detailsData.status
        speciesLabel.text = detailsData.species
        typeLabel.text = detailsData.type
        originLabel.text = detailsData.origin
    }
    
    private func setupNavigation() {
        let rightBarButton = UIBarButtonItem(image: detailsData.isBookmarked ? .bookmarkFill : .bookmark, style: .plain, target: self, action: #selector(didTapBookmark))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .bookmarkTint
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .backIcon.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didTapBack))
        
        if #available(iOS 26.0, *) {
            navigationItem.rightBarButtonItem?.hidesSharedBackground = true
            navigationItem.leftBarButtonItem?.hidesSharedBackground = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc
    private func didTapBookmark() {
        
        let newList = list.map { item in
            var item = item
            if item.profileName == detailsData.name {
                item.isBookmarked.toggle()
                navigationItem.rightBarButtonItem?.image = item.isBookmarked ? .bookmarkFill : .bookmark
                return item
            } else {
                return item
            }
        }
        
        list = newList
        
        viewModel.saveState(list: list)
        
        list = viewModel.getState()
        
        self.didBookmark?()

        
    }
    
    @objc
    private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
