//
//  CreateGoal.swift
//  Group5
//
//  Created by Eden Fernando on 7/5/2026.
//

import Foundation
import SwiftUI


struct GoalView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 1
    @State private var goal = GoalData()
    @Binding var isPresented: Bool
    @State private var amountString: String = ""
    @FocusState private var isTextFieldFocused: Bool

    
    
    let icons = ExpenseCategory.allCases.map { $0.icon }

    var isButtonDisabled: Bool {
        if currentStep == 1 {
            return goal.name.trimmingCharacters(in: .whitespaces).isEmpty
        } else if currentStep == 3 {
            return goal.amount <= 0
        }
        return false 
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Header with Close Button
            HStack {
                Spacer()
                
                Button {
                    withAnimation { isPresented = false }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.title2)
                        .padding(8)
                }
                
            }
            .padding()

            if currentStep == 1 {
                stepOne // Name slide
            } else if currentStep == 2 {
                stepTwo // Icon slide
            } else {
                stepThree // Amount slide
            }
            
            Spacer()
            HStack{
                if currentStep > 1 {
                    Button(action: {
                        withAnimation { currentStep -= 1 }
                    }) {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 28, height: 28)
                                
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            Text("Back")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 10)
                        .padding(.leading, 8)
                        .padding(.trailing, 24)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                    }
                }

                Spacer()
                
                Button(action: {
                    if currentStep < 3 {
                        withAnimation { currentStep += 1 }
                    } else {
                        withAnimation { isPresented = false }
                        saveGoalToUserDefaults(newGoal: goal)
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentStep == 3 ? "Done" : "Next")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        // The white circle with chevron
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 24)  // More padding on the left for the text
                    .padding(.trailing, 8)  // Less on the right because the circle has its own padding
                    .background(Color(red: 255/255, green: 185/255, blue: 135/255)) // The peach color
                    .clipShape(Capsule()) // This gives it the perfectly round ends shown in your image
                    
                }
                .disabled(isButtonDisabled)
                .opacity(isButtonDisabled ? 0.5 : 1.0)

                .padding()
            }
            
        }
        .onAppear {
            // Focus automatically when the view opens (Slide 1)
            isTextFieldFocused = true
        }
        .onChange(of: currentStep) { oldStep, newStep in
            if newStep == 1 || newStep == 3 {
                isTextFieldFocused = true
            } else {
                isTextFieldFocused = false
            }
        }
        .padding()
    }

    // SLIDE 1: Name
    var stepOne: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What would you like to name your goal?")
                .font(.title2).bold()
            TextField("Enter name here", text: $goal.name)
                .textFieldStyle(.plain)
                .focused($isTextFieldFocused)
            Divider()
        }
    }

    // SLIDE 2: Icons
    var stepTwo: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Pick an icon").font(.title2).bold()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(icons, id: \.self) { icon in
                    Image(systemName: icon)
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .background(goal.icon == icon ? Color.orange : Color.orange.opacity(0.2))
                        .clipShape(Circle())
                        .onTapGesture { goal.icon = icon }
                }
            }
        }
    }

    // SLIDE 3: Amount
    var stepThree: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How much do you need to save?")
                .font(.title2)
                .bold()
            
            HStack(spacing: 5) {
                // The currency symbol
                Text("$")
                    .font(.title2)
                    .foregroundColor(.gray)
                TextField("Enter amount here", text: $amountString) // <-- Use 'text' instead of 'value'
//                    .keyboardType(.decimalPad)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(.plain)
                    .onChange(of: amountString) { oldValue, newValue in
                        // This logic now correctly controls the text box
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        
                        if filtered.filter({ $0 == "." }).count > 1 {
                            amountString = String(filtered.dropLast())
                        } else {
                            amountString = filtered
                        }
                        
                        // This updates your number for the logic/saving
                        goal.amount = Double(amountString) ?? 0.0
                    }
            }
            Divider()
        }
    }
}
