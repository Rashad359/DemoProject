//
//  NetworkManager.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/21/25.
//

import UIKit

final class NetworkAdapter: APISession {
    
    func fetchData(completion: @escaping(Result<NetworkModel, Error>) -> Void) {
        let url = URL(string: "https://rickandmortyapi.com/api/character/?page=1")!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("Something went wrong...", error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            if let data {
                do {
                    let info = try JSONDecoder().decode(NetworkModel.self, from: data)
                    completion(.success(info))
                } catch {
                    print("Something went wrong during decoding...", error.localizedDescription)
                    return
                }
            }
        }
        
        task.resume()
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}
