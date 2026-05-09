//
//  GoalProgressCircle.swift
//  Group5
//
//  Created by Eden Fernando on 8/5/2026.
//

import Foundation
import SwiftUI

struct GoalProgressCircle: View {
    var goal: GoalData
    var currentSavings: Double
    
    var progress: CGFloat {
        let percent = currentSavings / goal.amount
        return min(max(percent, 0), 1)
    }
    
    var body: some View {
        ZStack {
            //grey background
            Circle()
                .fill(Color(red: 210/255, green: 210/255, blue: 210/255))
            
            //fill
            GeometryReader { geo in
                VStack {
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(Color(red: 255/255, green: 173/255, blue: 123/255))
                        .frame(height: geo.size.height * progress)
                }
            }
            .clipShape(Circle())
            
            // Solid black icon
            Image(systemName: goal.icon)
                .font(.system(size: 45, weight: .medium))
                .foregroundColor(.black)
        }
    }
}
