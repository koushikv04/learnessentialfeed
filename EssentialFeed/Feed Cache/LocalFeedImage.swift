//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Kaushik on 22/08/2024.
//

import Foundation
public struct LocalFeedImage: Equatable, Codable {
    public var id : UUID
    public var description:String?
    public var location:String?
    public var url:URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
