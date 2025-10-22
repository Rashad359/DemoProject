//
//  Fonts.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/20/25.
//

enum Fonts {
    case irishGrover
    case irishGroverRegular
    
    var fontName: String {
        switch self {
        case .irishGrover:
            return "Irish Grover"
        case .irishGroverRegular:
            return "IrishGrover-Regular"
        }
    }
}
