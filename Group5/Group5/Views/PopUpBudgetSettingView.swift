//
//  PopUpBudgetSettingView.swift
//  Group5
//
//  Created by KK on 8/5/2026.
//

import SwiftUI

struct PopUpBudgetSettingView: View
{
    // ViewModel
    @ObservedObject var viewModel: ExpenseViewModel
    // To set budget and limit data
    @State private var showLimitInput = false
    @State private var selectedCategory: ExpenseCategory?
    @State private var inputAmount = ""
    @State private var showWarning = false
    @State private var editingMonthlyBudget = false
    @State private var showInvalidInputWarning = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            // Page Title
            Text("Budget Editing")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top, 28)
                .padding(.bottom, 24)
            // Monthly budget display row
            monthlyBudgetRow
            
            ScrollView
            {
                VStack(spacing: 22)
                {
                    ForEach(viewModel.categoryLimits)
                    {
                        item in
                        PopupBudgetCategoryRow(item: item)
                        {
                            editingMonthlyBudget = false
                            selectedCategory = item.category
                            inputAmount = ""
                            showLimitInput = true
                        }
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 28)
        }
        Button
        {
            dismiss()
        } label:
        {
            Text("Save")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .background(Color("Categories"))
                .cornerRadius(18)
        }
        .padding(.bottom, 30)
        .background(Color.white)
        .alert(editingMonthlyBudget ? "Set Monthly Budget" : "Set Category Limit", isPresented: $showLimitInput)
        {
            
            TextField("Enter amount", text: $inputAmount)
                .keyboardType(.decimalPad)
            
            Button("Cancel", role: .cancel)
            {
                inputAmount = ""
            }
            
            Button("Save")
            {
                guard let amount = Double(inputAmount), amount >= 0
                else
                {
                    showInvalidInputWarning = true
                    return
                }
                if editingMonthlyBudget
                {
                    viewModel.setMonthlyBudget(amount)
                }
                else if let category = selectedCategory
                {
                    let success = viewModel.setCategoryLimit(category: category, limit: amount)

                    if !success
                    {
                        showWarning = true
                        return
                    }
                }
                inputAmount = ""
            }
        }
        .alert("Category limits exceed monthly budget", isPresented: $showWarning)
        {
            Button("OK", role: .cancel) { }
        } message:
        {
            Text("Please increase the monthly budget first before setting this category limit.")
        }
        .alert("Invalid input", isPresented: $showInvalidInputWarning)
        {
            Button("OK", role: .cancel)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
                {
                    showLimitInput = true
                }
            }
        } message:
        {
            Text("Please enter a number.")
        }
    }
    
    // Monthly budget display row
    private var monthlyBudgetRow: some View {
        HStack(alignment: .center) {
            Text("Monthly Budget")
                .font(.subheadline)
                .fontWeight(.bold)
            
            Spacer()
            // Edit monthly budget button
            Button
            {
                editingMonthlyBudget = true
                inputAmount = ""
                showLimitInput = true
            } label:
            {
                Image(systemName: "pencil")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            // Current monthly budget amount
            Text("$\(Int(viewModel.monthlyBudget))")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.orange.opacity(0.55))
        .cornerRadius(10)
        .padding(.horizontal, 8)
    }
}

// Individual category row view
struct PopupBudgetCategoryRow: View
{
    let item: CategoryLimit
    let onEdit: () -> Void
    
    var body: some View
    {
        HStack(spacing: 16)
        {
            ZStack
            {
                Circle()
                    .fill(Color.gray.opacity(0.08))
                    .frame(width: 44, height: 44)

                Image(systemName: item.category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color("Categories"))
            }
            Text(item.category.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            
            Button
            {
                onEdit()
            } label:
            {
                Image(systemName: "pencil")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            Text("$\(Int(item.limit))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 48, alignment: .trailing)
        }
    }
}


#Preview {
    PopUpBudgetSettingView(viewModel: ExpenseViewModel())
}
