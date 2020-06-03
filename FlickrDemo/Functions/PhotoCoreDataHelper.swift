//
//  CoreData.swift
//  FlickrDemo
//
//  Created by XYZ on 2020/6/1.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit
import CoreData

class PhotoCoreDataHelper {
    
    var context: NSManagedObjectContext! = nil
    private let photoEntityName = "FavoritePhotos"
    
    init(context:NSManagedObjectContext) {
        self.context = context
    }
    
    // insert
    func insertPhoto(photoTitle: String,
                     photoImg: UIImage) -> Bool {
        
        let insertData = NSEntityDescription.insertNewObject(forEntityName: photoEntityName,
                                                             into: context)
                
        insertData.setValue(photoTitle, forKey: "title")
        insertData.setValue(photoImg.pngData(), forKey: "image")
        insertData.setValue(NSDate.init(timeIntervalSinceNow: 0), forKey: "addTime")
        
        do {
            try context.save()
            return true
        } catch {
            fatalError("Insert photo error \(error)")
        }
    }
    
    // fetch
    func fetchFavoritePhotos() -> [NSManagedObject]? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: photoEntityName)

        request.sortDescriptors = [NSSortDescriptor(key: "addTime", ascending: false)]

        do {
            return try context.fetch(request) as? [NSManagedObject]
        } catch {
            fatalError("get FavoritePhotos error \(error)")
        }
    }

    // delete
    func delete(photo: NSManagedObject?) -> Bool {
        
        if let okPhoto = photo {
            
            context.delete(okPhoto)
            
            do {
                try context.save()
                return true
            } catch {
                fatalError("Delete photo error \(error)")
            }
        }

        return false
    }
}
