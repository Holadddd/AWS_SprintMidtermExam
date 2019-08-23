//
//  MJRefreshWrapper.swift
//  AWS_SprintMidtermExam
//
//  Created by wu1221 on 2019/8/23.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import MJRefresh

extension UITableView {
    
    func addRefreshHeader(refreshingBlock: @escaping () -> Void) {
        
        mj_header = MJRefreshNormalHeader(refreshingBlock: refreshingBlock)
    }
    
    func endHeaderRefreshing() {
        
        mj_header.endRefreshing()
    }
    
    func beginHeaderRefreshing() {
        
        mj_header.beginRefreshing()
    }
    
    func addRefreshFooter(refreshingBlock: @escaping () -> Void) {
        
        mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: refreshingBlock)
    }
    
    func endFooterRefreshing() {
        
        mj_footer.endRefreshing()
    }
    
    func endWithNoMoreData() {
        
        mj_footer.endRefreshingWithNoMoreData()
    }
    
    func resetNoMoreData() {
        
        mj_footer.resetNoMoreData()
    }
}
