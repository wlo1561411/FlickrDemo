//
//  Photo.swift
//  FlickrDemo
//
//  Created by Finn on 2020/5/29.
//  Copyright © 2020 Finn. All rights reserved.
//

import Foundation

/*
Size Text:
s 小正方形 75x75
q large square 150x150
t 縮圖，最長邊為 100
m 小，最長邊為 240
n small, 320 on longest side
- 中等，最長邊為 500
z 中等尺寸 640，最長邊為 640
c 中等尺寸 800，最長邊為 800†
b 大尺寸，最長邊為 1024*
h 大型 1600，長邊 1600†
k 大型 2048，長邊 2048†
o 原始圖片, 根據來源格式可以是 jpg、gif 或 png
*/
private let size = "z"

class Photo {
    
    var farm:     Int?
    var server:   String?
    var photoID:  String?
    var secret:   String?
    var title:    String?
    var imgTask:  ImgDownloadTask?
    
    init(photoDict:[String:Any], indexRow:Int, imgDelegate: ImgDownloadDelegate) {
        
        server   = photoDict["server"] as? String
        photoID  = photoDict["id"] as? String
        secret   = photoDict["secret"] as? String
        title    = photoDict["title"] as? String
        farm     = photoDict["farm"] as? Int
        imgTask  = ImgDownloadTask(url: encodePhotoUrl(),
                                   indexRow: indexRow,
                                   imgDelegate: imgDelegate)
    }
    
    /*
     https://farm(farm-id).staticflickr.com/(server-id)/(id)_(secret)_(mstzb).jpg
     farm-id:
     server-id:
     photo-id:
     secret:
     size:
     */
    private func encodePhotoUrl() -> URL? {
        
        guard let okFarm    = farm,
              let okServer  = server,
              let okPhotoID = photoID,
              let okSecret  = secret  else { return nil }
        
        let urlString = "https://farm\(okFarm).staticflickr.com/\(okServer)/\(okPhotoID)_\(okSecret)_\(size).jpg"
        return URL(string: urlString)
    }
}


