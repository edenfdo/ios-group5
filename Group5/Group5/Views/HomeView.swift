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
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack (spacing: 20) {
                    HStack(spacing: 15) {
                        expenseCard(title: "Today", amount: viewModel.todayTotal)
                        expenseCard(title: "Remaining", amount: 125.10) // Update this logic in VM later
                    }
                    .padding(.horizontal)
                    
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 150, height: 150)
                        .overlay(Image(systemName: "car.fill").font(.system(size: 60)))

                    calendarView
//                    Text("Today's Total")
//                    Text("$\(viewModel.todayTotal, specifier: "%.2f")")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
                }
                .padding(.top)
                
            }
            .toolbar {
                
                ToolbarItem(placement: .principal) {
                    Text("SaveSync")
                        .font(.headline) // Adjust font style to match your design
                        .foregroundColor(.primary)
                }
            }
            
        }
        
    }
    
    private func expenseCard(title: String, amount: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
            
            Text(amount, format: .currency(code: "USD"))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var calendarView: some View {
        VStack(spacing: 15) {
            // Month & Year Header
            HStack {
                Text("September 2025") // You can make this dynamic later
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                HStack(spacing: 20) {
                    Image(systemName: "chevron.left")
                    Image(systemName: "chevron.right")
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

            // The Grid of Days
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            let days = Date().getAllDays() // Gets dates for current month
            
            LazyVGrid(columns: columns, spacing: 10) {
                // Add blank spaces for the start of the month
                let startOffset = Calendar.current.component(.weekday, from: days.first!) - 1
                ForEach(0..<startOffset, id: \.self) { _ in
                    Text("").frame(width: 35, height: 35)
                }

                ForEach(days, id: \.self) { date in
                    let dayNumber = Calendar.current.component(.day, from: date)
                    let isOverBudget = viewModel.totalFor(day: date) > 50.0 // Your threshold
                    
                    Text("\(dayNumber)")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 35, height: 35)
                        .background(isOverBudget ? Color(red: 255/255, green: 173/255, blue: 123/255) : Color.clear)
                        .foregroundColor(isOverBudget ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
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
