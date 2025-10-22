//
//  UserDefaultsManager.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/21/25.
//

import UIKit

final class UserDefaultsManager {
    
    private let userdefaults: UserDefaults
    
    init() {
        userdefaults = UserDefaults.standard
    }
    
    private var currentKey = "key"
    private var bookmarkKey = "bookmark"
    
    func saveBookmark(isBookmarked: Bool) {
        userdefaults.set(isBookmarked, forKey: bookmarkKey)
    }
    
    func getBookmark() -> Bool {
        userdefaults.bool(forKey: bookmarkKey)
    }
    
    func saveState(list: [ProfileCollectionCell.Item]) {
        if let encodedData = try? JSONEncoder().encode(list) {
            userdefaults.set(encodedData, forKey: currentKey)
            userdefaults.synchronize()
        }
    }
    
    func getState() -> [ProfileCollectionCell.Item] {
        if let data = userdefaults.object(forKey: currentKey) as? Data {
            if let decodedData = try? JSONDecoder().decode([ProfileCollectionCell.Item].self, from: data) {
                return decodedData
            }
        }
        return []
    }
}
