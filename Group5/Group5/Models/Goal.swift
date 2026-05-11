//
//  Goal.swift
//  Group5
//
//  Created by Eden Fernando on 6/5/2026.
//

import Foundation
import SwiftUI

// goal model
struct GoalData: Codable, Identifiable {
    var id = UUID()
    var name: String = ""
    var icon: String = "target"
    var amount: Double = 0.0
}
