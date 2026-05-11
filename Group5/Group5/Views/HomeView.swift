//
//  HomeView.swift
//  Group5
//
//  Created by chuyue zhang on 2/5/2026.
//

import SwiftUI

//Home Page
struct HomeView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingGoalFlow = false
    @State private var savedGoal: GoalData? = nil
    @State private var selectedDate: Date? = nil
    @State private var showingDayDetail = false
    @State private var displayDate = Date()
    
    var body: some View {
        ZStack {
            Color("BackgroundColour")
                .ignoresSafeArea()
            ZStack {
                VStack {
                    Text("SaveSync")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    
                    ScrollView{
                        VStack (spacing: 20) {
                            HStack(spacing: 15) {
                                expenseCard(title: "Today", amount: viewModel.todayTotal)
                                expenseCard(title: "Remaining", amount: viewModel.remainingMonthlyBudget)
                            }
                            .padding(.horizontal)
                            VStack {
                                if let goal = savedGoal {
                                    
                                    HStack(spacing: 20) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Your Goal Progress:")
                                                .font(.system(size: 22, weight: .bold))
                                            
                                            let remaining = max(goal.amount - viewModel.remainingMonthlyBudget, 0)
                                            
                                            Text("$\(remaining, specifier: "%.2f") away!")
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                                        
                                        Spacer()
                                        
                                        GoalProgressCircle(goal: goal, currentSavings: viewModel.remainingMonthlyBudget)
                                            .frame(width: 120, height: 120)
                                    }
                                    .padding(25)
                                    .background(Color(red: 252/255, green: 245/255, blue: 230/255))
                                    .cornerRadius(20)
                                    .padding(.horizontal)
                                    
                                } else {
                                    
                                    Button(action: {
                                        showingGoalFlow = true
                                    }) {
                                        Text("Create a goal")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(Color(red: 255/255, green: 185/255, blue: 135/255))
                                            .cornerRadius(12)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            .padding(.horizontal)
                            
                            calendarView
                            
                        }
                        .padding(.top)
                        
                    }
                    .background(.backgroundColour)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("SaveSync")
                                .font(.headline)
                            
                            
                        }
                    }
                }
                .padding(.bottom, 90)
                .padding(.top, 65)
                .padding(.horizontal, 3)
                
                if showingGoalFlow {
                    
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { showingGoalFlow = false }
                        }
                    
                    
                    GoalView(isPresented: $showingGoalFlow)
                        .frame(width: 340, height: 550)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(radius: 20)
                        .transition(.scale.combined(with: .opacity))
                }
                
                else if showingDayDetail, let date = selectedDate {
                    
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showingDayDetail = false } }
                    
                    
                    if showingDayDetail, let dateToDisplay = selectedDate {
                        CalendarPopUp(
                            date: dateToDisplay,
                            expenses: viewModel.expensesFor(day: dateToDisplay),
                            isPresented: $showingDayDetail,
                            onDelete: { indices in
                                let dayExpenses = viewModel.expensesFor(day: dateToDisplay)
                                indices.forEach { index in
                                    viewModel.deleteExpense(dayExpenses[index])
                                }
                            }
                        )
                        .id(dateToDisplay)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 100)
                        .transition(.scale)
                        
                    }
                }
                
            }
            .ignoresSafeArea()
            .onAppear {
                loadGoal()
            }
            .onChange(of: showingGoalFlow) { _, isShowing in
                if !isShowing {
                    loadGoal()
                }
            }
        }
            
    }
        
        func loadGoal() {
            if let data = UserDefaults.standard.data(forKey: "SavedGoals"),
               let decoded = try? JSONDecoder().decode([GoalData].self, from: data) {
                
                self.savedGoal = decoded.last
            }
        }
        
        private func expenseCard(title: String, amount: Double) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Text("$\(amount, specifier: "%.2f")")
                    .font(.system(size: 24, weight: .bold))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
        }
        
        private var calendarView: some View {
            VStack(spacing: 15) {
                
                HStack {
                    
                    Text(displayDate.formatted(.dateTime.month(.wide).year()))
                        .font(.system(size: 18, weight: .bold))
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        // back button
                        Button(action: { moveMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                        }
                        
                        // forward button
                        Button(action: { moveMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 5)
                
                
                let daysOfWeek = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.gray)
                    }
                }
                
                
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                
                
                let days: [Date] = displayDate.getAllDays()
                
                LazyVGrid(columns: columns, spacing: 10) {
                    let startOffset = Calendar.current.component(.weekday, from: days.first!) - 1
                    
                    ForEach(0..<startOffset, id: \.self) { _ in
                        Text("").frame(width: 35, height: 35)
                    }
                    
                    ForEach(days, id: \.self) { date in
                        let dayNumber = Calendar.current.component(.day, from: date)
                        
                        // budget colour logic
                        let dailyLimit = viewModel.monthlyBudget / 30
                        let dayTotal = viewModel.totalFor(day: date)
                        let percentage = dayTotal / dailyLimit
                        
                        var dayColor: Color {
                            
                            let baseColor = Color(red: 255/255, green: 173/255, blue: 123/255)
                            
                            
                            if dayTotal == 0 { return .clear }
                            print("Checking Color - Percentage: \(percentage)")
                            
                            
                            switch percentage {
                            case ..<0.25:
                                print("Level 1 (0.2)")
                                return baseColor.opacity(0.2) // Level 1: Under 25%
                                
                            case ..<0.50:
                                print("Level 2 (0.4)")
                                return baseColor.opacity(0.4) // Level 2: 25% to 49%
                            case ..<0.75:
                                print("Level 3 (0.7)")
                                return baseColor.opacity(0.7) // Level 3: 50% to 74%
                            default:
                                print("Level 4 (1.0)")
                                return baseColor.opacity(1.0) // Level 4: 75% and above
                            }
                        }
                        
                        Text("\(dayNumber)")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 35, height: 35)
                            .background(dayColor)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                selectedDate = date // Set the specific date clicked
                                withAnimation { showingDayDetail = true }
                            }
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal)
        }
        
    
    private func moveMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: displayDate) {
            displayDate = newDate
        }
    }
}

extension Date {
    func getAllDays() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
        
        return range.compactMap { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)!
        }
    }
}




#Preview {
    HomeView(viewModel: ExpenseViewModel())
}
