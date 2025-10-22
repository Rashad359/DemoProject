//
//  RMModel.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/21/25.
//

import UIKit

nonisolated struct NetworkModel: Decodable {
    let results: [ResultModel]
    
    struct ResultModel: Decodable {
        let id: Int
        let name: String
        let status: String
        let species: String
        let gender: String
        let image: String
        let type: String
        let origin: OriginModel
        
        struct OriginModel: Decodable {
            let name: String
        }
    }
}
