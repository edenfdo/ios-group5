//
//  BudgetView.swift
//  Group5
//
//  Created by chuyue zhang on 2/5/2026.
//

import SwiftUI

// Budget page view

struct BudgetView: View {
    // Import ViewModel
    @State private var showBudgetSetting = false
    
    // ViewModel
    @ObservedObject var viewModel: BudgetViewModel
    @ObservedObject var expenseViewModel: ExpenseViewModel

    var body: some View {
        // Background
        ZStack {
            Color(red: 1.0, green: 0.98, blue: 0.90)
                .ignoresSafeArea()
            
            // Main vertical layout
            VStack(spacing: 0)
            {
                // Header (Page title)
                Text("Budget")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 65)
                    .padding(.bottom, 20)
                monthlyBudgetCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                // Category section
                HStack
                {
                    Text("Category Limits")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Scrollable category budget limits
                ScrollView
                {
                    VStack(spacing: 20)
                    {
                        // Display all category rows
                        ForEach(viewModel.categoryLimits)
                        {
                            item in
                            CategoryBudgetRow(
                                item: item,
                                spent: spentThisMonth(for: item.category),
                                isLatest: latestCategory == item.category)
                        }
                    }
                    .padding(.horizontal, 20)
                    .safeAreaPadding(.bottom, 90)
                }
            }
            .padding(.bottom, 90)
        }
        .sheet(isPresented: $showBudgetSetting)
        {
            PopUpBudgetSettingView(viewModel: viewModel)
                .interactiveDismissDisabled()
        }
    }
    
    // Calculate total spent for current month
    var totalSpentThisMonth: Double
    {
        let calendar = Calendar.current
        return expenseViewModel.expenses
            .filter {
                calendar.isDate(
                    $0.date,
                    equalTo: Date(),
                    toGranularity: .month
                )
            }
            .reduce(0) { $0 + $1.spending }
    }

    // Calculate spent amount for a specific category
    func spentThisMonth(for category: ExpenseCategory) -> Double
    {
        let calendar = Calendar.current
        return expenseViewModel.expenses
            .filter {
                calendar.isDate(
                    $0.date,
                    equalTo: Date(),
                    toGranularity: .month
                )
                &&
                $0.category == category
            }
            .reduce(0) { $0 + $1.spending }
    }

    // Most recently added category
    var latestCategory: ExpenseCategory?
    {
        expenseViewModel.expenses.last?.category
    }

    // Monthly budget card UI
    private var monthlyBudgetCard: some View
    {
        VStack(alignment: .leading, spacing: 14)
        {
            // To set monthly budget and category limits
            Button
            {
                // Set Monthly Budget View
                showBudgetSetting = true
            }
            label:
            {
                Text("Set Monthly Budget")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color("SetBudgetButton"))
                    .cornerRadius(18)
            }
            
            // Monthly budget text information
            HStack
            {
                Text("Monthly Budget")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Text("$\(Int(totalSpentThisMonth)) / $\(Int(viewModel.monthlyBudget))")
                    .font(.subheadline)
            }
            
            // Safeguard for outofbound
            let rawTotal = viewModel.monthlyBudget
            let rawValue = totalSpentThisMonth
            let finiteTotal = rawTotal.isFinite ? rawTotal : 0
            let finiteValue = rawValue.isFinite ? rawValue : 0
            let safeTotal = finiteTotal > 0 ? finiteTotal : 1
            let clampedValue = min(max(finiteValue, 0), safeTotal)
            ProgressView(value: clampedValue, total: safeTotal)
                .tint(Color("Chart"))
                .scaleEffect(x: 1, y: 2.2, anchor: .center)
        }
        .padding()
        .background(Color("Catogories"))
        .cornerRadius(10)
    }
}

// Each category view
struct CategoryBudgetRow: View
{
    let item: CategoryLimit
    let spent: Double
    let isLatest: Bool
    
    var body: some View
    {
        VStack(spacing: 8)
        {
            HStack
            {
                Circle()
                    .fill(isLatest ? .pink : .clear)
                    .frame(width: 6, height: 6)
                
                ZStack
                {
                    Circle()
                        .fill(.white.opacity(0.8))
                        .frame(width: 46, height: 46)
                    Image(systemName: item.category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color("Catogories"))
                }
                VStack(alignment: .leading, spacing: 4)
                {
                    Text(item.category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Spent $ \(Int(spent)) this month")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("$\(Int(item.limit))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            // Safeguard for outofbound
            let rawTotal = item.limit
            let rawValue = spent
            let finiteTotal = rawTotal.isFinite ? rawTotal : 0
            let finiteValue = rawValue.isFinite ? rawValue : 0
            let safeTotal = finiteTotal > 0 ? finiteTotal : 1
            let clampedValue = min(max(finiteValue, 0), safeTotal)
            ProgressView(value: clampedValue, total: safeTotal)
                .tint(Color("Chart"))
                .scaleEffect(x: 1, y: 2.2, anchor: .center)
        }
    }
}

#Preview {
    BudgetView(viewModel: BudgetViewModel(), expenseViewModel: ExpenseViewModel())
}

