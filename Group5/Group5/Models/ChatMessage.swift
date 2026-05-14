//
//  ChatMessage.swift
//  Group5
//
//  Created by Eden Fernando on 14/5/2026.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool // True if user sent it, False if Gemini replied
    let timestamp = Date()
}
