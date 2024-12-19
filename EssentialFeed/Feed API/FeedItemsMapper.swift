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

    
    
   private static var ok_200: Int = 200

    internal static func map(_ data:Data, response:HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == ok_200,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}



