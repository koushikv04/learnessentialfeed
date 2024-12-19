//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Kaushik on 07/12/2024.
//
import Foundation

public class CodableFeedStore:FeedStore {

    private struct Cache: Codable {
        var feed: [CodableFeedImage]
        var timeStamp:Date
        
        var localFeed:[LocalFeedImage] {
            return feed.map {$0.local}
        }
    }
    
    private struct CodableFeedImage:Codable {
        private var id : UUID
        private var description:String?
        private var location:String?
        private var url:URL
        
        init(_ image:LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local:LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)queue",qos: .userInitiated,attributes: .concurrent)
    private var storeURL:URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.empty))
            }
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(.found(feed: cache.localFeed, timestamp: cache.timeStamp)))
            } catch {
                completion(.failure(error))
            }
        }
       
        
    }
    
    public func insert(_ cache:(feed:[LocalFeedImage], timestamp: Date), completion: @escaping InsertCompletion) {
        
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let encoded = try! encoder.encode(Cache(feed: cache.feed.map(CodableFeedImage.init), timeStamp: cache.timestamp))
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
       
    }
}
