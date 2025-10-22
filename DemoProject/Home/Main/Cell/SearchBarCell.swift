//
//  SearchBarCell.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/22/25.
//

import UIKit
import SnapKit

final class SearchBarCell: BaseCollectionViewCell {
    
    var searchComplete: ((String?) -> ())? = nil
    
    var beginSearch: ((String?) -> ())? = nil
    
    private let loopImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        
        return imageView
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search..."
        textField.backgroundColor = .bookmarkTint
        textField.layer.cornerRadius = 15
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(didSearch), for: .editingChanged)
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 20))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 22, height: 20))
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .background
        containerView.addSubview(imageView)
        textField.leftView = containerView
        textField.leftViewMode = .always
        textField.delegate = self
        
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupCell() {
        super.setupCell()
        
        contentView.addSubview(searchTextField)
        
        searchTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(23)
//            make.edges.equalToSuperview()
            make.verticalEdges.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
    }
    
    @objc
    private func didSearch() {
        searchComplete?(searchTextField.text)
    }
}

extension SearchBarCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        beginSearch?(textField.text)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        searchTextField.text = ""
        return true
    }
}
