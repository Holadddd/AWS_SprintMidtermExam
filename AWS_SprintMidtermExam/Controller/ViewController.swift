//
//  ViewController.swift
//  AWS_SprintMidtermExam
//
//  Created by wu1221 on 2019/8/23.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import Kingfisher
import MJRefresh

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
                self.tableView.endFooterRefreshing()
                self.tableView.endHeaderRefreshing()
                
                self.imageView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.width)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetup()
        api()
        
        self.tableView.addRefreshFooter {
            //loadNextPage
            self.playList(offset: self.playListArr.count)
        }
        self.tableView.addRefreshHeader {
            self.playListArr.removeAll()
            self.playList(offset: 0)
        }
    }
}

extension ViewController {
    
    func tableViewSetup() {
        
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.contentInset = UIEdgeInsets(top: -UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
        tableView.contentInsetAdjustmentBehavior = .never
        
        
        //ScrollView
        scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        scrollView.contentSize = CGSize(width: width, height: width)
        
        scrollView.delegate = self
        
        scrollView.clipsToBounds = false
        //headerView
        
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        imageView.image = UIImage(named: "MidtermCover")
        scrollView.addSubview(imageView)
        
        tableView.tableHeaderView = scrollView
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            cell.alpha = 0.3
            cell.alpha = 1
        }
    }
    
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

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let outOfBounds = tableView.contentOffset.y
        if outOfBounds < 0 {
            imageView.frame = CGRect(origin: CGPoint(x: outOfBounds/2, y: outOfBounds), size: CGSize(width: width - outOfBounds, height: width - outOfBounds))
        }
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
    
    func playList(offset: Int) {
        
        HTTPClient.shared.getPlayList(offset: offset) {[weak self] result in
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
            playList(offset: 0)
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


