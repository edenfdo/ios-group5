//
//  CreateGoal.swift
//  Group5
//
//  Created by Eden Fernando on 7/5/2026.
//

import Foundation
import SwiftUI


struct GoalView: View {
    // tracks which step the user is on within the popup
    @State private var currentStep = 1
    
    // stores the goal being created
    @State private var goal: GoalData
    
    // controls whether the goal is displayed or not
    @Binding var isPresented: Bool
    
    //optional parameter passed when editing an existing goal
    private var editingGoal: GoalData?
    
    // temporary string for amount input
    @State private var amountString: String = ""
    
    // controls keyboard/cursor focus
    @FocusState private var isTextFieldFocused: Bool
    
    // allows the view to dismiss itself when used in a navigation stack
    @Environment(\.dismiss) var dismiss

    // creates an array of icon names from all expense categories
    let icons = ExpenseCategory.allCases.map { $0.icon }

    //initializer to handle both creation and editing modes
    init(isPresented: Binding<Bool>, editingGoal: GoalData? = nil) {
        self._isPresented = isPresented
        self.editingGoal = editingGoal
        
        if let existingGoal = editingGoal {
            _goal = State(initialValue: existingGoal)
            _amountString = State(initialValue: existingGoal.amount > 0 ? String(format: "%.2f", existingGoal.amount) : "")
        } else {
            _goal = State(initialValue: GoalData())
        }
    }
    
    // button disabling logic
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
            
            HStack {
                // pushes close icon to the top right
                Spacer()
                
                // close button
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

            // switching between different steps
            if currentStep == 1 {
                stepOne
            } else if currentStep == 2 {
                stepTwo
            } else {
                stepThree
            }
            
            Spacer()
            HStack{
                // back navigation button which appears on step 2 and 3
                if currentStep > 1 {
                    Button(action: {
                        withAnimation { currentStep -= 1 }
                    }) {
                        HStack(spacing: 8) {
                            // left icon
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 28, height: 28)
                                
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            // text
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
                // next and done button
                Button(action: {
                    if currentStep < 3 {
                        withAnimation { currentStep += 1 }
                    } else {
                        // close popup
                        withAnimation { isPresented = false }
                        //based on whether you are editing or saving fresh
                        if editingGoal != nil {
                            updateGoalInUserDefaults(updatedGoal: goal)
                        } else {
                            saveGoalToUserDefaults(newGoal: goal)
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        // changing the label of the button depending the step number
                        Text(currentStep == 3 ? "Done" : "Next")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        
                        ZStack {
                            // right icon
                            Circle()
                                .fill(.white)
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 24)
                    .padding(.trailing, 8)
                    .background(Color(red: 255/255, green: 185/255, blue: 135/255))
                    .clipShape(Capsule())
                    
                }
                .disabled(isButtonDisabled)
                .opacity(isButtonDisabled ? 0.5 : 1.0)

                .padding()
            }
            
        }
        // focus logic
        .onAppear {
            
            isTextFieldFocused = true
        }
        // focus for steps with text fields
        .onChange(of: currentStep) { oldStep, newStep in
            if newStep == 1 || newStep == 3 {
                isTextFieldFocused = true
            } else {
                isTextFieldFocused = false
            }
        }
        .padding()
    }

    // name of the goal
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

    // choose an icon
    var stepTwo: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Pick an icon").font(.title2).bold()
            // 4 column grid to show icon options
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(icons, id: \.self) { icon in
                    Image(systemName: icon)
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .background(goal.icon == icon ? Color.orange : Color.orange.opacity(0.2))
                        .clipShape(Circle())
                        // updates goal icon
                        .onTapGesture { goal.icon = icon }
                }
            }
        }
    }

    // enter the amount
    var stepThree: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How much do you need to save?")
                .font(.title2)
                .bold()
            
            HStack(spacing: 5) {
                
                Text("$")
                    .font(.title2)
                    .foregroundColor(.gray)
                // text field links to amountString, so that input can be validated before being assigned to goal.amount
                TextField("Enter amount here", text: $amountString)
       
                    // focus
                    .focused($isTextFieldFocused)
                    .textFieldStyle(.plain)
                    .onChange(of: amountString) { oldValue, newValue in
                        // only allows numbers
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        
                        // only one decimal point allowed
                        if filtered.filter({ $0 == "." }).count > 1 {
                            amountString = String(filtered.dropLast())
                        } else {
                            amountString = filtered
                        }
                        
                        
                        goal.amount = Double(amountString) ?? 0.0
                    }
            }
            Divider()
        }
    }
}
