import CoreData

//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Kouv on 06/01/2025.
//


@objc(ManagedFeedImage)
internal class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
    @NSManaged var data: Data?

    var local:LocalFeedImage {
        return LocalFeedImage(id: id,description: imageDescription,location: location, url: url)
    }
}
extension ManagedFeedImage {
    static func images(from localFeed:[LocalFeedImage], in context:NSManagedObjectContext)->NSOrderedSet {
        return NSOrderedSet(array: localFeed.map({ local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.location = local.location
            managed.imageDescription = local.description
            managed.url = local.url
            return managed
        }))
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
            let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
            request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 1
            return try context.fetch(request).first
        }
    
    
}
