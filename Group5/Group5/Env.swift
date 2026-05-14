//
//  Env.swift
//  Group5
//
//  Created by Eden Fernando on 14/5/2026.
//


import Foundation

enum Env {
    static var apiURL: String {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String else {
            fatalError("API_URL missing from Info.plist")
        }
                
        return urlString
    }
}
