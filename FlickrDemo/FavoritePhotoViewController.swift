//
//  FavoritePhotoViewController.swift
//  FlickrDemo
//
//  Created by XYZ on 2020/6/1.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit
import CoreData

class FavoritePhotoViewController: UIViewController {

    @IBOutlet weak var favPhotoCollectionView: UICollectionView!
    
    private let cellId = "photoCell"
    
    lazy var coreDataHelper: PhotoCoreDataHelper = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return PhotoCoreDataHelper(context: context)
    }()
    lazy var noFavLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "找不到已收藏的照片"
        lb.textColor = .black
        return lb
    }()
    
    var favPhotos = [NSManagedObject]()
            
// MARK: - View Cycle Life
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFavoritePhotos()
    }
    
// MARK: - UI Functions
    
    fileprivate func setupUI() {
        
        favPhotoCollectionView.delegate   = self
        favPhotoCollectionView.dataSource = self
        
        registerCell()
    }

    fileprivate func registerCell() {
        let cellNib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
        favPhotoCollectionView.register(cellNib, forCellWithReuseIdentifier: "photoCell")
    }
    
    fileprivate func setupNoFavLabel() {
        
        view.addSubview(noFavLabel)
        noFavLabel.centerXAnchor.constraint(equalTo: favPhotoCollectionView.centerXAnchor).isActive = true
        noFavLabel.centerYAnchor.constraint(equalTo: favPhotoCollectionView.centerYAnchor).isActive = true
    }
    
// MARK: - CoreData
    
    fileprivate func getFavoritePhotos() {
        
        if let favs = coreDataHelper.getFavoritePhotos() {
            favPhotos = favs
        }
        
        if favPhotos.count <= 0 {
            setupNoFavLabel()
        }
    }
}


// MARK: - CollectionView

extension FavoritePhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("Cell init error")
        }
        
        let title   = favPhotos[indexPath.row].value(forKey: "title") as! String
        let imgData = favPhotos[indexPath.row].value(forKey: "image") as! Data
        
        cell.configFavoriteCell(title: title,
                                img: UIImage(data: imgData))
        
        return cell
    }
}

private let cellLabelViewHeight: CGFloat = 50

extension FavoritePhotoViewController: UICollectionViewDelegateFlowLayout {
        
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
}
