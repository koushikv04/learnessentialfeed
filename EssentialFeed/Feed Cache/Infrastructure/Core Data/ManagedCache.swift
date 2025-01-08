//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Kouv on 06/01/2025.
//

import CoreData

@objc(ManagedCache)
internal class ManagedCache:NSManagedObject {
    @NSManaged var timeStamp:Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeed:[LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local}
    }
}

extension ManagedCache {
    static func find(in context:NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context:NSManagedObjectContext)throws->ManagedCache {
        try find(in: context).map (context.delete)
        return ManagedCache(context: context)
    }
}


