//
//  AnalyticsView.swift
//  Group5
//
//  Created by chuyue zhang on 2/5/2026.
//

import SwiftUI

//Analytics View page
struct AnalyticsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    init(viewModel: ExpenseViewModel = ExpenseViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {

        ZStack {
            Color("BackgroundColour")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    titleSection
                    totalSpendCard
                    lineChartCard
                    topExpensesSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 90)
                .padding(.top, 65)
                .safeAreaPadding(.bottom, 90)
            }
        }
        .padding(.bottom, 90)
    }
    
    //page title
    var titleSection: some View {
        Text("Analytics")
            .font(.headline)
            .fontWeight(.bold)
//            .padding(.top, 10)
            .padding(.bottom, 1)
    }
    
    //total spent card
    var totalSpendCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Spent")
                .font(.subheadline)
                .fontWeight(.bold)
            
            Text("$  \(Int(totalSpentThisYear))")
                .font(.system(size: 50, weight: .bold))
                .foregroundStyle(AppColours.black)
            
            Text("\(expensesThisYear.count) expenses")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
    
    //line graph card
    var lineChartCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Monthly Spending")
                .font(.subheadline)
                .fontWeight(.bold)
            
            MonthlyLineChart(monthlyTotals: monthlyTotals)
                .frame(height: 170)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
    
    //top expenses list
    var topExpensesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Top expenses")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(categoryTotals, id: \.category) { item in
                categoryExpenseRow(category: item.category, total: item.total, count: item.count)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    //each category row
    func categoryExpenseRow(category: ExpenseCategory, total: Double, count: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color("Catogories").opacity(0.25))
                    .frame(width: 48, height: 48)
                
                Image(systemName: category.icon)
                    .foregroundStyle(AppColours.orange)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue.capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(count) expenses")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text("$\(Int(total))")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
    
    //expenses only for this year
    var expensesThisYear: [ExpenseItem] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        return viewModel.expenses.filter { expense in
            calendar.component(.year, from: expense.date) == currentYear
        }
    }
    
    //total spent this year
    var totalSpentThisYear: Double {
        expensesThisYear.reduce(0) { total, expense in
            total + expense.spending
        }
    }
    
    //monthly totals from January to December
    var monthlyTotals: [Double] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        var totals = Array(repeating: 0.0, count: 12)
        
        for expense in expensesThisYear {
            let month = calendar.component(.month, from: expense.date)
            totals[month - 1] += expense.spending
        }
        
        //future months stay as zero
        for index in currentMonth..<12 {
            totals[index] = 0
        }
        
        return totals
    }
    
    //category totals in alphabetical order
    var categoryTotals: [(category: ExpenseCategory, total: Double, count: Int)] {
        ExpenseCategory.allCases.map { category in
            let categoryExpenses = expensesThisYear.filter { $0.category == category }
            let total = categoryExpenses.reduce(0) { $0 + $1.spending }
            
            return (category: category, total: total, count: categoryExpenses.count)
        }
        .sorted { $0.category.rawValue < $1.category.rawValue }
    }
}

//Simple line graph for monthly expenses
struct MonthlyLineChart: View {
    let monthlyTotals: [Double]
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 8) {
                ZStack {
                    chartGrid
                    chartLine(size: geo.size)
                }
                .frame(height: 135)
                
                monthLabels
            }
        }
    }
    
    //light chart lines in background
    var chartGrid: some View {
        VStack {
            ForEach(0..<5, id: \.self) { _ in
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 1)
                Spacer()
            }
        }
    }
    
    //month names under graph
    var monthLabels: some View {
        HStack {
            ForEach(months, id: \.self) { month in
                Text(month)
                    .font(.system(size: 9))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    //draws the actual spending line
    func chartLine(size: CGSize) -> some View {
        let maxValue = max(monthlyTotals.max() ?? 0, 1)
        let width = size.width
        let height: CGFloat = 135
        let gap = width / CGFloat(monthlyTotals.count - 1)
        
        let points = monthlyTotals.enumerated().map { index, total in
            CGPoint(
                x: CGFloat(index) * gap,
                y: height - CGFloat(total / maxValue) * height
            )
        }
        
        return ZStack {
            Path { path in
                guard let firstPoint = points.first else { return }
                path.move(to: firstPoint)
                
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color("Chart"), lineWidth: 1.5)
            
            ForEach(points.indices, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .stroke(Color("Chart"), lineWidth: 1)
                    )
                    .position(points[index])
            }
        }
        
    }
}

#Preview {
    AnalyticsView()
}
