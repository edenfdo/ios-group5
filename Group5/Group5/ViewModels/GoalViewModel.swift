//
//  GoalViewModel.swift
//  Group5
//
//  Created by Eden Fernando on 7/5/2026.
//

import Foundation

func saveGoalToUserDefaults(newGoal: GoalData) {
    // gets existing goals from UserDefaults
    let defaults = UserDefaults.standard
    var currentGoals: [GoalData] = []
    
    if let data = defaults.data(forKey: "SavedGoals") {
        if let decoded = try? JSONDecoder().decode([GoalData].self, from: data) {
            currentGoals = decoded
        }
    }
    
    // adds the new goal
    currentGoals.append(newGoal)
    
    // saves the updated list back to UserDefaults
    if let encoded = try? JSONEncoder().encode(currentGoals) {
        defaults.set(encoded, forKey: "SavedGoals")
    }
}

func updateGoalInUserDefaults(updatedGoal: GoalData) {
    let defaults = UserDefaults.standard
    var currentGoals: [GoalData] = []
    
    //retrieves the existing array from UserDefaults
    if let data = defaults.data(forKey: "SavedGoals") {
        if let decoded = try? JSONDecoder().decode([GoalData].self, from: data) {
            currentGoals = decoded
        }
    }
    
    // finds the index of the goal matching the id and replaces it
    if let index = currentGoals.firstIndex(where: { $0.id == updatedGoal.id }) {
        currentGoals[index] = updatedGoal
    } else {
        // Fallback: If for some reason the ID is missing, append it as a safeguard
        currentGoals.append(updatedGoal)
    }
    
    // saves the updated list back to UserDefaults
    if let encoded = try? JSONEncoder().encode(currentGoals) {
        defaults.set(encoded, forKey: "SavedGoals")
    }
}

