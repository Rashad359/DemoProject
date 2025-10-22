//
//  UITableViewCell+Ext.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/20/25.
//

import UIKit

extension UITableView {
    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let bareCell = self.dequeueReusableCell(withIdentifier: T.identifier, for: indexPath)
        
        guard let cell = bareCell as? T else { fatalError("Error in dequeueing") }
        return cell
    }
}
