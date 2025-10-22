//
//  UICollectionView+Ext.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/20/25.
//

import UIKit

extension UICollectionView {
    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let bareCell = self.dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath)
        
        guard let cell = bareCell as? T else { fatalError("Error in dequeueing collection view cell")}
        return cell
    }
}
