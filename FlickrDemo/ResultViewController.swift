//
//  ResultViewController.swift
//  FlickrDemo
//
//  Created by Finn on 2020/5/30.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit


class ResultViewController: UIViewController {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    private let cellId = "photoCell"
    
    lazy var webService = { return WebService() }()
    lazy var collectionAI: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        ai.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.startAnimating()
        return ai
    }()
    lazy var noResultLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "找不到相關結果"
        lb.textColor = .black
        return lb
    }()
    
    var photos = [Photo]()
    
    var perPage = 0
    var text    = ""
    var page    = 1
    
// MARK: - View Cycle Life
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        firstFetch()
    }

    
// MARK: - UI Fuctions
    
    fileprivate func setupUI() {
        
        navigationItem.title = text
        
        photoCollectionView.delegate   = self
        photoCollectionView.dataSource = self
        photoCollectionView.isHidden   = true
        
        view.addSubview(collectionAI)
        collectionAI.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        collectionAI.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        registerCell()
    }
    
    fileprivate func registerCell() {
        
        photoCollectionView.register(UICollectionReusableView.self,
                                     forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter,
                                     withReuseIdentifier: "footerView")
        
        let cellNib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
        photoCollectionView.register(cellNib, forCellWithReuseIdentifier: "photoCell")
    }
    
    fileprivate func setupNoResultLable() {
        
        view.addSubview(noResultLabel)
        noResultLabel.centerXAnchor.constraint(equalTo: photoCollectionView.centerXAnchor).isActive = true
        noResultLabel.centerYAnchor.constraint(equalTo: photoCollectionView.centerYAnchor).isActive = true
    }
    
// MARK: - WebService
    
    fileprivate func firstFetch() {

        webService.fetchPhotoData(text: text,
                                  perPage: perPage,
                                  page: page,
                                  startPoint: photos.count,
                                  imgDelegate: self) { (isSuc, photos) in
                                    
            if isSuc {
                
                DispatchQueue.main.async {
                    
                    if let okPhotos = photos {
                        
                        self.collectionAI.stopAnimating()
                        
                        if okPhotos.count > 0 {
                            self.photos = okPhotos
                            self.photoCollectionView.reloadData()
                            self.photoCollectionView.isHidden = false
                        } else {
                            self.setupNoResultLable()
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func updateCollectionView(from: Int, to:Int) {
        
        var insertArr = [IndexPath]()
        for row in from ..< to {
            insertArr.append(IndexPath(item: row, section: 0))
        }
        
        self.photoCollectionView.performBatchUpdates({
            self.photoCollectionView.insertItems(at: insertArr)
        }) { (isFinish) in
            print("Fetch success")
        }
    }
    
    fileprivate func fetchMore() {
        
        if webService.isDownloading {
            print("Fetching......")
            return
        }
        
        page += 1
        
        webService.fetchPhotoData(text: text,
                                  perPage: perPage,
                                  page: page,
                                  startPoint: photos.count,
                                  imgDelegate: self) { (isSuc, photos) in
            if isSuc {
                DispatchQueue.main.async {
                    if let okPhotos = photos {
                        let from = self.photos.count
                        self.photos.append(contentsOf: okPhotos)
                        self.updateCollectionView(from: from, to: self.photos.count)
                    }
                }
            }
        }
    }
    
    fileprivate func readyToDownloadImg(imgTask: ImgDownloadTask?) {
        
        guard let okImgTask = imgTask else { return }
        
        if okImgTask.webservice.isFinish ||
           okImgTask.webservice.isDownloading ||
           okImgTask.loadedImg != nil {
            return
        } else {
            okImgTask.startDownloadImg()
        }
    }
}

// MARK: - CollectionView
extension ResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("Cell init error")
        }
        
        cell.configResultCell(title: photos[indexPath.row].title,
                              imgTask: photos[indexPath.row].imgTask)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        readyToDownloadImg(imgTask: photos[indexPath.row].imgTask)
        
        if indexPath.row >= photos.count - 1 {
            fetchMore()
        }
    }
}

private let cellLabelViewHeight: CGFloat = 50

extension ResultViewController: UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 30 = |-(10)-[cell]-(10)-[cell]-(10)-|
        let width = (collectionView.frame.width - 30) / 2
        return CGSize(width: width,
                      height: width + cellLabelViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        var footer = UICollectionReusableView()

        if kind == UICollectionView.elementKindSectionFooter {
            footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: "footerView",
                                                                     for: indexPath)
            if footer.subviews.count == 0 {
                let ai = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
                ai.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                ai.translatesAutoresizingMaskIntoConstraints = false
                ai.startAnimating()
                footer.addSubview(ai)
                ai.centerXAnchor.constraint(equalTo: footer.centerXAnchor).isActive = true
                ai.centerYAnchor.constraint(equalTo: footer.centerYAnchor).isActive = true
            }
        }

        return footer
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}

// MARK: - ImgDownloadDelegate

extension ResultViewController: ImgDownloadDelegate {
    
    func updateLoadedImg(indexRow: Int) {
        
        DispatchQueue.main.async {
            
            let indexPath = IndexPath(item: indexRow,
                                      section: self.photoCollectionView.numberOfSections - 1)
            
            let isVisable = self.photoCollectionView.indexPathsForVisibleItems.filter({$0 == indexPath}).count == 1 ? true : false
            
            if !isVisable { return }
            
            // cancel reloadCell animation
            UIView.setAnimationsEnabled(false)
            
            self.photoCollectionView.performBatchUpdates({
                self.photoCollectionView.reloadItems(at: [indexPath])
            }) { (finished) in
                UIView.setAnimationsEnabled(true)
            }
        }
    }
}
