//
//  Network.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 13/04/2023.
//

import Foundation
import FirebaseStorage
import CoreData
import RealmSwift

class Network {
    static let shared = Network()
    private let storage = Storage.storage().reference()
    
    enum NetworkError: Error, LocalizedError {
        case urlNotFound
        case responseError
        case failedToSaveData
    }
    
    typealias ModelResult = Result<[Accounts], Error>
    
    func fetchModel(completion: @escaping (ModelResult) -> Void) {
        storage.child("accounts.json").downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(NetworkError.urlNotFound))
                return
            }
            let urlString = url.absoluteString
            
            guard let url = URL(string: urlString) else {
                completion(.failure(NetworkError.urlNotFound))
                return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let httpResponse =  response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    completion(.failure(NetworkError.responseError))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let modelArray = try decoder.decode([Accounts].self, from: data!)
                    let realm = try Realm()
                    try realm.write {
                        for model in modelArray {
                            realm.add(model)
                        }
                    }
                    completion(.success(modelArray))
                    
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        })
    }

    func fetchOperations() async throws -> [OperationsView] {
        storage.child("operations.json").downloadURL(completion: { url, error in
            guard let url = url, error == nil else { return }
            let urlString = url.absoluteString
            UserDefaults.standard.set(urlString, forKey: "urlOperations")
        })

        guard let urlString = UserDefaults.standard.value(forKey: "urlOperations") as? String,
              let url = URL(string: urlString) else { throw NetworkError.urlNotFound }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse =  response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.responseError }
       
        let decoder = JSONDecoder()

        let operations = try decoder.decode([OperationsView].self, from: data)
        
           return operations
        }
        
    }


