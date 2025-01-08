//
//  HTTPURLResponse+statusCode.swift
//  EssentialFeed
//
//  Created by Kouv on 04/01/2025.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200:Int {return 200}
    
    var isOK:Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
