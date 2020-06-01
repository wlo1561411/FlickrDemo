//
//  PhotoCollectionViewCell.swift
//  FlickrDemo
//
//  Created by Finn on 2020/5/30.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgTitleLabel: UILabel!
    
    lazy var cellAI: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        ai.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.startAnimating()
        return ai
    }()
    lazy var addBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("收藏", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        btn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        return btn
    }()
    lazy var coreDataHelper: PhotoCoreDataHelper = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return PhotoCoreDataHelper(context: context)
    }()
        
// MARK: - Cell initialize
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setupUI()
    }
    
// MARK: - UI Functions
    
    fileprivate func setupUI() {
        // Initialization code
        
        imgView.contentMode = .scaleAspectFill
        
        self.addSubview(cellAI)
        cellAI.centerYAnchor.constraint(equalTo: imgView.centerYAnchor).isActive = true
        cellAI.centerXAnchor.constraint(equalTo: imgView.centerXAnchor).isActive = true
        
        self.addSubview(addBtn)
        addBtn.rightAnchor.constraint (equalTo: imgView.rightAnchor,  constant: -5).isActive = true
        addBtn.bottomAnchor.constraint(equalTo: imgView.bottomAnchor, constant: -5).isActive = true
        addBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        addBtn.widthAnchor.constraint (equalToConstant: 45).isActive = true
        addBtn.addTarget(self, action: #selector(addBtnAction), for: .touchUpInside)
    }

    func configResultCell(title:String?, imgTask:ImgDownloadTask?) {
        
        imgTitleLabel.text = title
        imgView.image      = nil
        addBtn.isHidden    = false
        cellAI.isHidden    = false
        
        configImgView(imgTask: imgTask)
    }
    
    func configFavoriteCell(title:String?, img:UIImage?) {
        
        imgTitleLabel.text = title
        imgView.image      = img
        addBtn.isHidden    = true
        cellAI.isHidden    = true
    }
    
    fileprivate func configImgView(imgTask:ImgDownloadTask?) {
        
        guard let okImgTask = imgTask else { return }
        
        if okImgTask.webservice.isFinish {
            cellAI.stopAnimating()
            imgView.image = okImgTask.loadedImg
        } else {
            cellAI.startAnimating()
        }
    }
    
// MARK: - Button Actions

    @objc func addBtnAction() {
        
        guard let okTitle = imgTitleLabel.text else { return }
        guard let okImg   = imgView.image      else { return }

        if coreDataHelper.insertPhoto(photoTitle: okTitle,
                                      photoImg: okImg) {
            print("Add favorite success")
        }
    }
    
}
