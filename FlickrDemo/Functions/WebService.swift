//
//  WebService.swift
//  FlickrDemo
//
//  Created by Finn on 2020/5/29.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

class WebService {
    
    lazy var session = { return URLSession(configuration: .default)}()
    
    private lazy var apiLink        = "https://api.flickr.com/services/rest/"
    private lazy var apiKey         = "c6aa86f54815fa88a24a8ed550396bd9"
    private lazy var method         = "flickr.photos.search"
    private lazy var format         = "json"
    private lazy var noJsonCallBack = "1"
    
    typealias photosDataCallBack = (Bool, [Photo]?) -> ()
    typealias imageCallBack = (Bool, UIImage?) -> ()
    
    var isDownloading = false
    var isFinish = false
    
    fileprivate func encodeUrl(baseURL:String,params:[String:Any]) -> URL? {

        guard let url = URL(string: baseURL) else { return nil }

        if !params.isEmpty {
            
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                
                components.queryItems = [URLQueryItem]()
                for (key,value) in params {
                    let query = URLQueryItem(name: key, value: "\(value)")
                    components.queryItems?.append(query)
                }

                return components.url
            }
            
            return nil
        }
        
        return nil
    }
    
    /*
     https://www.flickr.com/services/rest/
     ?method=
     &api_key=
     &text=
     &per_page=
     &page=
     &format=json
     &nojsoncallback=1
     */
    func fetchPhotoData(text: String,
                        perPage: Int,
                        page: Int,
                        startPoint: Int,
                        imgDelegate: ImgDownloadDelegate,
                        callBack: @escaping photosDataCallBack) {
        
        let params: [String:Any] = ["method"        : method,
                                    "api_key"       : apiKey,
                                    "text"          : text,
                                    "per_page"      : perPage,
                                    "page"          : page,
                                    "format"        : format,
                                    "nojsoncallback": noJsonCallBack]
        
        guard let encodedURL = encodeUrl(baseURL: apiLink, params: params) else { return }
        var request = URLRequest(url: encodedURL)
        request.httpMethod = "GET"
        
        isDownloading = true
        isFinish = false
        
        let task = session.downloadTask(with: request) { (url, response, error) in
            
            if error != nil {
                print("Fetch photo data error : \(error!.localizedDescription))")
                self.isDownloading = false
                self.isFinish = false
                callBack(false,nil)
            }
            
            if let loadedUrl = url {
                
                do {
                    let data = try Data(contentsOf: loadedUrl)
                    self.isDownloading = false
                    self.isFinish = true
                    callBack(true,self.parsePhotosJson(jsonData: data,
                                                       startPoint: startPoint,
                                                       imgDelegate: imgDelegate))
                } catch  {
                    print("Parse photo data : \(error.localizedDescription)")
                    self.isDownloading = false
                    self.isFinish = false
                    callBack(false,nil)
                }
            }
        }
        
        task.resume()
    }
    
    private func parsePhotosJson(jsonData:Data,
                                 startPoint: Int,
                                 imgDelegate: ImgDownloadDelegate) -> [Photo] {
        
        var loadedPhotos = [Photo]()
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData,
                                                        options: .fragmentsAllowed)
            if let jsonDic = json as? [String:Any] {
                if let photos = jsonDic["photos"] as? [String:Any] {
                    if let photosArray = photos["photo"] as? [[String:Any]] {
                        for i in 0 ..< photosArray.count {
                            let photo = Photo(photoDict: photosArray[i],
                                              indexRow: (i + startPoint),
                                              imgDelegate: imgDelegate)
                            loadedPhotos.append(photo)
                        }
                    }
                }
            }
        } catch  {
            print("Parse JSON error : \(error.localizedDescription)")
        }
        
        return loadedPhotos
    }
    
    func downloadImg(url:URL, callBack:@escaping imageCallBack) {
        
        isDownloading = true
        isFinish = false
        
        let task = session.downloadTask(with: url) { (url, response, err) in
            
            if err != nil {
                print("Download Image Fail, error : \(err!.localizedDescription)")
                self.isDownloading = false
                self.isFinish = false
                callBack(false,nil)
            }
            
            if let okUrl = url {
                
                do {
                    let loadedImg = UIImage(data: try Data(contentsOf: okUrl))
                    self.isDownloading = false
                    self.isFinish = true
                    callBack(true,loadedImg)
                } catch  {
                    print("Convert Image Fail, error : \(error.localizedDescription)")
                    self.isDownloading = false
                    self.isFinish = false
                    callBack(false,nil)
                }
            }
        }
        task.resume()
    }
}
