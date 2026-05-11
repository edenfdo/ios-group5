//
//  HomeView.swift
//  Group5
//
//  Created by chuyue zhang on 2/5/2026.
//

import SwiftUI

// Home Page
struct HomeView: View {
    // observes the expense view model
    @ObservedObject var viewModel: ExpenseViewModel
    
    // local state which controls whether the goal creation flow is shown or not
    @State private var showingGoalFlow = false
    
    // stores the goal as an optional
    @State private var savedGoal: GoalData? = nil
    
    // stores which date was selected by the user
    @State private var selectedDate: Date? = nil
    
    // local state which controls whether day detail popup is shown or not
    @State private var showingDayDetail = false
    
    // stores the currently shown month for the calendar
    @State private var displayDate = Date()
    
    var body: some View {
        ZStack {
            // background colour fill
            Color("BackgroundColour")
                .ignoresSafeArea()
            ZStack {
                // displays app name
                VStack {
                    Text("SaveSync")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    
                    ScrollView{
                        VStack (spacing: 20) {
                            // two cards side by side
                            HStack(spacing: 15) {
                                // today card
                                expenseCard(title: "Today", amount: viewModel.todayTotal)
                                // remaining card
                                expenseCard(title: "Remaining", amount: viewModel.remainingMonthlyBudget)
                            }
                            .padding(.horizontal)
                            VStack {
                                // display goal if exists
                                if let goal = savedGoal {
                                    
                                    HStack(spacing: 20) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Your Goal Progress:")
                                                .font(.system(size: 22, weight: .bold))
                                            
                                            // calculates how much more needs to be saved to achieve the goal
                                            let remaining = max(goal.amount - viewModel.remainingMonthlyBudget, 0)
                                            
                                            // displays the remaining amount
                                            Text("$\(remaining, specifier: "%.2f") away!")
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                                        
                                        Spacer()
                                        
                                        // goal progress circle
                                        GoalProgressCircle(goal: goal, currentSavings: viewModel.remainingMonthlyBudget)
                                            .frame(width: 120, height: 120)
                                    }
                                    .padding(25)
                                    .background(Color(red: 252/255, green: 245/255, blue: 230/255))
                                    .cornerRadius(20)
                                    .padding(.horizontal)
                                    
                                } else {
                                    // button which allows users to create a goal
                                    Button(action: {
                                        showingGoalFlow = true
                                    }) {
                                        // label text
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
                            
                            // renders calendar
                            calendarView
                            
                        }
                        .padding(.top)
                        
                    }
                    .background(.backgroundColour)
                    
                }
                .padding(.bottom, 90)
                .padding(.top, 65)
                .padding(.horizontal, 3)
                
                if showingGoalFlow {
                    // creates a dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        // if you tap outside the popup box, the popup will close
                        .onTapGesture {
                            withAnimation { showingGoalFlow = false }
                        }
                    
                    // displays goal view
                    GoalView(isPresented: $showingGoalFlow)
                        .frame(width: 340, height: 550)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(radius: 20)
                        // animation
                        .transition(.scale.combined(with: .opacity))
                }
                
                else if showingDayDetail {
                    // creates a dimmed background
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showingDayDetail = false } }
                    
                    if showingDayDetail, let dateToDisplay = selectedDate {
                        CalendarPopUp(
                            // passes the date, expenses from that date, a binding to control the dismissal of the popup box
                            date: dateToDisplay,
                            expenses: viewModel.expensesFor(day: dateToDisplay),
                            isPresented: $showingDayDetail,
                            // deleting an expense
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
    
    // loads and decodes saved goals from UserDefaults
    func loadGoal() {
        if let data = UserDefaults.standard.data(forKey: "SavedGoals"),
           let decoded = try? JSONDecoder().decode([GoalData].self, from: data) {
            
            self.savedGoal = decoded.last
        }
    }
        
    // expense card component
    private func expenseCard(title: String, amount: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // card title
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
            // amount
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
                // shows the current month and year
                Text(displayDate.formatted(.dateTime.month(.wide).year()))
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                HStack(spacing: 20) {
                    // back navigation button
                    Button(action: { moveMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    // forward navigation button
                    Button(action: { moveMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 5)
            
            // day labels
            let daysOfWeek = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            
            // creating 7 columns
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            // get all the days in the current month
            let days: [Date] = displayDate.getAllDays()
            
            LazyVGrid(columns: columns, spacing: 10) {
                // decides how many empty cells to display before the first day
                let startOffset = Calendar.current.component(.weekday, from: days.first!) - 1
                
                // loops for each day
                ForEach(0..<startOffset, id: \.self) { _ in
                    Text("").frame(width: 35, height: 35)
                }
                
                ForEach(days, id: \.self) { date in
                    let dayNumber = Calendar.current.component(.day, from: date)
                    
                    // budget colour logic
                    let dailyLimit = viewModel.monthlyBudget / 30
                    let dayTotal = viewModel.totalFor(day: date)
                    // spending percentage
                    let percentage = dayTotal / dailyLimit
                    
                    var dayColor: Color {
                        
                        // base colour
                        let baseColor = Color(red: 255/255, green: 173/255, blue: 123/255)
                        
                        // no expenses which lead to a clear fill
                        if dayTotal == 0 { return .clear }
                        print("Checking Color - Percentage: \(percentage)")
                        
                        
                        switch percentage {
                        case ..<0.25:
                            // under 25%
                            print("Level 1 (0.2)")
                            return baseColor.opacity(0.2)
                            
                        case ..<0.50:
                            // 25% to 49%
                            print("Level 2 (0.4)")
                            return baseColor.opacity(0.4)
                        case ..<0.75:
                            // 50% to 74%
                            print("Level 3 (0.7)")
                            return baseColor.opacity(0.7)
                        default:
                            // 75% and above
                            print("Level 4 (1.0)")
                            return baseColor.opacity(1.0)
                        }
                    }
                    // day cell
                    Text("\(dayNumber)")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 35, height: 35)
                        .background(dayColor)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        // clicking on date leads to day detail popup appearing
                        .onTapGesture {
                            selectedDate = date
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
        
    // month navigation
    private func moveMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: displayDate) {
            displayDate = newDate
        }
    }
}

// generates all days in a specific month
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
