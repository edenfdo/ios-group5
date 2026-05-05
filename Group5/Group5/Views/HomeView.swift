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
    
    @State private var displayDate = Date()
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack (spacing: 20) {
                    HStack(spacing: 15) {
                        expenseCard(title: "Today", amount: viewModel.todayTotal)
                        expenseCard(title: "Remaining", amount: viewModel.remainingMonthlyBudget)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        print("Goal button tapped")
                        // Logic to navigate or open a sheet goes here
                    }) {
                        Text("Create a goal")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity) // Makes it span the width
                            .padding(.vertical, 14)      // Adjust height
                            .background(Color(red: 255/255, green: 185/255, blue: 135/255)) // Match the orange/peach color
                            .cornerRadius(12)
                    }
                    .padding(.horizontal) // Adds space on the sides to match your cards
                    
//                    Circle()
//                        .fill(Color.gray.opacity(0.2))
//                        .frame(width: 150, height: 150)
//                        .overlay(Image(systemName: "car.fill").font(.system(size: 60)))

                    calendarView
//                    Text("Today's Total")
//                    Text("$\(viewModel.todayTotal, specifier: "%.2f")")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
                }
                .padding(.top)
                
            }
            .background(.backgroundColour)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SaveSync")
                        .font(.headline) // Adjust font style to match your design
                        
                       
                }
            }
            
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

            // Day Headers (Su, Mo, Tu...)
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
                    let dayColor: Color = dayTotal == 0 ? .clear : (percentage > 1.0 ? .red.opacity(0.6) : .green.opacity(0.4))
                    
                    Text("\(dayNumber)")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 35, height: 35)
                        .background(dayColor)
                        .foregroundColor(dayTotal > 0 ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
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
