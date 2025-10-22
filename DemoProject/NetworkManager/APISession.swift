//
//  URLSession.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/21/25.
//

import UIKit

protocol APISession {
    func fetchData(completion: @escaping(Result<NetworkModel, Error>) -> Void)
}
