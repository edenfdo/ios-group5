//
//  ExpenseCategory.swift
//  Group5
//
//  Created by chuyue zhang on 2/5/2026.
//

import Foundation

import SwiftUI

//Created all the categories name and icons
enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case food = "Food"
    case travel = "Travel"
    case fun = "Fun"
    case housing = "Housing"
    case shopping = "Shopping"
    case friends = "Friends"
    case study = "Study"
    case gift = "Gift"
    case transport = "Transport"
    case necessities = "Necessities"
    case medical = "Medical"
    case other = "Other"
    
    var id:String {rawValue}
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .travel: return "airplane.up.right"
        case .fun: return "gamecontroller.fill"
        case .housing: return "house.fill"
        case .shopping: return "cart.fill"
        case .friends: return "person.2.fill"
        case .study: return "studentdesk"
        case .gift: return "gift.fill"
        case .transport: return "bus.fill"
        case .necessities: return "bed.double.fill"
        case .medical: return "cross.case.fill"
        case .other: return "plus.diamond.fill"
        }
    }
    
}
