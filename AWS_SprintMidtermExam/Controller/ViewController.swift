//
//  ViewController.swift
//  AWS_SprintMidtermExam
//
//  Created by wu1221 on 2019/8/23.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var playListArr:[PlayList] = [] {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        api()
    }


}
extension ViewController {
    
    func api() {
        HTTPClient.shared.kkboxAccessToken { [weak self] result in
            switch result {
            case .success(let data):
                print(data)
                self?.parseTokenDate(data: data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func playList() {
        
        HTTPClient.shared.getPlayList {[weak self] result in
            switch result {
            case .success(let data):
                print(data)
                HTTPClient.shared.semaphore.signal()
                self?.parsePlayListData(data: data)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func paginPlayList() {
        
        HTTPClient.shared.getPlayList(offset: playListArr.count) {[weak self] result in
            switch result {
            case .success(let data):
                print(data)
                HTTPClient.shared.semaphore.signal()
                self?.parsePlayListData(data: data)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func parseTokenDate(data: Data) {
        let decoder = JSONDecoder()
        do {
            let info = try decoder.decode(Oauth2Token.self, from: data)
            print(info.access_token)
            HTTPClient.shared.token = info.access_token
            playList()
        } catch {
            print(error)
        }
    }
    
    func parsePlayListData(data: Data) {
        let decoder = JSONDecoder()
        do {
            let info = try decoder.decode(PlayListData.self, from: data)
            print(info.data.count)
//            info.data.map { (PlayList) -> Void in
//                playListArr.append(PlayList)
//            }
            playListArr += info.data
        } catch {
            print(error)
        }
    }
    
}


