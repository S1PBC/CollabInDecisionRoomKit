//
//  CORMessage.swift
//
//  Created by Ella Isgar on 5/6/26.
//

import Foundation

struct CORMessage: Identifiable {
    let id = UUID()
    let timestamp: Date
    let text: String
    let category: MessageCategory
    
    enum MessageCategory {
        case info, success, warning, error
    }
    
    init(_ text: String, category: MessageCategory = .info) {
        self.timestamp = Date()
        self.text = text
        self.category = category
    }
}
