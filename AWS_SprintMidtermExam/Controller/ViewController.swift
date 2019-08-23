//
//  ViewController.swift
//  AWS_SprintMidtermExam
//
//  Created by wu1221 on 2019/8/23.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var scrollView: UIScrollView!
    
    var refreshControl: UIRefreshControl!
    
    let imageView = UIImageView()
    
    let width = UIScreen.main.bounds.width
    
    var playListArr:[PlayListWithCollection] = [] {
        didSet {
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetup()
        api()
    }


}
extension ViewController {
    
    func tableViewSetup() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //refreshControl
//        refreshControl = UIRefreshControl()
//        self.refreshControl.addTarget(self, action: #selector(ViewController.refresh), for: UIControlEvents.valueChanged)
//        refreshControl.attributedTitle = NSAttributedString(string: "重新整理中...")
//        tableView?.addSubview(self.refreshControl)
        
        //ScrollView
        scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        scrollView.contentSize = CGSize(width: width, height: width)
        scrollView.bouncesZoom = true
        scrollView.delegate = self
        
        //headerView
        
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        imageView.image = UIImage(named: "MidtermCover")
        scrollView.addSubview(imageView)
        
        tableView.tableHeaderView = scrollView
    }
    
    
}

extension ViewController: UITableViewDelegate {
    
    
}

extension ViewController: UITableViewDataSource, SwitchMyCollection {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = playListArr[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListTableViewCell") as? PlayListTableViewCell else { fatalError() }
        let albumImageUrl = URL(string: info.playList.album.images[0].url)
        cell.albumImage.kf.setImage(with: albumImageUrl)
       
        cell.albumNameLabel.text = info.playList.name
        
        switch info.collection {
        case true:
            cell.collectionButton.setImage(UIImage(named: "heartTrue"), for: .normal)
        case false:
            cell.collectionButton.setImage(UIImage(named: "heartFalse"), for: .normal)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func collectionSwitch(_ cell: PlayListTableViewCell) {
        print(collectionSwitch)

        guard let indexPath = tableView.indexPath(for: cell) else { fatalError() }
        print(indexPath)
        let data = playListArr[indexPath.row]
        
        playListArr[indexPath.row].collection = !(data.collection)
        
        tableView.reloadData()
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
            
            playListArr += info.data.map { (PlayList) -> PlayListWithCollection in
                PlayListWithCollection(playList: PlayList, collection: false)
            }
            
        } catch {
            print(error)
        }
    }
    
}


