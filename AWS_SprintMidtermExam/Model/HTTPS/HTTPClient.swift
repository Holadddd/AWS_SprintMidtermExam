//
//  HTTPClient.swift
//  AWS_SprintMidtermExam
//
//  Created by wu1221 on 2019/8/23.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation

enum Result<T> {
    
    case success(T)
    
    case failure(Error)
}

enum STHTTPClientError: Error {
    
    case decodeDataFail
    
    case clientError(Data)
    
    case serverError
    
    case unexpectedError
}

protocol SwitchMyCollection {
    
    func collectionSwitch(_ cell: PlayListTableViewCell)
    
}

class HTTPClient {
    
    static let shared = HTTPClient()
    
    var token: String? {
        didSet {
            semaphore.signal()
        }
    }
    
    let semaphore = DispatchSemaphore(value: 1)
}

extension HTTPClient {
    
    func kkboxAccessToken (completion: @escaping (Result<Data>) -> Void) {
        
        let grant_type = "client_credentials"
        
        let client_id = "8899eb5903e939401fae0ed0e3825cdc"
        
        let client_secret = "12013f0aef795888fb587dc6cb8fc2b6"
        
        let body = "grant_type=\(grant_type)&client_id=\(client_id)&client_secret=\(client_secret)"
        
        guard let url = URL(string: "https://account.kkbox.com/oauth2/token/\(body)") else { fatalError() }
        print(url)
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.allHTTPHeaderFields = ["Host": "account.kkbox.com",
                                       "Content-Type": "application/x-www-form-urlencoded"]
        
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data,  response, error) in
            self.semaphore.wait()
            guard error == nil else {
                
                return completion(Result.failure(error!))
            }
            // swiftlint:disable force_cast
            let httpResponse = response as! HTTPURLResponse
            // swiftlint:enable force_cast
            let statusCode = httpResponse.statusCode
            
            switch statusCode {
                
            case 200..<300:
                
                completion(Result.success(data!))
                
            case 400..<500:
                
                completion(Result.failure(STHTTPClientError.clientError(data!)))
                
            case 500..<600:
                
                completion(Result.failure(STHTTPClientError.serverError))
                
            default: return
                
                completion(Result.failure(STHTTPClientError.unexpectedError))
            }
            
        }
        task.resume()

        
    }
    
    func getPlayList(offset: Int ,completion: @escaping (Result<Data>) -> Void) {
        
        semaphore.wait()
        
        let play_list = "DZrC8m29ciOFY2JAm3"
        
        let limit = 20
        
        let offset = offset 
        print(offset)
        let territory = "TW"
        
        let query = "v1.1/new-hits-playlists/\(play_list)/tracks?territory=\(territory)&limit=\(limit)&offset=\(offset)"
        
        guard let url = URL(string: "https://account.kkbox.com/\(query)") else { fatalError() }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        guard let token = token else { return }
        
        request.allHTTPHeaderFields = ["Authorization": "Bearer" + " " + "\(token)",
            "Host": "api.kkbox.com",
            "offset": "\(offset)"]
        
        let task = URLSession.shared.dataTask(with: request) { (data,  response, error) in
            
            guard error == nil else {
                
                return completion(Result.failure(error!))
            }
            // swiftlint:disable force_cast
            let httpResponse = response as! HTTPURLResponse
            // swiftlint:enable force_cast
            let statusCode = httpResponse.statusCode
            
            switch statusCode {
                
            case 200..<300:
                
                completion(Result.success(data!))
                
            case 400..<500:
                
                completion(Result.failure(STHTTPClientError.clientError(data!)))
                
            case 500..<600:
                
                completion(Result.failure(STHTTPClientError.serverError))
                
            default: return
                
                completion(Result.failure(STHTTPClientError.unexpectedError))
            }
            
        }
        task.resume()
    }
}

struct Oauth2Token: Codable {
    var access_token: String
    var token_type: String
    var expires_in: Int
    
    enum Codingkeys: String, CodingKey {
        case access_token, token_type, expires_in
    }
}

struct PlayListData: Codable {
    var data: [PlayList]
    enum Codingkeys: String, CodingKey {
        case data
    }
}

struct PlayList: Codable {
    var id: String
    var name: String
    var duration: Int
    var url: String
    var track_number: Int
    var explicitness: Bool
    var available_territories: [String]
    var album: Album
    enum Codingkeys: String, CodingKey {
        case id, name, duration, url, track_number, explicitness, available_territories, album
    }
}

struct Album: Codable {
    var id: String
    var name: String
    var url: String
    var explicitness: Bool
    var available_territories: [String]
    var release_date: String
    var images: [AlbumImage]
    var artist: AlbumArtist
    enum Codingkeys: String, CodingKey {
        case id, name, url, explicitness, available_territories, release_date, images, artist
    }
}

struct AlbumImage: Codable {
    var height: Int
    var width: Int
    var url: String
    enum Codingkeys: String, CodingKey {
        case height, width, url
    }
}

struct AlbumArtist: Codable {
    var id: String
    var name: String
    var url: String
    var images: [AlbumImage]
    enum Codingkeys: String, CodingKey {
        case id, name, url, images
    }
}

struct PlayListWithCollection {
    var playList: PlayList
    var collection: Bool
}
