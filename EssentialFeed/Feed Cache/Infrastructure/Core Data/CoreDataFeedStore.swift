//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Kouv on 05/01/2025.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
    
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    enum StoreError: Error {
            case modelNotFound
            case failedToLoadPersistentContainer(Error)
        }
    
    public init(storeURL:URL)throws {
        let bundle =  Bundle(for: CoreDataFeedStore.self)
        guard let model = CoreDataFeedStore.model else {
                    throw StoreError.modelNotFound
        }

        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
                    context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    private let container:NSPersistentContainer
    private let context:NSManagedObjectContext
    
    func perform(execute:@escaping(NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            execute(context)
        }
        
    }
    

    
    private func cleanUpReferencesToPersistentStores() {
            context.performAndWait {
                let coordinator = self.container.persistentStoreCoordinator
                try? coordinator.persistentStores.forEach(coordinator.remove)
            }
        }

        deinit {
            cleanUpReferencesToPersistentStores()
        }
    
}


