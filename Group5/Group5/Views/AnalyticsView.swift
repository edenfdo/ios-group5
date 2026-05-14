//
//  AnalyticsView.swift
//  Group5
//
//  Created by chuyue zhang on 2/5/2026.
//

import SwiftUI
import Charts


//Analytics View page.
struct AnalyticsView: View {
    // gets the expense data from the view model so the page shows updated spending
    @ObservedObject var viewModel: ExpenseViewModel
    
    init(viewModel: ExpenseViewModel = ExpenseViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {

        ZStack {
            Color("BackgroundColour")
                .ignoresSafeArea()
            VStack {
                // main page heading
                Text("Analytics")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                // scroll view for the user to go through each categories
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        totalSpendCard
                        lineChartCard
                        topExpensesSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
                    .safeAreaPadding(.bottom, 90)
                }
            }
            .padding(.bottom, 90)
            .padding(.top, 65)
            .padding(.horizontal, 3)
        }
    }
    
    //total spent card shows the total spend summary card
    var totalSpendCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Spent")
                .font(.subheadline)
                .fontWeight(.bold)
            // displays the total money spent this year
            Text("$  \(Int(totalSpentThisYear))")
                .font(.system(size: 50, weight: .bold))
                .foregroundStyle(.black)
            
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
    
    //line graph card for the monthly spending
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
    
    //top expenses list shows the top spending categories list
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
    
    //this shows each expense category row
    func categoryExpenseRow(category: ExpenseCategory, total: Double, count: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color("Categories").opacity(0.25))
                    .frame(width: 48, height: 48)
                
                Image(systemName: category.icon)
                    .foregroundStyle(Color.categories)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue.capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                // this showstotal money spent this year
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
    
    //calculate the total spending this year
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
    
    //category totals in the alphabetical order
    var categoryTotals: [(category: ExpenseCategory, total: Double, count: Int)] {
        ExpenseCategory.allCases.map { category in
            let categoryExpenses = expensesThisYear.filter { $0.category == category }
            let total = categoryExpenses.reduce(0) { $0 + $1.spending }
            
            return (category: category, total: total, count: categoryExpenses.count)
        }
        .sorted {
            if $0.total == $1.total {
                return $0.category.rawValue < $1.category.rawValue
            } else {
                return $0.total > $1.total
            }
        }
    }
}

struct MonthlyLineChart: View {
    let monthlyTotals: [Double]
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    // Updated data model mapping an index property for strict timeline sorting
    var chartData: [(index: Int, month: String, total: Double)] {
        monthlyTotals.enumerated().map { index, total in
            (index: index, month: months[index], total: total)
        }
    }
    
    var body: some View {
        Chart {
            ForEach(chartData, id: \.month) { item in
                // 1. Plots line across custom sorted X axis coordinates
                LineMark(
                    x: .value("Month", item.month),
                    y: .value("Spending", item.total)
                )
                .interpolationMethod(.linear)
                .foregroundStyle(Color("Chart"))
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                
                // 2. Overlays data tracking circles matching your canvas design
                PointMark(
                    x: .value("Month", item.month),
                    y: .value("Spending", item.total)
                )
                .foregroundStyle(.white)
                .annotation(position: .overlay) {
                    Circle()
                        .stroke(Color("Chart"), lineWidth: 1)
                        .frame(width: 6, height: 6)
                }
            }
        }
        // Force the layout engine to sort elements chronologically by their index order
        .chartXScale(domain: months)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Color.gray.opacity(0.15))
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(moneyLabel(doubleValue))
                            .font(.system(size: 9))
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let monthString = value.as(String.self) {
                        Text(monthString)
                            .font(.system(size: 10))
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
    
    func moneyLabel(_ value: Double) -> String {
        if value >= 1000 {
            return "$\(Int(value / 1000))K"
        } else {
            return "$\(Int(value))"
        }
    }
}




////Simple line graph for monthly expenses
//struct MonthlyLineChart: View {
//    let monthlyTotals: [Double]
//    // months labels under the graph x axis
//    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//    
//    var body: some View {
//        GeometryReader { geo in
//            let labelWidth: CGFloat = 25
//            let chartHeight: CGFloat = 135
//            let chartWidth = geo.size.width - labelWidth
//            
//            VStack(spacing: 8) {
//                HStack(spacing: 0) {
//                    yAxisLabels
//                        .frame(width: labelWidth, height: chartHeight)
//                    
//                    ZStack {
//                        chartGrid
//                        chartLine(size: CGSize(width: chartWidth, height: chartHeight))
//                    }
//                    .frame(width: chartWidth, height: chartHeight)
//                }
//                
//                HStack(spacing: 0) {
//                    Spacer()
//                        .frame(width: labelWidth)
//                    
//                    monthLabels
//                        .frame(width: chartWidth)
//                }
//            }
//        }
//    }
//    
//    //money labels on y axis
//    var yAxisLabels: some View {
//        let maxValue = max(monthlyTotals.max() ?? 0, 1)
//        
//        return VStack {
//            ForEach((0..<5).reversed(), id: \.self) { index in
//                let value = maxValue * Double(index) / 4.0
//                Text(moneyLabel(value))
//                    .font(.system(size: 9))
//                    .foregroundStyle(.gray)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                
//                if index != 0 {
//                    Spacer()
//                }
//            }
//        }
//    }
//    
//    //light chart lines in background
//    var chartGrid: some View {
//        VStack {
//            ForEach(0..<5, id: \.self) { _ in
//                Rectangle()
//                    .fill(Color.gray.opacity(0.15))
//                    .frame(height: 1)
//                Spacer()
//            }
//        }
//    }
//    
//    //month names under graph
//    var monthLabels: some View {
//        HStack {
//            ForEach(months, id: \.self) { month in
//                Text(month)
//                    .font(.system(size: 10))
//                    .foregroundStyle(.gray)
//                    .frame(maxWidth: .infinity)
//                    .lineLimit(1)
//                    .minimumScaleFactor(0.6)
//            }
//        }
//    }
//    
//    //draws the spending line sing monthly expense values
//    func chartLine(size: CGSize) -> some View {
//        let maxValue = max(monthlyTotals.max() ?? 0, 1)
//        let width = size.width
//        let height = size.height
//        let gap = width / CGFloat(monthlyTotals.count - 1)
//        // converts expense values into points on the graph
//        let points = monthlyTotals.enumerated().map { index, total in
//            CGPoint(
//                x: CGFloat(index) * gap,
//                y: height - CGFloat(total / maxValue) * height
//            )
//        }
//        
//        return ZStack {
//            Path { path in
//                guard let firstPoint = points.first else { return }
//                path.move(to: firstPoint)
//                // connects all points with a line
//                for point in points.dropFirst() {
//                    path.addLine(to: point)
//                }
//            }
//            .stroke(Color("Chart"), lineWidth: 1.5)
//            
//            ForEach(points.indices, id: \.self) { index in
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: 6, height: 6)
//                    .overlay(
//                        Circle()
//                            .stroke(Color("Chart"), lineWidth: 1)
//                    )
//                    .position(points[index])
//            }
//        }
//        
//    }
//    
//    //formats big numbers as money such as K
//    func moneyLabel(_ value: Double) -> String {
//        if value >= 1000 {
//            return "$\(Int(value / 1000))K"
//        } else {
//            return "$\(Int(value))"
//        }
//    }
//}

#Preview {
    AnalyticsView()
}
