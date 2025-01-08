//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Kaushik on 24/07/2024.
//

import Foundation



internal final class FeedItemsMapper {
    private struct Root:Decodable {
        let items:[RemoteFeedItem]
    }

    
    

    internal static func map(_ data:Data, response:HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}



