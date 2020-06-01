//
//  ImageDownloadTask.swift
//  FlickrDemo
//
//  Created by Finn on 2020/5/29.
//  Copyright © 2020 Finn. All rights reserved.
//

import Foundation

import UIKit


// Image Download Task
protocol ImgDownloadDelegate {
    func updateLoadedImg(indexRow:Int)
}

class ImgDownloadTask {
    
    let webservice = WebService()
    var url: URL?
    let indexRow: Int
    var loadedImg: UIImage?
    let delegate: ImgDownloadDelegate?
    
    init(url:URL?, indexRow:Int, imgDelegate:ImgDownloadDelegate) {
        self.url = url
        self.indexRow = indexRow
        self.delegate = imgDelegate
    }
    
    func startDownloadImg() {

        guard let okUrl = url else { return }
        
        webservice.downloadImg(url: okUrl) { (isSuccess, loadedImg) in
            if isSuccess {
                self.loadedImg = loadedImg
                self.delegate?.updateLoadedImg(indexRow: self.indexRow)
            }
        }
    }
}
